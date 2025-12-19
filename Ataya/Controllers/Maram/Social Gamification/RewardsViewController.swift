//
//  RewardsViewController.swift
//  Ataya
//
//  Created by Maram on 18/12/2025.


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
        badgesCollectionView.clipsToBounds = false
        badgesCollectionView.layer.masksToBounds = false

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
                           icon: UIImage(systemName: "heart.fill"))   // ✅ نفس ما هي

        case 1:
            cell.configure(title: "Meal Hero",
                           subtitle: "Provided 100+ meals",
                           icon: UIImage(named: "meal")?.withRenderingMode(.alwaysOriginal))

        case 2:
            cell.configure(title: "Community Helper",
                           subtitle: "Supported 3 campaigns",
                           icon: UIImage(named: "community")?.withRenderingMode(.alwaysOriginal))

        default: // ✅ الكارد الرابع
            cell.configure(title: "Gold Donor",
                           subtitle: "Donated to international causes",
                           icon: UIImage(named: "last")?.withRenderingMode(.alwaysOriginal))
        }


        // ✅ ADDED: set background color per card
        let hex = badgeCardHexColors[indexPath.item % badgeCardHexColors.count]
        cell.contentView.backgroundColor = UIColor(hex: hex)

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
