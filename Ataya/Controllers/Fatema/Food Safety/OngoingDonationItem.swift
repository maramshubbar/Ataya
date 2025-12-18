//
//  OngoingDonationItem.swift
//  Ataya
//
//  Created by Fatema Maitham on 18/12/2025.
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

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ngoLabel: UILabel!
    @IBOutlet weak var statusContainerView: UIView!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        cardView.layer.cornerRadius = 18
        cardView.layer.masksToBounds = false
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.35).cgColor
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)

        productImageView.layer.cornerRadius = 14
        productImageView.clipsToBounds = true
        productImageView.contentMode = .scaleAspectFill

        statusContainerView.layer.cornerRadius = 10
        statusContainerView.clipsToBounds = true
    }

    func configure(with item: OngoingDonationItem) {
        titleLabel.text = item.title
        ngoLabel.text = item.ngoName
        statusLabel.text = item.status
        productImageView.image = UIImage(named: item.imageName)

        switch item.status.lowercased() {
        case "ready pickup":
            statusContainerView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.18)
            statusLabel.textColor = .systemOrange
        case "in progress":
            statusContainerView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.20)
            statusLabel.textColor = .systemOrange
        default:
            statusContainerView.backgroundColor = UIColor.systemGray5
            statusLabel.textColor = .darkGray
        }
    }
}
