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

        // Card base style (shadow + radius)
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 18
        cardView.layer.masksToBounds = false

        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)

        // Border (color will change per status)
        cardView.layer.borderWidth = 1

        // Image
        productImageView.layer.cornerRadius = 14
        productImageView.clipsToBounds = true
        productImageView.contentMode = .scaleAspectFill

        // Text style (close to figma)
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        ngoLabel.font = .systemFont(ofSize: 15, weight: .regular)
        ngoLabel.textColor = UIColor.systemGray

        // Badge
        statusContainerView.layer.cornerRadius = 12
        statusContainerView.clipsToBounds = true

        statusLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 1
        
        statusContainerView.setContentHuggingPriority(.required, for: .horizontal)
        statusContainerView.setContentCompressionResistancePriority(.required, for: .horizontal)

        statusLabel.setContentHuggingPriority(.required, for: .horizontal)
        statusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // keeps shadow perfect with rounded corners
        cardView.layer.shadowPath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 18).cgPath
    }

    func configure(with item: OngoingDonationItem) {
        titleLabel.text = item.title
        ngoLabel.text = item.ngoName
        statusLabel.text = item.status
        productImageView.image = UIImage(named: item.imageName)

        // Figma-like colors (ready=orange, progress=yellow, completed=green)
        let style = styleForStatus(item.status)

        cardView.layer.borderColor = style.border.cgColor
        statusContainerView.backgroundColor = style.badgeBG
        statusLabel.textColor = style.badgeText
    }

    private func styleForStatus(_ status: String) -> (border: UIColor, badgeBG: UIColor, badgeText: UIColor) {
        let s = status.lowercased()

        // ✅ (تقريب قوي لألوان فِقما)
        let readyBorder = UIColor(red: 244/255, green: 188/255, blue: 118/255, alpha: 1)
        let readyBG     = UIColor(red: 244/255, green: 188/255, blue: 118/255, alpha: 0.35)
        let readyText   = UIColor(red: 161/255, green: 98/255,  blue: 7/255,   alpha: 1)

        let progBorder  = UIColor(red: 224/255, green: 232/255, blue: 156/255, alpha: 1)
        let progBG      = UIColor(red: 224/255, green: 232/255, blue: 156/255, alpha: 0.45)
        let progText    = UIColor(red: 133/255, green: 102/255, blue: 0/255,   alpha: 1)

        let doneBorder  = UIColor(red: 180/255, green: 231/255, blue: 180/255, alpha: 1)
        let doneBG      = UIColor(red: 180/255, green: 231/255, blue: 180/255, alpha: 0.45)
        let doneText    = UIColor(red: 22/255,  green: 101/255, blue: 52/255,  alpha: 1)

        if s.contains("ready") {
            return (readyBorder, readyBG, readyText)
        } else if s.contains("progress") {
            return (progBorder, progBG, progText)
        } else if s.contains("complete") {
            return (doneBorder, doneBG, doneText)
        } else {
            return (.systemGray4, .systemGray6, .darkGray)
        }
    }
}
