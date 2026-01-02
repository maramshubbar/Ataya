//
//  MercyGift.swift
//  Ataya
//
//  Created by Fatema Maitham on 29/12/2025.
//
import Foundation
import FirebaseFirestore

struct MercyGift {

    enum PricingMode: String {
        case fixed
        case custom
    }

    let id: String
    let title: String
    let description: String
    let pricingMode: PricingMode

    let fixedAmount: Double?
    let minAmount: Double?
    let maxAmount: Double?

    let imageURL: String?
    let imagePublicId: String?
    let assetName: String?

    let isActive: Bool
    let createdAt: Timestamp?
    let updatedAt: Timestamp?

    init?(_ doc: DocumentSnapshot) {
        let data = doc.data() ?? [:]

        let title = (data["title"] as? String)
            ?? (data["name"] as? String)
            ?? ""

        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return nil }

        let desc = (data["description"] as? String) ?? ""

        let pricingRaw = (data["pricingMode"] as? String)
            ?? (data["pricing"] as? String)
            ?? "custom"

        let pricingMode = PricingMode(rawValue: pricingRaw) ?? .custom

        func toDouble(_ any: Any?) -> Double? {
            if let d = any as? Double { return d }
            if let i = any as? Int { return Double(i) }
            if let n = any as? NSNumber { return n.doubleValue }
            return nil
        }

        self.id = doc.documentID
        self.title = title
        self.description = desc
        self.pricingMode = pricingMode

        self.fixedAmount = toDouble(data["fixedAmount"])
        self.minAmount = toDouble(data["minAmount"])
        self.maxAmount = toDouble(data["maxAmount"])

        self.imageURL = (data["imageURL"] as? String) ?? (data["imageUrl"] as? String)
        self.imagePublicId = (data["imagePublicId"] as? String) ?? (data["image_public_id"] as? String)
        self.assetName = (data["assetName"] as? String)

        self.isActive = (data["isActive"] as? Bool) ?? true
        self.createdAt = data["createdAt"] as? Timestamp
        self.updatedAt = data["updatedAt"] as? Timestamp
    }
}
