//
//  LocationStorage.swift
//  Ataya
//
//  Created by Fatema Maitham on 01/01/2026.
//


import Foundation

struct LocationStorage {

    struct SavedLocation {
        let latitude: Double
        let longitude: Double
        let address: String
    }

    private static var cached: SavedLocation?

    static func save(latitude: Double, longitude: Double, address: String) {
        cached = SavedLocation(latitude: latitude, longitude: longitude, address: address)
    }

    static func load() -> SavedLocation? {
        return cached
    }

    static func clear() {
        cached = nil
    }
}
