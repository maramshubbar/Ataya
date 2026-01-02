import UIKit
import FirebaseFirestore

final class DraftDonation {

    var id: String?

    // Details
    var itemName: String = ""
    var quantityValue: Int = 0
    var quantityUnit: String = ""
    var expiryDate: Date?
    var category: String = ""
    var packagingType: String = ""
    var allergenInfo: String? = nil
    var notes: String? = nil
    var safetyConfirmed: Bool = false

    // Photos
    var images: [UIImage] = []
    var photoURLs: [String] = []
    var imagePublicIds: [String] = []
    var photoCount: Int { photoURLs.count }

    // Pickup (saved under "pickup" by DonationDraftSaver)
    var pickupDate: Date?
    var pickupTime: String?
    var pickupMethod: String = ""          // "ngo" or "myAddress"
    var pickupAddress: AddressModel?

    func applyCloudinaryUploads(urls: [String], publicIds: [String], replace: Bool = true) {
        if replace {
            self.photoURLs = urls
            self.imagePublicIds = publicIds
        } else {
            self.photoURLs.append(contentsOf: urls)
            self.imagePublicIds.append(contentsOf: publicIds)
        }
    }

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

    /// ✅ No pickup fields here (pickup saved as nested object by DonationDraftSaver)
    func toFirestoreDict(isUpdate: Bool) -> [String: Any] {
        normalizeBeforeSave()

        var data: [String: Any] = [
            "safetyConfirmed": safetyConfirmed
        ]

        // Details
        if !itemName.isEmpty { data["itemName"] = itemName }
        else if isUpdate { data["itemName"] = FieldValue.delete() }

        if !category.isEmpty { data["category"] = category }
        else if isUpdate { data["category"] = FieldValue.delete() }

        if !packagingType.isEmpty { data["packagingType"] = packagingType }
        else if isUpdate { data["packagingType"] = FieldValue.delete() }

        if quantityValue > 0 { data["quantityValue"] = quantityValue }
        else if isUpdate { data["quantityValue"] = FieldValue.delete() }

        if !quantityUnit.isEmpty { data["quantityUnit"] = quantityUnit }
        else if isUpdate { data["quantityUnit"] = FieldValue.delete() }

        if let expiryDate { data["expiryDate"] = expiryDate }
        else if isUpdate { data["expiryDate"] = FieldValue.delete() }

        if let allergenInfo { data["allergenInfo"] = allergenInfo }
        else if isUpdate { data["allergenInfo"] = FieldValue.delete() }

        if let notes { data["notes"] = notes }
        else if isUpdate { data["notes"] = FieldValue.delete() }

        // Photos
        if !photoURLs.isEmpty || !imagePublicIds.isEmpty {
            data["photoURLs"] = photoURLs
            data["imagePublicIds"] = imagePublicIds
            data["photoCount"] = photoURLs.count
        } else if isUpdate {
            data["photoURLs"] = FieldValue.delete()
            data["imagePublicIds"] = FieldValue.delete()
            data["photoCount"] = FieldValue.delete()
        }

        return data
    }
}

