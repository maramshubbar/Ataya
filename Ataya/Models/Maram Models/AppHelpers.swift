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
