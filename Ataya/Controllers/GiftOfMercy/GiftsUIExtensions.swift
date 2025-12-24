import UIKit
import Foundation

// MARK: - UITextField Helpers
extension UITextField {

    func setLeftPadding(_ points: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: points, height: 1))
        leftView = paddingView
        leftViewMode = .always
    }

    func setRightPadding(_ points: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: points, height: 1))
        rightView = paddingView
        rightViewMode = .always
    }

    func addDoneToolbar(title: String = "Done") {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(_doneTapped))

        toolbar.items = [flex, done]
        inputAccessoryView = toolbar
    }

    @objc private func _doneTapped() {
        resignFirstResponder()
    }
}

// MARK: - Decimal Formatting
extension Decimal {
    var plainString: String {
        NSDecimalNumber(decimal: self).stringValue
    }

    var moneyString: String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.usesGroupingSeparator = true
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f.string(from: NSDecimalNumber(decimal: self)) ?? plainString
    }
}

// MARK: - UIView Shadow
extension UIView {
    func applyCardShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 12
    }
}

import Foundation

extension String {
    func decimalValue() -> Decimal? {
        // يشيل المسافات
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)

        // يسمح بالأرقام + النقطة + الفاصلة
        // ويشيل أي شيء ثاني مثل $
        let allowed = CharacterSet(charactersIn: "0123456789.,")
        let cleaned = trimmed.unicodeScalars.filter { allowed.contains($0) }
        let cleanedString = String(String.UnicodeScalarView(cleaned))

        // نحول الفاصلة إلى نقطة عشان Decimal يفهمها
        let normalized = cleanedString.replacingOccurrences(of: ",", with: ".")

        return Decimal(string: normalized)
    }
}
