//
//  RewardsViewController.swift
//  Ataya
//
//  Created by Maram on 18/12/2025.
//
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

final class RewardsViewController: UIViewController {

    @IBOutlet weak var badgesCollectionView: UICollectionView!

    // ✅ لازم تربطينهم من الستوريبورد
    @IBOutlet weak var donationsLabel: UILabel?
    @IBOutlet weak var livesLabel: UILabel?
    @IBOutlet weak var pointsLabel: UILabel?
    @IBOutlet weak var tierLabel: UILabel?

    // ✅ اربطي صورة الميدالية الكبيرة اللي فوق
    @IBOutlet weak var tierMedalImageView: UIImageView?

    // ✅ Outlet Collections
    @IBOutlet var rewardRowViews: [UIView]!
    // IMPORTANT order: [Coupon, Certificate, Booster]
    @IBOutlet var statusPillButtons: [UIButton]!

    // MARK: - Firebase
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // MARK: - Rewards cache
    private var metrics = RewardsMetrics()

    // ✅ throttle عشان ما يعيد يحسب كل شوي
    private var isRecomputing = false
    private var lastRecomputeAt: Date = .distantPast

    private let badgeCardHexColors = [
        "#fff8ed", "#FBF9FF", "#F6FCF3", "#fffbfb"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBadges()
        styleRewardsUI()

        ensureRewardsSeededIfNeeded()
        startListeningToRewards()

        // ✅ احسب مرة أول ما تفتح الصفحة
        recomputeRewardsNowIfAllowed()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // ✅ إذا رجعتي للصفحة بعد تبرع، يحسب مرة ثانية
        recomputeRewardsNowIfAllowed()
    }

    deinit { listener?.remove() }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBadgesItemSizeIfNeeded()
    }

    private func updateBadgesItemSizeIfNeeded() {
        guard let layout = badgesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let newSize = CGSize(width: 130, height: 190)
        if layout.itemSize != newSize {
            layout.itemSize = newSize
            layout.invalidateLayout()
        }
    }

    private func styleRewardsUI() {
        let borderColor = UIColor(hex: "#F7D44C")

        rewardRowViews.forEach { v in
            v.layer.borderWidth = 1
            v.layer.borderColor = borderColor.cgColor
            v.layer.cornerRadius = 8
            v.clipsToBounds = true
        }

        statusPillButtons.forEach { b in
            b.layer.cornerRadius = 4
            b.clipsToBounds = true
        }
    }

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

        badgesCollectionView.collectionViewLayout = layout
        badgesCollectionView.showsHorizontalScrollIndicator = false
        badgesCollectionView.alwaysBounceHorizontal = true
        badgesCollectionView.backgroundColor = .clear
        badgesCollectionView.clipsToBounds = false
        badgesCollectionView.layer.masksToBounds = false
        badgesCollectionView.decelerationRate = .fast
    }

    // MARK: - Firebase (users/{uid}.rewards)

    private func ensureRewardsSeededIfNeeded() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { snap, _ in
            guard let snap, snap.exists else { return }
            let rewards = snap.data()?["rewards"] as? [String: Any]
            if rewards != nil { return }

            userRef.setData([
                "rewards": RewardsMetrics.defaultFirestoreDict()
            ], merge: true)
        }
    }

    private func startListeningToRewards() {
        guard let uid = Auth.auth().currentUser?.uid else {
            applyPlaceholders()
            return
        }

        let userRef = db.collection("users").document(uid)

        listener?.remove()
        listener = userRef.addSnapshotListener { [weak self] snap, err in
            guard let self else { return }

            if let err {
                print("❌ Rewards listen error:", err)
                DispatchQueue.main.async { self.applyPlaceholders() }
                return
            }

            let data = snap?.data() ?? [:]
            let rewards = data["rewards"] as? [String: Any] ?? [:]
            self.metrics = RewardsMetrics(dict: rewards)

            DispatchQueue.main.async {
                self.applyRewardsToUI()
                self.badgesCollectionView.reloadData()
            }
        }
    }

    private func applyPlaceholders() {
        donationsLabel?.text = "—"
        livesLabel?.text = "—"
        pointsLabel?.text = "—"
        tierLabel?.text = "—"
        tierMedalImageView?.image = UIImage(named: "tier_starter")
    }

    private func applyRewardsToUI() {
        donationsLabel?.text = "\(metrics.successfulDonations) Successful Donations"
        livesLabel?.text = "\(metrics.livesTouched) Lives Touched"
        pointsLabel?.text = "\(formatNumber(metrics.points)) pts"

        // ✅ خلي التيير + الصورة يعتمدون على النقاط (أضمن من firestore لو فيه غلط)
        let visual = TierVisual.from(points: metrics.points)
        tierLabel?.text = visual.title
        tierMedalImageView?.image = UIImage(named: visual.medalAssetName)

        // ✅ Available/Locked (IMPORTANT order)
        let couponAvailable  = RewardsEngine.isCouponAvailable(points: metrics.points)
        let certAvailable    = RewardsEngine.isCertificateAvailable(points: metrics.points)
        let boosterAvailable = RewardsEngine.isBoosterAvailable(points: metrics.points)

        setPill(statusPillButtons[safe: 0], available: couponAvailable)
        setPill(statusPillButtons[safe: 1], available: certAvailable)
        setPill(statusPillButtons[safe: 2], available: boosterAvailable)
    }

    private func setPill(_ button: UIButton?, available: Bool) {
        guard let button else { return }
        button.setTitle(available ? "Available" : "Locked", for: .normal)
        button.backgroundColor = available ? UIColor(hex: "#F7D44C") : UIColor(hex: "#D9D9D9")
        button.setTitleColor(.black, for: .normal)
    }

    private func formatNumber(_ n: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f.string(from: NSNumber(value: n)) ?? "\(n)"
    }

    // MARK: - ✅ Recompute using RewardsSyncService

    private func recomputeRewardsNowIfAllowed() {
        // لازم تكونين مسجلة دخول
        guard Auth.auth().currentUser != nil else { return }

        // throttle: لا تعيد خلال 5 ثواني
        let now = Date()
        if isRecomputing { return }
        if now.timeIntervalSince(lastRecomputeAt) < 5 { return }

        isRecomputing = true
        lastRecomputeAt = now

        RewardsSyncService.shared.recomputeAndSaveCurrentUser { [weak self] err in
            guard let self else { return }
            self.isRecomputing = false
            if let err {
                print("❌ Rewards recompute error:", err)
            } else {
                print("✅ Rewards recomputed & saved")
            }
        }
    }
}

extension RewardsViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 4 }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BadgeCardCell.reuseId,
            for: indexPath
        ) as! BadgeCardCell

        let hex = badgeCardHexColors[indexPath.item % badgeCardHexColors.count]
        let bgColor = UIColor(hex: hex)

        switch indexPath.item {
        case 0:
            cell.configure(title: "Gold Heart", subtitle: "Donated 10+ times", iconName: "Heart", bgColor: bgColor)
        case 1:
            cell.configure(title: "Meal Hero", subtitle: "Provided 100+ meals", iconName: "meal", bgColor: bgColor)
        case 2:
            cell.configure(title: "Community Helper", subtitle: "Supported 3 campaigns", iconName: "community", bgColor: bgColor)
        default:
            cell.configure(title: "Gold Donor", subtitle: "Donated to international causes", iconName: "last", bgColor: bgColor)
        }

        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - Helpers (no UI changes)

private struct RewardsMetrics {
    var successfulDonations: Int = 0
    var livesTouched: Int = 0
    var points: Int = 0

    init() {}

    init(dict: [String: Any]) {
        successfulDonations = Self.intValue(dict["successfulDonations"])
        livesTouched = Self.intValue(dict["livesTouched"])
        points = Self.intValue(dict["points"])
    }

    static func defaultFirestoreDict() -> [String: Any] {
        [
            "successfulDonations": 0,
            "livesTouched": 0,
            "points": 0,
            "tier": "Starter",
            "campaignsSupported": 0
        ]
    }

    static func intValue(_ any: Any?) -> Int {
        if let i = any as? Int { return i }
        if let d = any as? Double { return Int(d) }
        if let n = any as? NSNumber { return n.intValue }
        if let s = any as? String { return Int(s.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0 } // ✅ مهم
        return 0
    }
}

private struct TierVisual {
    let title: String
    let medalAssetName: String

    static func from(points: Int) -> TierVisual {
        switch points {
        case 0..<500:
            return .init(title: "Starter", medalAssetName: "tier_starter")
        case 500..<1500:
            return .init(title: "Silver Donor", medalAssetName: "tier_silver")
        case 1500..<2500:
            return .init(title: "Gold Donor", medalAssetName: "tier_gold")
        default:
            return .init(title: "Diamond Donor", medalAssetName: "tier_diamond")
        }
    }
}

private enum RewardsEngine {
    static func isCouponAvailable(points: Int) -> Bool { points >= 300 }
    static func isCertificateAvailable(points: Int) -> Bool { points >= 1500 }
    static func isBoosterAvailable(points: Int) -> Bool { points >= 800 }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// ⚠️ إذا عندج نفس extension موجود بملف ثاني، احذفي واحد منهم
extension UIColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h.removeFirst() }
        if h.count == 6 { h += "FF" }
        var v: UInt64 = 0
        Scanner(string: h).scanHexInt64(&v)

        let r = CGFloat((v & 0xFF000000) >> 24) / 255
        let g = CGFloat((v & 0x00FF0000) >> 16) / 255
        let b = CGFloat((v & 0x0000FF00) >> 8) / 255
        let a = CGFloat(v & 0x000000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
