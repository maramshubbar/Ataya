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

    private func setupBadges() {
        badgesCollectionView.register(
            UINib(nibName: "BadgeCardCell", bundle: nil),
            forCellWithReuseIdentifier: BadgeCardCell.reuseId
        )

        badgesCollectionView.dataSource = self
        badgesCollectionView.delegate = self

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.itemSize = CGSize(width: 104, height: 194)

        badgesCollectionView.collectionViewLayout = layout

        badgesCollectionView.showsHorizontalScrollIndicator = false
        badgesCollectionView.alwaysBounceHorizontal = true
        badgesCollectionView.backgroundColor = .clear
        badgesCollectionView.clipsToBounds = false
        badgesCollectionView.layer.masksToBounds = false
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4 // change to 3 if you want only 3 cards
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BadgeCardCell.reuseId,
            for: indexPath
        ) as! BadgeCardCell

        switch indexPath.item {
        case 0:
            cell.configure(title: "Gold Heart",
                           subtitle: "Donated 10+ times",
                           icon: UIImage(systemName: "heart.fill"))

        case 1:
            cell.configure(title: "Meal Hero",
                           subtitle: "Provided 100+ meals",
                           icon: UIImage(named: "meal")?.withRenderingMode(.alwaysOriginal))

        case 2:
            cell.configure(title: "Community Helper",
                           subtitle: "Supported 3 campaigns",
                           icon: UIImage(named: "community")?.withRenderingMode(.alwaysOriginal))

        default:
            cell.configure(title: "Gold Donor",
                           subtitle: "Donated to international causes",
                           icon: UIImage(named: "last")?.withRenderingMode(.alwaysOriginal))
        }

        let hex = badgeCardHexColors[indexPath.item % badgeCardHexColors.count]
        cell.contentView.backgroundColor = UIColor(hex: hex)

        return cell
    }
}
