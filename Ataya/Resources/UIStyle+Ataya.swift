//
//  UIStyle+Ataya.swift
//  Ataya
//
//  Created by Fatema Maitham on 19/12/2025.
//

import UIKit

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
    func applyCardBorder(radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat = 2) {
        layer.cornerRadius = radius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        clipsToBounds = true
    }

    func applySoftShadow(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.10
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 6)
    }
}
