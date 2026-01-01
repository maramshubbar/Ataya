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
    
    var images: [UIImage] = []
    var photoURLs: [String] = []
    var imagePublicIds: [String] = []
    var photoCount: Int { photoURLs.count }

    var pickupDate: Date?
    var pickupTime: String?
    var pickupMethod: String = ""
    var pickupAddress: AddressModel?

    
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

        if let expiryDate { data["expiryDate"] = expiryDate }
        if let allergenInfo { data["allergenInfo"] = allergenInfo }
        if let notes { data["notes"] = notes }

        return data
    }
}
