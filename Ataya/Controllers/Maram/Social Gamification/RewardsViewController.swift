//
//  RewardsViewController.swift
//  Ataya
//
//  Created by Maram on 18/12/2025.
//

import UIKit

final class RewardsViewController: UIViewController {

    @IBOutlet weak var badgesCollectionView: UICollectionView!

    // ✅ ADDED: connect your 3 row views here (Outlet Collection)
    @IBOutlet var rewardRowViews: [UIView]!

    // ✅ ADDED: connect Available/Locked buttons here (Outlet Collection)
    @IBOutlet var statusPillButtons: [UIButton]!

    // ✅ ADDED: badge card background colors
    private let badgeCardHexColors = [
        //"#E5E5E5",
        "#fff8ed",
        "#FBF9FF",
        "#F6FCF3",
        "#fffbfb"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBadges()

        // ✅ ADDED
        styleRewardsUI()
    }

    // ✅ ADDED (NEW): dynamic sizing after AutoLayout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBadgesItemSizeIfNeeded()
    }

    // ✅ ADDED (NEW): makes carousel show a “peek” of next card
    private func updateBadgesItemSizeIfNeeded() {
        guard let layout = badgesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let newSize = CGSize(width: 130, height: 190)   // ✅ EXACT size you want
        if layout.itemSize != newSize {
            layout.itemSize = newSize
            layout.invalidateLayout()
        }
    }


    // ✅ ADDED
    private func styleRewardsUI() {
        let borderColor = UIColor(hex: "#F7D44C")

        // 3 row views: border + radius 8
        rewardRowViews.forEach { v in
            v.layer.borderWidth = 1
            v.layer.borderColor = borderColor.cgColor
            v.layer.cornerRadius = 8
            v.clipsToBounds = true
        }

        // Available/Locked buttons: radius 4
        statusPillButtons.forEach { b in
            b.layer.cornerRadius = 4
            b.clipsToBounds = true
        }
    }

    private func setupBadges() {
        // ✅ Register XIB cell
        badgesCollectionView.register(
            UINib(nibName: "BadgeCardCell", bundle: nil),
            forCellWithReuseIdentifier: BadgeCardCell.reuseId
        )

        badgesCollectionView.dataSource = self
        badgesCollectionView.delegate = self

        // ✅ Horizontal layout (carousel)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 18
        layout.minimumInteritemSpacing = 0

        // ✅ Peek (shows a bit of the next card)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

        // ✅ temporary size (final size will be set in viewDidLayoutSubviews)
        let newSize = CGSize(width: 130, height: 220)
            // ✅ EXACT

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

        // ✅ background color per card (now passed into configure)
        let hex = badgeCardHexColors[indexPath.item % badgeCardHexColors.count]
        let bgColor = UIColor(hex: hex)

        switch indexPath.item {
        case 0:
            cell.configure(
                title: "Gold Heart",
                subtitle: "Donated 10+ times",
                iconName: "Heart",          // ✅ اسم الصورة في Assets
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

        // keep cell clear around the card (for shadow)
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear

        return cell
    }
}

// ✅ ADDED: Hex color helper
extension UIColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h.removeFirst() }
        if h.count == 6 { h += "FF" } // add alpha
        var v: UInt64 = 0
        Scanner(string: h).scanHexInt64(&v)

        let r = CGFloat((v & 0xFF000000) >> 24) / 255
        let g = CGFloat((v & 0x00FF0000) >> 16) / 255
        let b = CGFloat((v & 0x0000FF00) >> 8) / 255
        let a = CGFloat(v & 0x000000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
