//
//  FoodSafetyReport.swift
//  Ataya
//
//  Created by Fatema Maitham on 02/01/2026.
//


import Foundation
import FirebaseFirestore

struct FoodSafetyReport {
    let id: String
    let donationId: String
    let donorId: String
    let donorName: String
    let ngoId: String

    let collectorId: String
    let collectorName: String

    let reason: String
    let description: String
    let evidenceUrl: String

    let status: String   // "open" / "resolved"
    let createdAt: Date

    init?(doc: DocumentSnapshot) {
        let data = doc.data() ?? [:]

        guard
            let donationId = data["donationId"] as? String,
            let donorId = data["donorId"] as? String,
            let donorName = data["donorName"] as? String,
            let ngoId = data["ngoId"] as? String,
            let collectorId = data["collectorId"] as? String,
            let collectorName = data["collectorName"] as? String,
            let reason = data["reason"] as? String,
            let status = data["status"] as? String
        else { return nil }

        let description = (data["description"] as? String) ?? ""
        let evidenceUrl = (data["evidenceUrl"] as? String) ?? ""

        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()

        self.id = doc.documentID
        self.donationId = donationId
        self.donorId = donorId
        self.donorName = donorName
        self.ngoId = ngoId
        self.collectorId = collectorId
        self.collectorName = collectorName
        self.reason = reason
        self.description = description
        self.evidenceUrl = evidenceUrl
        self.status = status
        self.createdAt = createdAt
    }
}
