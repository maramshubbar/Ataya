//
//  UIColor+Hex.swift
//  Ataya
//
//  Created by Fatema Maitham on 24/12/2025.
//

import UIKit

extension UIColor {

    convenience init(atayaHex hex: String, alpha: CGFloat = 1.0) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }

        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)

        let r, g, b: CGFloat

        if s.count == 6 {
            r = CGFloat((value & 0xFF0000) >> 16) / 255.0
            g = CGFloat((value & 0x00FF00) >> 8)  / 255.0
            b = CGFloat(value & 0x0000FF) / 255.0
        } else if s.count == 8 {
            r = CGFloat((value & 0x00FF0000) >> 16) / 255.0
            g = CGFloat((value & 0x0000FF00) >> 8)  / 255.0
            b = CGFloat(value & 0x000000FF) / 255.0
        } else {
            r = 0; g = 0; b = 0
        }

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    static let atayaYellow = UIColor(atayaHex: "F7D44C")
}
