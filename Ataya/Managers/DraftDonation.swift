import UIKit
import Foundation

// Holds ALL data across the 3-step donation flow.
// ONE instance is passed between screens until final submit.
final class DraftDonation {
    var id: String?

    var itemName: String = ""
    var quantity: String = ""

    var expiryDate: Date?
    var category: String = ""
    var packagingType: String = ""
    var allergenInfo: String? = nil
    var notes: String? = nil

    var safetyConfirmed: Bool = false

    // User-selected images (used during UI flow only)
    var images: [UIImage] = []

    // ✅ Cloudinary results (what we store in Firestore)
    var imageUrls: [String] = []
    var imagePublicIds: [String] = []

    var photoCount: Int { images.count }

    func toFirestoreDict() -> [String: Any] {
        var data: [String: Any] = [
            "itemName": itemName,
            "quantity": quantity,
            "category": category,
            "packagingType": packagingType,
            "safetyConfirmed": safetyConfirmed,
            "photoCount": photoCount
        ]

        if let expiryDate { data["expiryDate"] = expiryDate }
        if let allergenInfo { data["allergenInfo"] = allergenInfo }
        if let notes { data["notes"] = notes }

        // ✅ Add Cloudinary URLs if uploaded
        if !imageUrls.isEmpty { data["imageUrls"] = imageUrls }
        if !imagePublicIds.isEmpty { data["imagePublicIds"] = imagePublicIds }

        return data
    }
}
