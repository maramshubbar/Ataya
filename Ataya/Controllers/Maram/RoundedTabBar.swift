//
//  RoundedTabBar.swift
//  Ataya
//
//  Created by Maram on 16/12/2025.
//

import Foundation
import UIKit

final class RoundedTabBar: UITabBar {
    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = 34
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = false

        backgroundColor = .white
        isTranslucent = false

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: -2)
    }
}
