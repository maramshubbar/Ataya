import UIKit
import Foundation

final class DraftDonation {

    var id: String?

    var itemName: String = ""

    // Quantity
    var quantityValue: Int = 0
    var quantityUnit: String = ""

    var expiryDate: Date?
    var category: String = ""
    var packagingType: String = ""
    var allergenInfo: String? = nil
    var notes: String? = nil

    var safetyConfirmed: Bool = false

    // Photos
    var images: [UIImage] = []            // local only (before upload)
    var photoURLs: [String] = []          // Cloudinary secure_url
    var imagePublicIds: [String] = []     // Cloudinary public_id

    var photoCount: Int { photoURLs.count }

    // Pickup
    var pickupDate: Date?
    var pickupTime: String?
    var pickupMethod: String = ""
    var pickupAddress: AddressModel?

    // ✅ IMPORTANT: Call this AFTER Cloudinary upload success
    func applyCloudinaryUploads(urls: [String], publicIds: [String], replace: Bool = true) {
        if replace {
            self.photoURLs = urls
            self.imagePublicIds = publicIds
        } else {
            self.photoURLs.append(contentsOf: urls)
            self.imagePublicIds.append(contentsOf: publicIds)
        }
    }

    // ✅ Clean empty strings -> nil
    func normalizeBeforeSave() {
        itemName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        category = category.trimmingCharacters(in: .whitespacesAndNewlines)
        packagingType = packagingType.trimmingCharacters(in: .whitespacesAndNewlines)
        quantityUnit = quantityUnit.trimmingCharacters(in: .whitespacesAndNewlines)

        if let a = allergenInfo?.trimmingCharacters(in: .whitespacesAndNewlines) {
            allergenInfo = a.isEmpty || a.lowercased() == "none" ? nil : a
        }

        if let n = notes?.trimmingCharacters(in: .whitespacesAndNewlines) {
            notes = n.isEmpty ? nil : n
        }
    }

    // ✅ CRITICAL FIX:
    // لا ترسل قيم فاضية (0 أو "" أو []) عشان لا تمسحين قيم Cloudinary/Quantity القديمة بالـ merge
    func toFirestoreDict() -> [String: Any] {
        normalizeBeforeSave()

        var data: [String: Any] = [
            "itemName": itemName,
            "category": category,
            "packagingType": packagingType,
            "safetyConfirmed": safetyConfirmed
        ]

        if quantityValue > 0 { data["quantityValue"] = quantityValue }
        if !quantityUnit.isEmpty { data["quantityUnit"] = quantityUnit }

        if let expiryDate { data["expiryDate"] = expiryDate }
        if let allergenInfo { data["allergenInfo"] = allergenInfo }
        if let notes { data["notes"] = notes }

        // photos ONLY if uploaded (so we don't overwrite existing with empty)
        if !photoURLs.isEmpty || !imagePublicIds.isEmpty {
            data["photoURLs"] = photoURLs
            data["imagePublicIds"] = imagePublicIds
            data["photoCount"] = photoURLs.count
        }

        return data
    }
}
