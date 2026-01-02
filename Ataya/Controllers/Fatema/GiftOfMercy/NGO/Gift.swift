// FILE: Gift.swift

import Foundation
import FirebaseFirestore

struct Gift {

    enum PricingMode: String {
        case fixed
        case custom
    }

    // Firestore doc id
    var id: String

    // UI
    var title: String
    var description: String
    var isActive: Bool

    // Pricing
    var pricingMode: PricingMode
    var fixedAmount: Double?
    var minAmount: Double?
    var maxAmount: Double?

    // Cloudinary
    var imageURL: String?        // secure_url
    var imagePublicId: String?   // public_id

    // Tracking
    var ngoId: String?
    var createdAt: Timestamp?
    var updatedAt: Timestamp?

    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        isActive: Bool = true,
        pricingMode: PricingMode,
        fixedAmount: Double? = nil,
        minAmount: Double? = nil,
        maxAmount: Double? = nil,
        imageURL: String? = nil,
        imagePublicId: String? = nil,
        ngoId: String? = nil,
        createdAt: Timestamp? = nil,
        updatedAt: Timestamp? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isActive = isActive
        self.pricingMode = pricingMode
        self.fixedAmount = fixedAmount
        self.minAmount = minAmount
        self.maxAmount = maxAmount
        self.imageURL = imageURL
        self.imagePublicId = imagePublicId
        self.ngoId = ngoId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// ✅ Kept name to avoid breaking your existing GiftManagementCell.ViewModel(imageName: ...)
    /// Now it returns the Cloudinary URL (not a placeholder).
    var displayImageName: String { imageURL ?? "" }
}

// MARK: - Firestore keys
extension Gift {
    enum Keys {
        static let title = "title"
        static let description = "description"
        static let isActive = "isActive"
        static let pricingMode = "pricingMode"
        static let fixedAmount = "fixedAmount"
        static let minAmount = "minAmount"
        static let maxAmount = "maxAmount"
        static let imageURL = "imageURL"
        static let imagePublicId = "imagePublicId"
        static let ngoId = "ngoId"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }
}

// MARK: - Firestore mapping
extension Gift {

    func toFirestoreDict() -> [String: Any] {

        var data: [String: Any] = [
            Keys.title: title,
            Keys.description: description,
            Keys.isActive: isActive,
            Keys.pricingMode: pricingMode.rawValue,
            Keys.updatedAt: FieldValue.serverTimestamp()
        ]

        // createdAt only for new docs
        if createdAt == nil {
            data[Keys.createdAt] = FieldValue.serverTimestamp()
        }

        if let ngoId { data[Keys.ngoId] = ngoId }

        if let imageURL { data[Keys.imageURL] = imageURL }
        if let imagePublicId { data[Keys.imagePublicId] = imagePublicId }

        // Pricing fields (delete irrelevant ones to avoid stale values)
        switch pricingMode {
        case .fixed:
            data[Keys.fixedAmount] = fixedAmount ?? 0
            data[Keys.minAmount] = FieldValue.delete()
            data[Keys.maxAmount] = FieldValue.delete()

        case .custom:
            data[Keys.fixedAmount] = FieldValue.delete()

            if let minAmount { data[Keys.minAmount] = minAmount }
            else { data[Keys.minAmount] = FieldValue.delete() }

            if let maxAmount { data[Keys.maxAmount] = maxAmount }
            else { data[Keys.maxAmount] = FieldValue.delete() }
        }

        return data
    }

    init?(doc: DocumentSnapshot) {
        let d = doc.data() ?? [:]
        guard let title = d[Keys.title] as? String else { return nil }

        self.id = doc.documentID
        self.title = title
        self.description = d[Keys.description] as? String ?? ""
        self.isActive = d[Keys.isActive] as? Bool ?? true

        let raw = d[Keys.pricingMode] as? String ?? PricingMode.fixed.rawValue
        self.pricingMode = PricingMode(rawValue: raw) ?? .fixed

        self.fixedAmount = Gift.readDouble(d[Keys.fixedAmount])
        self.minAmount = Gift.readDouble(d[Keys.minAmount])
        self.maxAmount = Gift.readDouble(d[Keys.maxAmount])

        self.imageURL = d[Keys.imageURL] as? String
        self.imagePublicId = d[Keys.imagePublicId] as? String

        self.ngoId = d[Keys.ngoId] as? String
        self.createdAt = d[Keys.createdAt] as? Timestamp
        self.updatedAt = d[Keys.updatedAt] as? Timestamp
    }

    private static func readDouble(_ value: Any?) -> Double? {
        if let d = value as? Double { return d }
        if let i = value as? Int { return Double(i) }
        if let n = value as? NSNumber { return n.doubleValue }
        return nil
    }
}
