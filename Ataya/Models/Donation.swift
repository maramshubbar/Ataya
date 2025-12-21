//
//  Donation.swift
//  Ataya
//
//  Created by Maram on 21/12/2025.
//

import Foundation
import FirebaseFirestore

struct Donation: Codable {
    @DocumentID var id: String?

    let donorId: String
    let title: String
    let category: String

    let expiryMonth: Int
    let expiryYear: Int

    let allergens: String
    let packaging: String
    let details: String

    let status: String
    let imageUrls: [String]

    @ServerTimestamp var createdAt: Timestamp?
}

