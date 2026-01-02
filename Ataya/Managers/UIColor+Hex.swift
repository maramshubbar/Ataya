//
//  UIColor+Hex.swift
//  Ataya
//
//  Created by Fatema Maitham on 02/12/2025.
//

import UIKit

extension UIColor {

    /// Hex -> UIColor
    /// يقبل: "#F7D44C" أو "F7D44C" أو "FFF" (اختصار)
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }

        // دعم #RGB
        if s.count == 3 {
            let c = Array(s)
            s = "\(c[0])\(c[0])\(c[1])\(c[1])\(c[2])\(c[2])"
        }

        var rgb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8)  / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    /// عشان الأكواد القديمة اللي تستخدم atayaHex:
    convenience init(atayaHex: String, alpha: CGFloat = 1.0) {
        self.init(hex: atayaHex, alpha: alpha)
    }

    // MARK: - Ataya Brand Colors (استخدميهم كـ UIColor.atayaYellow ...)
    static let atayaYellow = UIColor(
        red: 247/255,
        green: 212/255,
        blue: 76/255,
        alpha: 1
    ) // #F7D44C

    static let atayaSoftYellow = UIColor(
        red: 255/255,
        green: 251/255,
        blue: 231/255,
        alpha: 1
    ) // #FFFBE7

    static let atayaGreen = UIColor(
        red: 0/255,
        green: 168/255,
        blue: 92/255,
        alpha: 1
    ) // #00A85C

    static let atayaBorderGray = UIColor(
        red: 153/255,
        green: 153/255,
        blue: 153/255,
        alpha: 1
    ) // #999999

}
