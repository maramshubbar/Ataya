//
//  CampaignCellCollectionViewCell.swift
//  Ataya
//
//  Created by Fatema Maitham on 17/12/2025.
//

import UIKit

final class CampaignCell: UICollectionViewCell {

    static let reuseId = "CampaignCell"

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var imgCampaign: UIImageView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    
    private let radius: CGFloat = 18

        override func awakeFromNib() {
            super.awakeFromNib()

            
            guard shadowView != nil, cardView != nil, imgCampaign != nil, badgeLabel != nil, titleLabel != nil else {
                print("❌ CampaignCell outlets not connected")
                return
            }

            
            // Make cell transparent
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            contentView.clipsToBounds = false

            // ---- Rounded card (clips) ----
            cardView.layer.cornerRadius = radius
            cardView.clipsToBounds = true

            // ---- Image ----
            imgCampaign.contentMode = .scaleAspectFill
            imgCampaign.clipsToBounds = true
            imgCampaign.layer.cornerRadius = radius
            imgCampaign.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // top corners only

            // ---- Title: 2 lines ----
            titleLabel.numberOfLines = 2
            titleLabel.lineBreakMode = .byWordWrapping
            titleLabel.textAlignment = .center

            // ---- Badge (pill) ----
            badgeLabel.clipsToBounds = true
            badgeLabel.layer.cornerRadius = 10

            // ---- Shadow on OUTER view (does not clip) ----
            shadowView.backgroundColor = .clear
            shadowView.layer.cornerRadius = radius
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOpacity = 0.12
            shadowView.layer.shadowRadius = 12
            shadowView.layer.shadowOffset = CGSize(width: 0, height: 6)
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            // Keep shadow smooth + same rounded shape
            shadowView.layer.shadowPath = UIBezierPath(
                roundedRect: shadowView.bounds,
                cornerRadius: radius
            ).cgPath
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            imgCampaign.image = nil
            badgeLabel.text = nil
            titleLabel.text = nil
        }

        // MARK: - Configure
        func configure(imageName: String, tag: String, title: String) {
            imgCampaign.image = UIImage(named: imageName)
            badgeLabel.text = tag
            titleLabel.text = title
        }
    }
