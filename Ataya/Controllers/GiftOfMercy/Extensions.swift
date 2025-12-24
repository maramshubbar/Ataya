//
//  Extensions.swift
//  Ataya
//
//  Created by Fatema Maitham on 24/12/2025.
//

import UIKit

// MARK: - UIColor Hex
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

// MARK: - UITextField padding + Done
extension UITextField {
    func setLeftPadding(_ value: CGFloat) {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: value, height: 1))
        leftView = v
        leftViewMode = .always
    }

    func addDoneToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        toolbar.items = [flex, done]
        inputAccessoryView = toolbar
    }

    @objc private func donePressed() {
        resignFirstResponder()
    }
}

// MARK: - String -> Decimal (valid amount)
extension String {
    func decimalValue() -> Decimal? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }

        // Allow "500" or "500.25"
        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
        return Decimal(string: normalized)
    }
}

// MARK: - Decimal formatting
extension Decimal {
    func moneyString() -> String {
        let ns = self as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: ns) ?? "$\(ns)"
    }

    func plainString() -> String {
        let ns = self as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: ns) ?? "\(ns)"
    }
}
