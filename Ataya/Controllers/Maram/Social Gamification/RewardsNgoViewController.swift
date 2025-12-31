//
//  RewardsNgoViewController.swift
//  Ataya
//
//  Created by Maram on 19/12/2025.
//




import UIKit
import FirebaseAuth
import FirebaseFirestore

final class RewardsNgoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - Outlets (اربطّيهم من الـ storyboard)
    @IBOutlet weak var badgesCollectionView: UICollectionView!

    @IBOutlet weak var pickupsLabel: UILabel!
    @IBOutlet weak var livesLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!

    // MARK: - Firestore
    private let db = Firestore.firestore()

    // MARK: - Badge VM
    private struct BadgeVM {
        let title: String
        let subtitle: String
        let iconName: String
        let colorHex: String
    }

    // Default badges (إذا ما موجودة في Firebase)
    private let defaultBadges: [BadgeVM] = [
        .init(title: "Fast Responder", subtitle: "Accepted pickups quickly", iconName: "Heart", colorHex: "#fff8ed"),
        .init(title: "Meal Hero", subtitle: "Handled donations safely", iconName: "meal", colorHex: "#FBF9FF"),
        .init(title: "Community Helper", subtitle: "Supported 3 campaigns", iconName: "community", colorHex: "#F6FCF3"),
        .init(title: "Trusted Partner", subtitle: "Maintained high reliability", iconName: "last", colorHex: "#fffbfb")
    ]

    private var badges: [BadgeVM] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBadges()
        applyInitialPlaceholders()

        // ✅ (اختياري) إذا تبين تثبتين لون النقاط فقط بدون تغيير الحجم:
        // pointsLabel.textColor = UIColor(red: 255/255, green: 216/255, blue: 63/255, alpha: 1) // #FFD83F

        fetchNgoRewards()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBadgesItemSizeIfNeeded()
    }

    private func applyInitialPlaceholders() {
        // عشان ما تظهر نصوص مثل donationsLabel...
        pickupsLabel.text = ""
        livesLabel.text = ""
        pointsLabel.text = ""

        badges = defaultBadges
        badgesCollectionView.reloadData()
    }

    // MARK: - Badges Collection Layout

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
        layout.itemSize = CGSize(width: 104, height: 194) // temporary

        badgesCollectionView.collectionViewLayout = layout
        badgesCollectionView.showsHorizontalScrollIndicator = false
        badgesCollectionView.alwaysBounceHorizontal = true
        badgesCollectionView.backgroundColor = .clear

        // shadows
        badgesCollectionView.clipsToBounds = false
        badgesCollectionView.layer.masksToBounds = false

        // smooth
        badgesCollectionView.decelerationRate = .fast
    }

    private func updateBadgesItemSizeIfNeeded() {
        guard let layout = badgesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let newSize = CGSize(width: 130, height: 190) // ✅ EXACT
        if layout.itemSize != newSize {
            layout.itemSize = newSize
            layout.invalidateLayout()
        }
    }

    // MARK: - Firebase Fetch (NGO Rewards)

    private func fetchNgoRewards() {
        guard let uid = Auth.auth().currentUser?.uid else {
            pickupsLabel.text = "—"
            livesLabel.text = "—"
            pointsLabel.text = "—"
            badges = defaultBadges
            badgesCollectionView.reloadData()
            return
        }

        db.collection("ngos").document(uid).getDocument { [weak self] snap, err in
            guard let self = self else { return }

            if let err = err {
                DispatchQueue.main.async {
                    self.pickupsLabel.text = "Failed to load"
                    self.livesLabel.text = err.localizedDescription
                    self.pointsLabel.text = ""
                    self.badges = self.defaultBadges
                    self.badgesCollectionView.reloadData()
                }
                return
            }

            let data = snap?.data() ?? [:]

            let tierTitle = data["tierTitle"] as? String ?? ""
            let successfulPickups = data["successfulPickups"] as? Int ?? 0
            let livesImpacted = data["livesImpacted"] as? Int ?? 0
            let points = data["points"] as? Int ?? 0

            let pointsFormatted = NumberFormatter.localizedString(from: points as NSNumber, number: .decimal)

            // badges optional
            let badgesArray = data["badges"] as? [[String: Any]] ?? []
            let parsedBadges: [BadgeVM] = badgesArray.compactMap { item in
                guard
                    let title = item["title"] as? String,
                    let subtitle = item["subtitle"] as? String,
                    let iconName = item["iconName"] as? String,
                    let colorHex = item["colorHex"] as? String
                else { return nil }
                return BadgeVM(title: title, subtitle: subtitle, iconName: iconName, colorHex: colorHex)
            }

            DispatchQueue.main.async {
                // ✅ ترتيب النصوص مثل فيقما (بدون تغيير أحجام الخط)
                self.pickupsLabel.text = "\(successfulPickups) Successful Pickups"
                self.livesLabel.text = "\(livesImpacted) Lives Impacted"
                self.pointsLabel.text = "\(pointsFormatted) pts"

                self.badges = parsedBadges.isEmpty ? self.defaultBadges : parsedBadges
                self.badgesCollectionView.reloadData()
            }
        }
    }

    // MARK: - UICollectionViewDataSource

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
        let bgColor = UIColor(hex: badge.colorHex) // لازم extension UIColor(hex:)

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
