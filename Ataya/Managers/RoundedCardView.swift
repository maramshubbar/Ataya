//
//  RoundedCardView.swift
//  Ataya
//
//  Created by Maram on 25/11/2025.
//

import Foundation
import UIKit

@IBDesignable
class RoundedCardView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet { setNeedsLayout() }
    }

    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet { setNeedsLayout() }
    }

    @IBInspectable var borderColor: UIColor = UIColor.lightGray {
        didSet { setNeedsLayout() }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
    }
}
