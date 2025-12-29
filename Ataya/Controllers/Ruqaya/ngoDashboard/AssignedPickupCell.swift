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
    
        
    @IBOutlet weak var donorLabel: UILabel!
    

    
    @IBOutlet weak var locationLabel: UILabel!
    
    
    @IBOutlet private weak var statusContainerView: UIView!
    @IBOutlet private weak var statusLabel: UILabel!
    
    private let radius: CGFloat = 24
    
    override func awakeFromNib() {
            super.awakeFromNib()

            backgroundColor = .clear
            contentView.backgroundColor = .clear
            selectionStyle = .none

            // ===== Card =====
            cardView.backgroundColor = .white
            cardView.layer.cornerRadius = radius
            cardView.layer.borderWidth = 1
            cardView.layer.borderColor = UIColor.systemGray4.cgColor
            cardView.clipsToBounds = true

            // ===== Image =====
            productImageView.layer.cornerRadius = 12
            productImageView.clipsToBounds = true
            productImageView.contentMode = .scaleAspectFill

            // ===== Text =====
            titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)

            donorLabel.font = .systemFont(ofSize: 16, weight: .regular)
            donorLabel.textColor = .systemGray

            locationLabel.font = .systemFont(ofSize: 16, weight: .regular)
            locationLabel.textColor = .systemGray

            // ===== Upcoming Badge =====
            statusContainerView.layer.cornerRadius = 15
            statusContainerView.clipsToBounds = true
            statusContainerView.backgroundColor = UIColor(red: 255/255,
                                                          green: 251/255,
                                                          blue: 204/255,
                                                          alpha: 1) // FFFBCC

            statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
            statusLabel.textAlignment = .center

        }

        func configure(with item: AssignedPickupItem) {
            titleLabel.text = item.title
            donorLabel.text = item.donor
            locationLabel.text = item.location
            statusLabel.text = item.status
            productImageView.image = UIImage(named: item.imageName)
        }
}
