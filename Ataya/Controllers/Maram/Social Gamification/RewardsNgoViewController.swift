//
//  RewardsNgoViewController.swift
//  Ataya
//
//  Created by Maram on 19/12/2025.
//

import UIKit

final class RewardsNgoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var badgesCollectionView: UICollectionView!

    private let badgeCardHexColors = [
        "#fff8ed",
        "#FBF9FF",
        "#F6FCF3",
        "#fffbfb"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBadges()
    }

    // ✅ ADDED: dynamic sizing after AutoLayout (same as RewardsViewController)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBadgesItemSizeIfNeeded()
    }

    // ✅ ADDED: keep exact size stable
    private func updateBadgesItemSizeIfNeeded() {
        guard let layout = badgesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let newSize = CGSize(width: 104, height: 194) // ✅ EXACT
        if layout.itemSize != newSize {
            layout.itemSize = newSize
            layout.invalidateLayout()
        }
    }

    private func setupBadges() {
        badgesCollectionView.register(
            UINib(nibName: "BadgeCardCell", bundle: nil),
            forCellWithReuseIdentifier: BadgeCardCell.reuseId
        )

        badgesCollectionView.dataSource = self
        badgesCollectionView.delegate = self

        // ✅ Horizontal carousel layout (same style)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 18
        layout.minimumInteritemSpacing = 0

        // ✅ Peek
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

        // ✅ temporary size (final set in viewDidLayoutSubviews)
        layout.itemSize = CGSize(width: 104, height: 194)

        badgesCollectionView.collectionViewLayout = layout

        badgesCollectionView.showsHorizontalScrollIndicator = false
        badgesCollectionView.alwaysBounceHorizontal = true
        badgesCollectionView.backgroundColor = .clear

        // ✅ important for shadow
        badgesCollectionView.clipsToBounds = false
        badgesCollectionView.layer.masksToBounds = false

        // ✅ smoother carousel feel
        badgesCollectionView.decelerationRate = .fast
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BadgeCardCell.reuseId,
            for: indexPath
        ) as! BadgeCardCell

        // ✅ background color per card (pass into configure)
        let hex = badgeCardHexColors[indexPath.item % badgeCardHexColors.count]
        let bgColor = UIColor(hex: hex)

        switch indexPath.item {
        case 0:
            cell.configure(
                title: "Gold Heart",
                subtitle: "Donated 10+ times",
                iconName: "Heart",     // ✅ put this image in Assets
                bgColor: bgColor
            )

        case 1:
            cell.configure(
                title: "Meal Hero",
                subtitle: "Provided 100+ meals",
                iconName: "meal",
                bgColor: bgColor
            )

        case 2:
            cell.configure(
                title: "Community Helper",
                subtitle: "Supported 3 campaigns",
                iconName: "community",
                bgColor: bgColor
            )

        default:
            cell.configure(
                title: "Gold Donor",
                subtitle: "Donated to international causes",
                iconName: "last",
                bgColor: bgColor
            )
        }

        // ✅ keep outside clear for shadow
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear

        return cell
    }
}
