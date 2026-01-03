//
//  RewardsNgoViewController.swift
//  Ataya
//
//  Created by Maram on 19/12/2025.
//
//
//  RewardsNgoViewController.swift
//  Ataya
//
//  Created by Maram on 19/12/2025.
//
//
//  RewardsNgoViewController.swift
//  Ataya
//
//  Created by Maram on 19/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class RewardsNgoViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var badgesCollectionView: UICollectionView!
    @IBOutlet weak var pickupsLabel: UILabel!
    @IBOutlet weak var livesLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!

    // اختياري
    @IBOutlet weak var tierLabel: UILabel?
    @IBOutlet weak var tierMedalImageView: UIImageView?

    // MARK: - Firestore (موجود بس ما راح نستخدمه في الديمو)
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var didRecalculateOnce = false

    // ✅ DEMO PLACEHOLDER MODE
    private let useDemoPlaceholder = true   // خليها true الحين

    // MARK: - Badge VM
    private struct BadgeVM {
        let title: String
        let subtitle: String
        let iconName: String
        let colorHex: String
    }

    private let defaultBadges: [BadgeVM] = [
        .init(title: "Fast Responder", subtitle: "Accepted pickups quickly", iconName: "Heart",      colorHex: "#fff8ed"),
        .init(title: "Meal Hero",      subtitle: "Handled donations safely",  iconName: "meal",      colorHex: "#FBF9FF"),
        .init(title: "Community Helper", subtitle: "Supported 3 campaigns",   iconName: "community", colorHex: "#F6FCF3"),
        .init(title: "Trusted Partner",  subtitle: "Maintained high reliability", iconName: "last",  colorHex: "#fffbfb")
    ]

    private var badges: [BadgeVM] = []
    private var metrics = NgoRewardsMetrics()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBadges()

        // ✅ Placeholder ثابت (2000 pts) - بدون Firebase
        if useDemoPlaceholder {
            applyDemoNgoPlaceholder2000()
            return
        }

        // ---- Firebase mode (لما تبين بعدين) ----
        applyInitialPlaceholders()
        ensureNgoRewardsSeededIfNeeded()
        recalculateNgoRewardsFromDonationsIfNeeded()
        startListeningToNgoRewards()
    }

    deinit { listener?.remove() }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBadgesItemSizeIfNeeded()
    }

    // MARK: - ✅ HEX -> UIColor (بدون UIColor(hex:))
    private func color(fromHex hexString: String,
                       fallback: UIColor = UIColor(white: 0.95, alpha: 1)) -> UIColor {
        var s = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6 else { return fallback }

        let r = CGFloat(Int(s.prefix(2), radix: 16) ?? 0) / 255
        let g = CGFloat(Int(s.dropFirst(2).prefix(2), radix: 16) ?? 0) / 255
        let b = CGFloat(Int(s.dropFirst(4).prefix(2), radix: 16) ?? 0) / 255
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }

    // ✅ DEMO PLACEHOLDER (2000 pts)
    private func applyDemoNgoPlaceholder2000() {
        let demoPickups = 20
        let demoLives = 200
        let demoPoints = 2000

        pickupsLabel.text = "\(demoPickups) Successful Pickups"
        livesLabel.text = "\(demoLives) Lives Impacted"
        pointsLabel.text = "\(formatNumber(demoPoints)) pts"

        tierLabel?.text = "Diamond Partner"
        tierMedalImageView?.image = UIImage(named: "tier_diamond")

        badges = defaultBadges
        badgesCollectionView.reloadData()
    }

    private func applyInitialPlaceholders() {
        pickupsLabel.text = "—"
        livesLabel.text = "—"
        pointsLabel.text = "—"

        tierLabel?.text = "Reliable NGO"
        tierMedalImageView?.image = UIImage(named: "tier_starter")

        badges = defaultBadges
        badgesCollectionView.reloadData()
    }

    // MARK: - Badges Layout
    private func setupBadges() {
        badgesCollectionView.register(
            UINib(nibName: "BadgeCardCell", bundle: nil),
            forCellWithReuseIdentifier: BadgeCardCell.reuseId
        )

        badgesCollectionView.dataSource = self
        badgesCollectionView.delegate = self

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 18
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layout.itemSize = CGSize(width: 104, height: 194)

        badgesCollectionView.collectionViewLayout = layout
        badgesCollectionView.showsHorizontalScrollIndicator = false
        badgesCollectionView.alwaysBounceHorizontal = true
        badgesCollectionView.backgroundColor = .clear
        badgesCollectionView.clipsToBounds = false
        badgesCollectionView.layer.masksToBounds = false
        badgesCollectionView.decelerationRate = .fast
    }

    private func updateBadgesItemSizeIfNeeded() {
        guard let layout = badgesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let newSize = CGSize(width: 130, height: 190)
        if layout.itemSize != newSize {
            layout.itemSize = newSize
            layout.invalidateLayout()
        }
    }

    // MARK: - ✅ users/{uid}.rewardsNgo (Firebase mode only)

    private func ensureNgoRewardsSeededIfNeeded() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { snap, _ in
            let data = snap?.data() ?? [:]
            if (data["rewardsNgo"] as? [String: Any]) != nil { return }

            userRef.setData([
                "rewardsNgo": NgoRewardsMetrics.defaultFirestoreDict()
            ], merge: true)
        }
    }

    private func startListeningToNgoRewards() {
        guard let uid = Auth.auth().currentUser?.uid else {
            applyInitialPlaceholders()
            return
        }

        let userRef = db.collection("users").document(uid)
        listener?.remove()

        listener = userRef.addSnapshotListener { [weak self] snap, err in
            guard let self else { return }

            if let err {
                print("❌ NGO rewards listen error:", err.localizedDescription)
                DispatchQueue.main.async { self.applyInitialPlaceholders() }
                return
            }

            let data = snap?.data() ?? [:]
            let rewardsNgo = (data["rewardsNgo"] as? [String: Any]) ?? [:]
            self.metrics = NgoRewardsMetrics(dict: rewardsNgo)

            DispatchQueue.main.async {
                self.pickupsLabel.text = "\(self.metrics.successfulPickups) Successful Pickups"
                self.livesLabel.text = "\(self.metrics.livesImpacted) Lives Impacted"
                self.pointsLabel.text = "\(self.formatNumber(self.metrics.points)) pts"

                let tier = NgoTier.from(points: self.metrics.points)
                self.tierLabel?.text = tier.title
                self.tierMedalImageView?.image = UIImage(named: tier.medalAssetName)

                self.badges = self.defaultBadges
                self.badgesCollectionView.reloadData()
            }
        }
    }

    private func formatNumber(_ n: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f.string(from: NSNumber(value: n)) ?? "\(n)"
    }

    // MARK: - ✅ Calculate from donations -> write users/{uid}.rewardsNgo (Firebase mode only)

    private func recalculateNgoRewardsFromDonationsIfNeeded() {
        guard !didRecalculateOnce else { return }
        didRecalculateOnce = true

        guard let uid = Auth.auth().currentUser?.uid else { return }

        let q = db.collection("donations")
            .whereField("ngoId", isEqualTo: uid)
            .whereField("status", isEqualTo: "completed")

        q.getDocuments { [weak self] snap, err in
            guard let self else { return }
            if let err {
                print("❌ NGO donations query:", err.localizedDescription)
                return
            }

            let docs = snap?.documents ?? []
            let successfulPickups = docs.count

            var lives = 0
            var verifiedCount = 0
            var photoCount = 0
            var campaignIds = Set<String>()

            for doc in docs {
                let d = doc.data()

                lives += NgoRewardsMetrics.intValue(d["livesImpacted"])
                if lives == 0 { lives += NgoRewardsMetrics.intValue(d["livesTouched"]) }
                if lives == 0 { lives += NgoRewardsMetrics.intValue(d["servings"]) }

                if self.boolValue(d["verifiedFoodQuality"]) == true ||
                    self.boolValue(d["foodQualityVerified"]) == true {
                    verifiedCount += 1
                }

                if let arr = d["imageURLs"] as? [String], !arr.isEmpty { photoCount += 1 }
                else if let arr = d["imageUrls"] as? [String], !arr.isEmpty { photoCount += 1 }

                if let c = d["campaignId"] as? String, !c.isEmpty { campaignIds.insert(c) }
            }

            if lives == 0 { lives = successfulPickups }

            var points = 0
            points += successfulPickups * 100
            points += verifiedCount * 50
            if successfulPickups >= 10 { points += 200 }
            points += photoCount * 30
            points += campaignIds.count * 100

            let tier = NgoTier.from(points: points)

            let userRef = self.db.collection("users").document(uid)
            userRef.setData([
                "rewardsNgo": [
                    "successfulPickups": successfulPickups,
                    "livesImpacted": lives,
                    "points": points,
                    "tierTitle": tier.title,
                    "campaignsSupported": campaignIds.count,
                    "updatedAt": FieldValue.serverTimestamp()
                ]
            ], merge: true)
        }
    }

    private func boolValue(_ any: Any?) -> Bool? {
        if let b = any as? Bool { return b }
        if let n = any as? NSNumber { return n.boolValue }
        if let s = any as? String {
            let x = s.lowercased()
            if x == "true" || x == "yes" || x == "1" { return true }
            if x == "false" || x == "no" || x == "0" { return false }
        }
        return nil
    }
}

// MARK: - Collection
extension RewardsNgoViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badges.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BadgeCardCell.reuseId,
            for: indexPath
        ) as! BadgeCardCell

        let badge = badges[indexPath.item]
        let bgColor = color(fromHex: badge.colorHex)

        cell.configure(
            title: badge.title,
            subtitle: badge.subtitle,
            iconName: badge.iconName,
            bgColor: bgColor
        )

        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - Helpers

private struct NgoRewardsMetrics {
    var successfulPickups: Int = 0
    var livesImpacted: Int = 0
    var points: Int = 0
    var tierTitle: String = "Reliable NGO"

    init() {}

    init(dict: [String: Any]) {
        successfulPickups = Self.intValue(dict["successfulPickups"])
        livesImpacted = Self.intValue(dict["livesImpacted"])
        points = Self.intValue(dict["points"])
        tierTitle = (dict["tierTitle"] as? String) ?? NgoTier.from(points: points).title
    }

    static func defaultFirestoreDict() -> [String: Any] {
        [
            "successfulPickups": 0,
            "livesImpacted": 0,
            "points": 0,
            "tierTitle": "Reliable NGO"
        ]
    }

    static func intValue(_ any: Any?) -> Int {
        if let i = any as? Int { return i }
        if let d = any as? Double { return Int(d) }
        if let n = any as? NSNumber { return n.intValue }
        if let s = any as? String { return Int(s.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0 }
        return 0
    }
}

private enum NgoTier {
    case starter, silver, gold, diamond

    static func from(points: Int) -> NgoTier {
        switch points {
        case 0..<500: return .starter
        case 500..<1500: return .silver
        case 1500..<2500: return .gold
        default: return .diamond
        }
    }

    var title: String {
        switch self {
        case .starter: return "Reliable NGO"
        case .silver:  return "Silver Partner"
        case .gold:    return "Gold Partner"
        case .diamond: return "Diamond Partner"
        }
    }

    var medalAssetName: String {
        switch self {
        case .starter: return "tier_starter"
        case .silver:  return "tier_silver"
        case .gold:    return "tier_gold"
        case .diamond: return "tier_diamond"
        }
    }
}
