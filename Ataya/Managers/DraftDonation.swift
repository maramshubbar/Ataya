//
//  DraftDonation.swift
//  Ataya
//
//  Created by Fatema Maitham on 17/12/2025.
//


import Foundation
import UIKit

// Holds ALL data across the 3-step donation flow.
// We pass ONE instance between screens until final submit.
struct DraftDonation {

    // MARK: - Photos (Cloudinary later)
    // For now (no Cloudinary): keep photo URLs empty.
    // Later: fill this with Cloudinary secure URLs.
    var photoUrls: [String] = []
    var images: [UIImage] = []

    // Optional: just to prove photos were selected even before Cloudinary.
    var localPhotosCount: Int = 0

    // MARK: - Details
    var id: String = ""
    var photoURLs: [String] = []
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
