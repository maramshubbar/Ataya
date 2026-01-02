//
//  OngoingDonationCell.swift
//  Ataya
//
//  Created by Fatema Maitham on 19/12/2025.
//

import UIKit
import FirebaseFirestore

// ✅ Model used by the Dashboard table
struct OngoingDonationItem {
    let title: String
    let ngoName: String
    let status: String
    let imageName: String        // fallback local asset
    let imageUrl: String?        // Firestore/Cloudinary URL (optional)
    let updatedAt: Date?

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
    private var statusWidthConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()

        // Text basics
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75
        titleLabel.lineBreakMode = .byClipping
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        statusLabel.numberOfLines = 1
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.minimumScaleFactor = 0.75
        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        statusContainerView.setContentHuggingPriority(.required, for: .horizontal)
        statusContainerView.setContentCompressionResistancePriority(.required, for: .horizontal)

        // remove any old width constraints on status container
        statusContainerView.constraints
            .filter { $0.firstAttribute == .width }
            .forEach { $0.isActive = false }

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        // Shadow container
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
        cardView.layer.borderWidth = 2

        // Status pill
        statusContainerView.layer.cornerRadius = 15
        statusContainerView.clipsToBounds = true

        // Fonts/colors
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        ngoLabel.font = .systemFont(ofSize: 16, weight: .regular)
        ngoLabel.textColor = .systemGray

        clipsToBounds = false
        contentView.clipsToBounds = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // ✅ prevent wrong image reuse
        productImageView.image = nil
        productImageView.accessibilityIdentifier = nil

        statusLabel.text = nil
        titleLabel.text = nil
        ngoLabel.text = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shadowView.layer.shadowPath = UIBezierPath(
            roundedRect: shadowView.bounds,
            cornerRadius: radius
        ).cgPath

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

    func configure(with item: OngoingDonationItem) {
        titleLabel.text = item.title
        ngoLabel.text = item.ngoName
        statusLabel.text = item.status

        // ✅ Image: placeholder from assets + URL if exists
        let placeholder = UIImage(named: item.imageName)
        Ataya.ImageLoader.shared.setImage(on: productImageView, from: item.imageUrl, placeholder: placeholder)

        // UI colors by status
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

        setNeedsLayout()
        layoutIfNeeded()
    }
}
extension OngoingDonationItem {

    static func fromFirestore(data: [String: Any]) -> OngoingDonationItem {

        let title =
            (data["title"] as? String) ??
            (data["foodItem"] as? String) ??
            (data["itemName"] as? String) ??
            (data["giftName"] as? String) ??
            "Donation"

        let ngoName =
            (data["ngoName"] as? String) ??
            (data["organizationName"] as? String) ??
            (data["assignedNgoName"] as? String) ??
            "NGO"

        let rawStatus =
            (data["status"] as? String) ??
            (data["donationStatus"] as? String) ??
            (data["state"] as? String) ??
            "in_progress"

        let status = normalizeStatus(rawStatus)

        let imageUrl =
            (data["imageUrl"] as? String) ??
            (data["photoUrl"] as? String) ??
            (data["coverImageUrl"] as? String) ??
            (data["thumbnailUrl"] as? String)

        let updatedAt =
            (data["updatedAt"] as? Timestamp)?.dateValue() ??
            (data["createdAt"] as? Timestamp)?.dateValue()

        let fallbackImageName = "donation_placeholder"

        return OngoingDonationItem(
            title: title,
            ngoName: ngoName,
            status: status,
            imageName: fallbackImageName,
            imageUrl: imageUrl,
            updatedAt: updatedAt
        )
    }

    private static func normalizeStatus(_ raw: String) -> String {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        switch s {
        case "ready pickup", "ready_pickup", "pickup_ready", "ready-to-pickup", "ready":
            return "Ready Pickup"
        case "in progress", "in_progress", "pending", "submitted", "approved", "processing":
            return "In Progress"
        case "completed", "complete", "done", "delivered", "finished":
            return "Completed"
        default:
            return raw.isEmpty ? "In Progress" : raw
        }
    }
}
