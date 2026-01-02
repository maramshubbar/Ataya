//
//  AppHelpers.swift
//  Ataya
//
//  Created by Maram on 24/12/2025.
//

import UIKit

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

extension Date {
    var formattedShort: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d yyyy"
        return f.string(from: self)
    }
}

//private extension UIColor {
//    convenience init(hex: String) {
//        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//        if h.hasPrefix("#") { h.removeFirst() }
//        var rgb: UInt64 = 0
//        Scanner(string: h).scanHexInt64(&rgb)
//        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
//        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
//        let b = CGFloat(rgb & 0x0000FF) / 255
//        self.init(red: r, green: g, blue: b, alpha: 1)
//    }
//}
