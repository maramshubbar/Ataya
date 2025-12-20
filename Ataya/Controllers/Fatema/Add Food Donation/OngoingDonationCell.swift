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
    private var statusWidthConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75
        titleLabel.lineBreakMode = .byClipping
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // Status label
        statusLabel.numberOfLines = 1
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.minimumScaleFactor = 0.75
        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        
        statusContainerView.setContentHuggingPriority(.required, for: .horizontal)
        statusContainerView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        statusContainerView.constraints
            .filter { $0.firstAttribute == .width }
            .forEach { $0.isActive = false }
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        // Shadow (must NOT clip)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.06
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowView.layer.shadowRadius = 8
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
        
        clipsToBounds = false
        contentView.clipsToBounds = false
        
        forceStatusConstraints()

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Keep shadow shape matching rounded card
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
    
    
    func configure(with item: OngoingDonationItem) {
        titleLabel.text = item.title
        ngoLabel.text = item.ngoName
        statusLabel.text = item.status
        productImageView.image = UIImage(named: item.imageName)
        
        setNeedsLayout()
        layoutIfNeeded()
        
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
    
    private func forceStatusConstraints() {

        guard let superV = statusContainerView.superview else { return }

        // 1) عطّل أي constraints قديمة تخص الـ statusContainerView (مثل centerX/leading الغلط)
        for c in superV.constraints {
            if c.firstItem as AnyObject === statusContainerView || c.secondItem as AnyObject === statusContainerView {
                c.isActive = false
            }
        }

        // 2) عطّل أي trailing/width constraints غلط ممكن تكون على titleLabel
        for c in superV.constraints {
            if c.firstItem as AnyObject === titleLabel || c.secondItem as AnyObject === titleLabel {
                // نخلي قيود اليسار/الاعلى عادة، بس نعطل اللي تسبب القص مع البيل
                if c.firstAttribute == .trailing || c.secondAttribute == .trailing || c.firstAttribute == .width || c.secondAttribute == .width {
                    c.isActive = false
                }
            }
        }

        statusContainerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // 3) constraints الصحيحة: البيل يمين + العنوان ما يتداخل
        let trailing = statusContainerView.trailingAnchor.constraint(equalTo: superV.trailingAnchor, constant: -16)
        let centerY  = statusContainerView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        let gap      = statusContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12)

        let titleTrail = titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusContainerView.leadingAnchor, constant: -12)

        trailing.priority = .required
        centerY.priority  = .required
        gap.priority      = .required
        titleTrail.priority = .required

        NSLayoutConstraint.activate([trailing, centerY, gap, titleTrail])

        // 4) priorities (العنوان يتمدد، والبيل ما ينضغط)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        statusContainerView.setContentHuggingPriority(.required, for: .horizontal)
        statusContainerView.setContentCompressionResistancePriority(.required, for: .horizontal)

        // العنوان يصير سطرين إذا تبين (أحسن من القص)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
    }

}
