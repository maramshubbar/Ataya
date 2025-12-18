//
//  RewardsViewController.swift
//  Ataya
//
//  Created by Maram on 18/12/2025.
//

import UIKit

final class RewardsViewController: UIViewController {

    @IBOutlet weak var badgesCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBadges()
    }

    private func setupBadges() {
        // ✅ Register XIB cell
        badgesCollectionView.register(
            UINib(nibName: "BadgeCardCell", bundle: nil),
            forCellWithReuseIdentifier: BadgeCardCell.reuseId
        )

        badgesCollectionView.dataSource = self
        badgesCollectionView.delegate = self

        // ✅ Horizontal layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.itemSize = CGSize(width: 104, height: 194)   // ✅ مثل التصميم

        badgesCollectionView.collectionViewLayout = layout

        badgesCollectionView.showsHorizontalScrollIndicator = false
        badgesCollectionView.alwaysBounceHorizontal = true
        badgesCollectionView.backgroundColor = .clear
    }
}

extension RewardsViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
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
                           icon: UIImage(systemName: "takeoutbag.and.cup.and.straw.fill"))

        case 2:
            cell.configure(title: "Community Helper",
                           subtitle: "Supported 3 campaigns",
                           icon: UIImage(systemName: "person.3.fill"))

        default: // ✅ الكارد الرابع
            cell.configure(title: "Gold Donor",
                           subtitle: "12 successful donations",
                           icon: UIImage(systemName: "star.fill"))
        }

        return cell
    }
}


