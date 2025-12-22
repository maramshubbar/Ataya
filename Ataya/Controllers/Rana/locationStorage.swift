//
//  locationStorage.swift
//  Ataya
//
//  Created by BP-36-224-14 on 22/12/2025.
//

import Foundation

enum locationStorage {
    private static let key = "saved_location"

    static func save(_ saved: savedLocation) {
        if let data = try? JSONEncoder().encode(saved) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> savedLocation? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(savedLocation.self, from: data)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
