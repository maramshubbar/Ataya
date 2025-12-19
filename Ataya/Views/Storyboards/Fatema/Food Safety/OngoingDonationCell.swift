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

    private let corner: CGFloat = 22

    override func awakeFromNib() {
        super.awakeFromNib()
        statusContainerView.setContentHuggingPriority(.required, for: .horizontal)
        statusContainerView.setContentCompressionResistancePriority(.required, for: .horizontal)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        contentView.clipsToBounds = false
        clipsToBounds = false

        // Image style
        productImageView.layer.cornerRadius = 14
        productImageView.clipsToBounds = true
        productImageView.contentMode = .scaleAspectFill

        // Pill style
        statusContainerView.layer.cornerRadius = 16
        statusContainerView.clipsToBounds = true

        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        ngoLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        ngoLabel.textColor = UIColor.black.withAlphaComponent(0.55)

        statusLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Apply shadow AFTER layout so it matches rounded corners
        shadowView.applySoftShadow(radius: corner)
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: corner).cgPath
    }

    func configure(with item: OngoingDonationItem) {
        titleLabel.text = item.title
        ngoLabel.text = item.ngoName
        statusLabel.text = item.status
        productImageView.image = UIImage(named: item.imageName)

        applyStatusStyle(item.status)
    }

    private func applyStatusStyle(_ status: String) {
        // Border + pill colors (match your screenshot vibes)
        let border: UIColor
        let pillBg: UIColor

        switch status.lowercased() {
        case "ready pickup":
            border = UIColor(hex: "#F6D9A8")
            pillBg = UIColor(hex: "#FBE7C6")
        case "in progress":
            border = UIColor(hex: "#E7F2A8")
            pillBg = UIColor(hex: "#F7F1C9")
        case "completed":
            border = UIColor(hex: "#BFE8B8")
            pillBg = UIColor(hex: "#D6F2CF")
        default:
            border = UIColor(hex: "#E6E6E6")
            pillBg = UIColor(hex: "#F2F2F2")
        }

        cardView.backgroundColor = .white
        cardView.applyCardBorder(radius: corner, borderColor: border, borderWidth: 2)

        shadowView.backgroundColor = .clear
        statusContainerView.backgroundColor = pillBg
        statusLabel.textColor = .black
    }
}
