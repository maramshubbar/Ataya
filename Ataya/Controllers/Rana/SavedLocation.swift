//
//  SavedLocation.swift
//  Ataya
//
//  Created by BP-36-224-14 on 22/12/2025.
//

import Foundation

struct savedLocation: Codable {
    let latitude: Double
    let longitude: Double
    let address: String
    let savedAt: Date
}
