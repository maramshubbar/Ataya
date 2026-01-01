//
//  locationStorage.swift
//  Ataya
//
//  Created by BP-36-224-14 on 22/12/2025.
//

import Foundation

struct SavedLocation: Codable {
    let latitude: Double
    let longitude: Double
    let address: String
    let savedAt: Date
}

enum LocationStorage {
    private static let key = "saved_location_key"

    static func save(_ location: SavedLocation) {
        if let data = try? JSONEncoder().encode(location) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> SavedLocation? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let loc = try? JSONDecoder().decode(SavedLocation.self, from: data) else {
            return nil
        }
        return loc
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
}
