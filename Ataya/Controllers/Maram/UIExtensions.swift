//
//  UIExtensions.swift
//  Ataya
//
//  Created by Maram on 29/11/2025.
//

import UIKit

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 48))
        leftView = v
        leftViewMode = .always
    }
}

extension UILabel {
    convenience init(text: String) {
        self.init(frame: .zero)
        self.text = text
        self.font = .systemFont(ofSize: 15)
        self.textColor = .black
    }
}

