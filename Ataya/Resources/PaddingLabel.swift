//
//  PaddingLabel.swift
//  Ataya
//
//  Created by Fatema Maitham on 19/12/2025.
//


import UIKit

final class PaddingLabel: UILabel {

    var insets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + insets.left + insets.right,
                      height: s.height + insets.top + insets.bottom)
    }
}
