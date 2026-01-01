//
//  AddressModel.swift
//  Ataya
//
//  Created by Fatema Maitham on 01/01/2026.
//


import Foundation

struct AddressModel {
    var title: String
    var fullAddress: String
    var latitude: Double
    var longitude: Double

    func toDict() -> [String: Any] {
        return [
            "title": title,
            "fullAddress": fullAddress,
            "latitude": latitude,
            "longitude": longitude
        ]
    }

    static func fromDict(_ dict: [String: Any]) -> AddressModel? {
        guard
            let title = dict["title"] as? String,
            let fullAddress = dict["fullAddress"] as? String,
            let latitude = dict["latitude"] as? Double,
            let longitude = dict["longitude"] as? Double
        else { return nil }

        return AddressModel(title: title, fullAddress: fullAddress, latitude: latitude, longitude: longitude)
    }
}
