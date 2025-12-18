//
//  DonationCell.swift
//  Ataya
//
//  Created by Fatema Maitham on 01/12/2025.
//

import UIKit

class DonationCell: UITableViewCell {
//    @IBOutlet weak var shadowView: UIView!
//    @IBOutlet weak var cardView: RoundedCardView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var donorLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusContainerView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var detailsButton: UIButton!
    
    override func awakeFromNib() {
            super.awakeFromNib()

            // ✅ make cell background transparent like Report cards
            backgroundColor = .clear
            contentView.backgroundColor = .clear

            // ✅ RoundedCardView handles radius+border (from Inspectables)
            // Just ensure your defaults match Report:
            cardView.cornerRadius = 15
            cardView.borderWidth = 1
            cardView.borderColor = UIColor.lightGray.withAlphaComponent(0.6)

            // ✅ Shadow on OUTER view (must not clip)
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOpacity = 0.12
            shadowView.layer.shadowRadius = 12
            shadowView.layer.shadowOffset = CGSize(width: 0, height: 6)
            shadowView.layer.masksToBounds = false

            // ✅ Status badge
            statusContainerView.layer.cornerRadius = 12
            statusContainerView.layer.masksToBounds = true

            // ✅ Button centered
            detailsButton.titleLabel?.textAlignment = .center
        }
    }
