//
//  OngoingDonationCell.swift
//  Ataya
//
//  Created by Fatema Maitham on 19/12/2025.
//

import UIKit

struct OngoingDonationItem {
    let title: String
    let ngoName: String
    let status: String
    let imageName: String
}

final class OngoingDonationCell: UITableViewCell {

    static let reuseId = "OngoingDonationCell"

    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var ngoLabel: UILabel!
    @IBOutlet private weak var statusContainerView: UIView!
    @IBOutlet private weak var statusLabel: UILabel!

    private let radius: CGFloat = 24

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        // Shadow view (NO clipping)
        shadowView.backgroundColor = .clear
        shadowView.layer.cornerRadius = radius
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.10
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 10)
        shadowView.layer.shadowRadius = 14
        shadowView.layer.masksToBounds = false
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale

        // Card view (clips for rounded corners)
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = radius
        cardView.clipsToBounds = true
        cardView.layer.borderWidth = 2

        // Status pill
        statusContainerView.layer.cornerRadius = 15
        statusContainerView.clipsToBounds = true
        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statusLabel.textAlignment = .center

        // Text
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        ngoLabel.font = .systemFont(ofSize: 16, weight: .regular)
        ngoLabel.textColor = .systemGray
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Keep shadow shape matching rounded card
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: radius).cgPath
    }

    func configure(with item: OngoingDonationItem) {
        titleLabel.text = item.title
        ngoLabel.text = item.ngoName
        statusLabel.text = item.status
        productImageView.image = UIImage(named: item.imageName)

        switch item.status {
        case "Ready Pickup":
            cardView.layer.borderColor = UIColor(red: 245/255, green: 206/255, blue: 150/255, alpha: 1).cgColor
            statusContainerView.backgroundColor = UIColor(red: 252/255, green: 236/255, blue: 207/255, alpha: 1)

        case "In Progress":
            cardView.layer.borderColor = UIColor(red: 226/255, green: 240/255, blue: 170/255, alpha: 1).cgColor
            statusContainerView.backgroundColor = UIColor(red: 247/255, green: 251/255, blue: 214/255, alpha: 1)

        default: // Completed
            cardView.layer.borderColor = UIColor(red: 198/255, green: 233/255, blue: 196/255, alpha: 1).cgColor
            statusContainerView.backgroundColor = UIColor(red: 225/255, green: 248/255, blue: 220/255, alpha: 1)
        }
    }
}
