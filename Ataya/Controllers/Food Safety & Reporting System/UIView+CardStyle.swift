//
//  UIView+CardStyle.swift
//  Ataya
//
//  Created by Fatema Maitham on 02/12/2025.
//

import Foundation
import UIKit

extension UIView {
    func applyCardStyle() {
        self.backgroundColor = .white

        // Corner radius
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = false

        // Border
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
    }
}
