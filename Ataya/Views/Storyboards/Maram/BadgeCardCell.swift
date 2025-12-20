//
//  BadgeCardCell.swift
//  Ataya
//
//  Created by Maram on 20/12/2025.
//

import UIKit

final class BadgeCardCell: UICollectionViewCell {

    static let reuseId = "BadgeCardCell"

    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    private let corner: CGFloat = 24

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // IMPORTANT: Don't clip shadows
        clipsToBounds = false
        contentView.clipsToBounds = false
        shadowView.clipsToBounds = false

        // Card (rounded + keeps content inside)
        cardView.layer.cornerRadius = corner
        cardView.clipsToBounds = true

        // Shadow (soft + bottom like your design)
        shadowView.backgroundColor = .clear
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.08
        shadowView.layer.shadowRadius = 8
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 12)

        // smoother + faster shadow rendering
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Move the shadow slightly DOWN so it looks like "bottom shadow"
        let shadowRect = shadowView.bounds.offsetBy(dx: 0, dy: 2)

        shadowView.layer.shadowPath = UIBezierPath(
            roundedRect: shadowRect,
            cornerRadius: corner
        ).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    func configure(title: String, subtitle: String, iconName: String, bgColor: UIColor) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconImageView.image = UIImage(named: iconName)
        cardView.backgroundColor = bgColor
    }
}
