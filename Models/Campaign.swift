//
//  Campaign.swift
//  Ataya
//
//  Created by Maram on 24/12/2025.
//


import Foundation
import FirebaseFirestore

struct Campaign: Identifiable, Codable {

    // ✅ Firestore document id
    @DocumentID var id: String?

    // ✅ Main fields (same as your form)
    var title: String
    var category: String
    var goalAmount: Double
    var startDate: Timestamp
    var endDate: Timestamp
    var location: String
    var overview: String
    var story: String
    var from: String
    var organization: String
    var showOnHome: Bool

    // ✅ Cloudinary
    var imageUrl: String?
    var imagePublicId: String?

    // ✅ Metadata
    var createdAt: Timestamp
    var updatedAt: Timestamp

    // MARK: - Init for create/edit from form
    init(
        id: String? = nil,
        title: String,
        category: String,
        goalAmount: Double,
        startDate: Date,
        endDate: Date,
        location: String,
        overview: String,
        story: String,
        from: String,
        organization: String,
        showOnHome: Bool,
        imageUrl: String? = nil,
        imagePublicId: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.goalAmount = goalAmount
        self.startDate = Timestamp(date: startDate)
        self.endDate = Timestamp(date: endDate)
        self.location = location
        self.overview = overview
        self.story = story
        self.from = from
        self.organization = organization
        self.showOnHome = showOnHome
        self.imageUrl = imageUrl
        self.imagePublicId = imagePublicId
        self.createdAt = Timestamp(date: createdAt)
        self.updatedAt = Timestamp(date: updatedAt)
    }

    // ✅ helper: parse "80,000 $" -> 80000
    static func parseGoalAmount(_ text: String) -> Double {
        let cleaned = text
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "$", with: "")
        return Double(cleaned) ?? 0
    }

    // ✅ For UI display
    var goalAmountText: String {
        let n = Int(goalAmount)
        return "\(n) $"
    }
}

