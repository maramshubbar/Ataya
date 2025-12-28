//
//  AdminDonationDetailsViewController.swift
//  Ataya
//
//  Created by Maram on 20/12/2025.
//

import UIKit

class AdminDonationDetailsViewController: UIViewController {

    @IBOutlet weak var donationCardView: UIView!
    @IBOutlet weak var donorCardView: UIView!
    @IBOutlet weak var ngoCardView: UIView!
    @IBOutlet weak var adminReviewCardView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        donationCardView.applyCardStyleNoShadow()
        donorCardView.applyCardStyleNoShadow()
        ngoCardView.applyCardStyleNoShadow()
        adminReviewCardView.applyCardStyleNoShadow()
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8) & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

extension UIView {

    /// ✅ Normal card: radius + border ONLY (NO shadow)
    func applyCardStyleNoShadow(
        radius: CGFloat = 16,
        borderHex: String = "#E6E6E6",
        borderWidth: CGFloat = 1
    ) {
        // Remove any shadow completely
        layer.shadowColor = nil
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.shadowOffset = .zero
        layer.shadowPath = nil
        layer.shouldRasterize = false

        // Card border + radius
        layer.cornerRadius = radius
        layer.borderWidth = borderWidth
        layer.borderColor = UIColor(hex: borderHex).cgColor

        // Clip content to rounded corners
        clipsToBounds = true
        layer.masksToBounds = true
    }

    // ✅ Keep your method, but make sure NO shadow happens
    func applyCardBorder(radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat = 2) {
        layer.shadowColor = nil
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.shadowOffset = .zero
        layer.shadowPath = nil
        layer.shouldRasterize = false

        layer.cornerRadius = radius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor

        clipsToBounds = true
        layer.masksToBounds = true
    }

    // (Left here if you still have calls somewhere, but it will NOT add shadow)
    func applySoftShadow(radius: CGFloat) {
        // Intentionally disabled (no shadow)
        layer.shadowColor = nil
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.shadowOffset = .zero
        layer.shadowPath = nil
        layer.shouldRasterize = false
    }
}
