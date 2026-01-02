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

        let a = (allergenInfo ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        allergenInfo = (a.isEmpty || a == "None") ? nil : a

        let n = (notes ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        notes = n.isEmpty ? nil : n

        if let pt = pickupTime?.trimmingCharacters(in: .whitespacesAndNewlines) {
            pickupTime = pt.isEmpty ? nil : pt
        }

        pickupMethod = pickupMethod.trimmingCharacters(in: .whitespacesAndNewlines)
    }


    /// ✅ No pickup fields here (pickup saved as nested object by DonationDraftSaver)
    func toFirestoreDict(isUpdate: Bool) -> [String: Any] {
        var d: [String: Any] = [:]

        d["itemName"] = itemName
        d["quantityValue"] = quantityValue
        d["quantityUnit"] = quantityUnit

        if let expiryDate { d["expiryDate"] = expiryDate }

        d["category"] = category
        d["packagingType"] = packagingType

        if let allergenInfo { d["allergenInfo"] = allergenInfo }
        if let notes { d["notes"] = notes }

        d["safetyConfirmed"] = safetyConfirmed

        return d
    }

}

