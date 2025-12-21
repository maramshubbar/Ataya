import UIKit

// Holds ALL data across the 3-step donation flow.
// ONE instance is passed between screens until final submit.
final class DraftDonation{
    // MARK: - Photos (No Cloudinary here)
    var images: [UIImage] = []          // selected photos (local only)
    var photoURLs: [String] = []        // later filled by teammate after upload

    // MARK: - Details
    var itemName: String = ""
    var quantity: Int = 0
    var expiryDate: Date? = nil
    var category: String = ""
    var allergenInfo: String = ""
    var packagingType: String = ""
    var notes: String = ""

    // MARK: - Safety
    var safetyConfirmed: Bool = false
}
