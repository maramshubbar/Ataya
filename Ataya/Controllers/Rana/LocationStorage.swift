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

    // ✅ إذا عندك كود قديم ينادي save(location)
    static func save(_ location: SavedLocation) {
        cached = location
    }

    // ✅ هذا اللي كودك الحالي يناديه: save(latitude:longitude:address:)
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
