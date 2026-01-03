
import UIKit
import Foundation

final class DraftDonation {
    var id: String?

    var itemName: String = ""

    // ✅ quantity as number + unit
    var quantityValue: Int = 0         // 0 = not selected yet
    var quantityUnit: String = "kg"

    var expiryDate: Date?
    var category: String = ""
    var packagingType: String = ""
    var allergenInfo: String? = nil
    var notes: String? = nil

    var safetyConfirmed: Bool = false

    // ✅ local images (before upload)
    var images: [UIImage] = []

    // ✅ uploaded images data
    var photoURLs: [String] = []
    var imagePublicIds: [String] = []

    var photoCount: Int { photoURLs.count }

    // ✅ PICKUP (ضيفناها عشان يختفي error)
    var pickupMethod: String?          // "myAddress" or "ngo"
    var pickupAddress: AddressModel?            // <-- إذا عندك موديل Address حطيه هنا بدل Any
    var pickupDate: Date?
    var pickupTime: String?

    // ✅ Cloudinary helper (علشان applyCloudinaryUploads موجودة بالكنترولرز)
    func applyCloudinaryUploads(urls: [String], publicIds: [String], replace: Bool) {
        if replace {
            self.photoURLs = urls
            self.imagePublicIds = publicIds
        } else {
            self.photoURLs.append(contentsOf: urls)
            self.imagePublicIds.append(contentsOf: publicIds)
        }
    }

    func toFirestoreDict() -> [String: Any] {
        var data: [String: Any] = [
            "itemName": itemName,

            // ✅ store properly
            "quantityValue": quantityValue,
            "quantityUnit": quantityUnit,

            "category": category,
            "packagingType": packagingType,
            "safetyConfirmed": safetyConfirmed,
            "photoCount": photoCount,
            "photoURLs": photoURLs,
            "imagePublicIds": imagePublicIds
        ]

        // ✅ optional extras
        if let expiryDate { data["expiryDate"] = expiryDate }
        if let allergenInfo { data["allergenInfo"] = allergenInfo }
        if let notes { data["notes"] = notes }

        // ✅ pickup fields (تخزينهم اختياري بس زين نرسلهم إذا موجودين)
        if let pickupMethod { data["pickupMethod"] = pickupMethod }
        if let pickupDate { data["pickupDate"] = pickupDate }
        if let pickupTime { data["pickupTime"] = pickupTime }

        // ⚠️ pickupAddress: ما أقدر أحوله تلقائيًا بدون ما أعرف نوعه
        // إذا عندك AddressModel/AddressItem خلّيه Dictionary هنا
        // مثال:
        // if let addr = pickupAddress as? AddressModel { data["pickupAddress"] = addr.toDict() }

        return data
    }
}

