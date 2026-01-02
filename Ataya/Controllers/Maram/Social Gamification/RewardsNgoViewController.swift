import UIKit
import FirebaseAuth
import FirebaseFirestore

final class RewardsNgoViewController: UIViewController {

    @IBOutlet weak var badgesCollectionView: UICollectionView!
    @IBOutlet weak var pickupsLabel: UILabel!
    @IBOutlet weak var livesLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var tierLabel: UILabel?
    @IBOutlet weak var tierMedalImageView: UIImageView?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private var metrics = NgoRewardsMetrics()

    // ✅ throttle مثل الدونر
    private var isRecomputing = false
    private var lastRecomputeAt: Date = .distantPast

    private struct BadgeVM {
        let title: String
        let subtitle: String
        let iconName: String
        let colorHex: String
    }

    private let defaultBadges: [BadgeVM] = [
        .init(title: "Fast Responder", subtitle: "Accepted pickups quickly", iconName: "Heart", colorHex: "#fff8ed"),
        .init(title: "Meal Hero", subtitle: "Handled donations safely", iconName: "meal", colorHex: "#FBF9FF"),
        .init(title: "Community Helper", subtitle: "Supported 3 campaigns", iconName: "community", colorHex: "#F6FCF3"),
        .init(title: "Trusted Partner", subtitle: "Maintained high reliability", iconName: "last", colorHex: "#fffbfb")
    ]

    private var badges: [BadgeVM] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBadges()
        applyInitialUI()

        ensureNgoRewardsDocSeededIfNeeded()
        startListeningNgoRewards()

        // ✅ يحسب ويكتب كل مرة (مثل الدونر)
        recomputeNgoRewardsNowIfAllowed()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recomputeNgoRewardsNowIfAllowed()
    }

    deinit { listener?.remove() }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBadgesItemSizeIfNeeded()
    }

    private func applyInitialUI() {
        // إذا تبين 0 بدل —
        pickupsLabel.text = "0 Successful Pickups"
        livesLabel.text = "0 Lives Impacted"
        pointsLabel.text = "0 pts"

        let tier = NgoTier.from(points: 0)
        tierLabel?.text = tier.title
        tierMedalImageView?.image = UIImage(named: tier.medalAssetName)

        badges = defaultBadges
        badgesCollectionView.reloadData()
    }

    // MARK: - Badges
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
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layout.itemSize = CGSize(width: 130, height: 190)

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

    // MARK: - ✅ Firestore: rewardsNgo/{uid}

    private func ensureNgoRewardsDocSeededIfNeeded() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = db.collection("rewardsNgo").document(uid)

        ref.getDocument { doc, _ in
            if let doc, doc.exists { return }
            ref.setData(NgoRewardsMetrics.defaultFirestoreDict(), merge: true)
        }
    }

    private func startListeningNgoRewards() {
        guard let uid = Auth.auth().currentUser?.uid else {
            applyInitialUI()
            return
        }

        let ref = db.collection("rewardsNgo").document(uid)
        listener?.remove()

        listener = ref.addSnapshotListener { [weak self] snap, err in
            guard let self else { return }

            if let err {
                print("❌ NGO rewards listen error:", err.localizedDescription)
                return
            }

            guard let data = snap?.data(), snap?.exists == true else {
                self.applyInitialUI()
                return
            }

            self.metrics = NgoRewardsMetrics(dict: data)

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

    // MARK: - ✅ Recompute (مثل الدونر)

    private func recomputeNgoRewardsNowIfAllowed() {
        guard Auth.auth().currentUser != nil else { return }

        let now = Date()
        if isRecomputing { return }
        if now.timeIntervalSince(lastRecomputeAt) < 5 { return }

        isRecomputing = true
        lastRecomputeAt = now

        NgoRewardsSyncService.shared.recomputeAndSaveCurrentNgo { [weak self] err in
            guard let self else { return }
            self.isRecomputing = false
            if let err {
                print("❌ NGO recompute error:", err.localizedDescription)
            } else {
                print("✅ NGO rewards recomputed & saved")
            }
        }
    }
}

extension RewardsNgoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { badges.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgeCardCell.reuseId, for: indexPath) as! BadgeCardCell
        let b = badges[indexPath.item]
        cell.configure(title: b.title, subtitle: b.subtitle, iconName: b.iconName, bgColor: UIColor(hex: b.colorHex))
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - Models

private struct NgoRewardsMetrics {
    var successfulPickups: Int = 0
    var livesImpacted: Int = 0
    var points: Int = 0

    init() {}

    init(dict: [String: Any]) {
        successfulPickups = Self.intValue(dict["successfulPickups"])
        livesImpacted = Self.intValue(dict["livesImpacted"])
        points = Self.intValue(dict["points"])
    }

    static func defaultFirestoreDict() -> [String: Any] {
        [
            "successfulPickups": 0,
            "livesImpacted": 0,
            "points": 0,
            "updatedAt": FieldValue.serverTimestamp()
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
