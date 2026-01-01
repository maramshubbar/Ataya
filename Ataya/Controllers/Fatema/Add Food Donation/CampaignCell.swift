//
//  CampaignCell.swift
//  Ataya
//
//  Created by Fatema Maitham on 19/12/2025.
//

import UIKit

final class CampaignCell: UICollectionViewCell {

    static let reuseId = "CampaignCell"
    private let baseShadowOpacity: Float = 0.08

    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var imgCampaign: UIImageView!
    @IBOutlet private weak var badgeLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!

    private let radius: CGFloat = 24

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        clipsToBounds = false
        contentView.clipsToBounds = false
        
        // Card (clips for rounded image corners)
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = radius
        cardView.clipsToBounds = true
        cardView.layer.borderWidth = 0
        cardView.layer.borderColor = UIColor.clear.cgColor

        // Shadow (must NOT clip)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.06
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowView.layer.shadowRadius = 8
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale


        // Badge pill
        badgeLabel.backgroundColor = UIColor(red: 246/255, green: 108/255, blue: 98/255, alpha: 1) // #F66C62
        badgeLabel.textColor = .white
        badgeLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        badgeLabel.layer.cornerRadius = 12
        badgeLabel.clipsToBounds = true
        badgeLabel.textAlignment = .center
        badgeLabel.numberOfLines = 1


        // Title
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
            let path = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: radius)
            shadowView.layer.shadowPath = path.cgPath
    }

    override var isHighlighted: Bool {
        didSet {
            contentView.alpha = 1.0

            shadowView.layer.shadowOpacity = baseShadowOpacity
        }
    }
    func configure(with item: Campaign) {
        imgCampaign.image = UIImage(named: item.imageName)
        badgeLabel.text = item.tag
        titleLabel.text = item.title
    }
}
