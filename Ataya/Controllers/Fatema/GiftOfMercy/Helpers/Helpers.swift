//
//  Helpers.swift
//  Ataya
//
//  Created by Fatema Maitham on 24/12/2025.
//

import UIKit

// MARK: - UITextField padding
extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 1))
        leftView = v
        leftViewMode = .always
    }

    func addDoneToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(_doneTap))
        toolbar.items = [flex, done]
        inputAccessoryView = toolbar
    }

    @objc private func _doneTap() {
        resignFirstResponder()
    }
}

// MARK: - Decimal format
extension Decimal {
    func moneyString() -> String {
        let ns = self as NSDecimalNumber
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencySymbol = "$"
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f.string(from: ns) ?? "$0.00"
    }

    func plainString() -> String {
        let ns = self as NSDecimalNumber
        return ns.stringValue
    }
}

// MARK: - String -> Decimal
extension String {
    func decimalValue() -> Decimal? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }

        let cleaned = trimmed.filter { "0123456789.".contains($0) }
        if cleaned.isEmpty { return nil }

        return Decimal(string: cleaned)
    }
}

// MARK: - Double / Int moneyString helpers
extension Double {
    func moneyString() -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencySymbol = "$"
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}

extension Int {
    func moneyString() -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencySymbol = "$"
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}
