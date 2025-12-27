//
//  OngoingDonationCell.swift
//  Ataya
//
//  Created by Fatema Maitham on 19/12/2025.
//

import UIKit

struct AssignedPickupItem {
    let title: String
    let donor: String
    let location: String
    let status: String
    let imageName: String
}



final class AssignedPickupCell: UITableViewCell {
    static let reuseId = "AssignedPickupCell"
    
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var productImageView: UIImageView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var donorLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    
    
    @IBOutlet private weak var statusContainerView: UIView!
    @IBOutlet private weak var statusLabel: UILabel!
    
    private let radius: CGFloat = 24
    private var statusWidthConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
            super.awakeFromNib()

            backgroundColor = .clear
            contentView.backgroundColor = .clear
            selectionStyle = .none

            // Shadow
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOpacity = 0.06
            shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
            shadowView.layer.shadowRadius = 8
            shadowView.layer.shouldRasterize = true
            shadowView.layer.rasterizationScale = UIScreen.main.scale

            // Card
            cardView.backgroundColor = .white
            cardView.layer.cornerRadius = radius
            cardView.clipsToBounds = true
            cardView.layer.borderWidth = 1
            cardView.layer.borderColor = UIColor.systemGray4.cgColor

            // Image
            productImageView.layer.cornerRadius = 12
            productImageView.clipsToBounds = true

            // Text
            titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
            donorLabel.font = .systemFont(ofSize: 16, weight: .regular)
            donorLabel.textColor = .systemGray
            locationLabel.font = .systemFont(ofSize: 16, weight: .regular)
            locationLabel.textColor = .systemGray

            // Badge
            statusContainerView.layer.cornerRadius = 15
            statusContainerView.clipsToBounds = true
            statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
            statusLabel.textAlignment = .center
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: radius).cgPath
            updateStatusPillWidth()
        }

        private func updateStatusPillWidth() {
            statusLabel.layoutIfNeeded()
            let padding: CGFloat = 28
            let maxWidth = contentView.bounds.width * 0.42
            let targetWidth = min(statusLabel.intrinsicContentSize.width + padding, maxWidth)

            if statusWidthConstraint == nil {
                let c = statusContainerView.widthAnchor.constraint(equalToConstant: targetWidth)
                c.priority = .required
                c.isActive = true
                statusWidthConstraint = c
            } else {
                statusWidthConstraint?.constant = targetWidth
            }
        }

        func configure(with item: AssignedPickupItem) {
            titleLabel.text = item.title
            donorLabel.text = item.donor
            locationLabel.text = item.location
            statusLabel.text = item.status
            productImageView.image = UIImage(named: item.imageName)

            // Upcoming style (مثل الفقما)
            statusContainerView.backgroundColor = UIColor(red: 252/255, green: 246/255, blue: 201/255, alpha: 1)

            setNeedsLayout()
        }

}
