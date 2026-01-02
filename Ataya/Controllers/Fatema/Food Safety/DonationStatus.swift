//
//  DonationStatus.swift
//  Ataya
//
//  Created by Fatema Maitham on 02/01/2026.
//


import Foundation
import FirebaseFirestore

enum DonationStatus: String {
    case pending
    case approved
    case rejected
}

struct DonationItem {
    let id: String
    let donationNumber: Int
    let donationCode: String
    let itemName: String

    let donorId: String
    let donorName: String
    let donorCity: String
    let donorEmail: String
    let donorPhone: String

    let ngoId: String
    let status: DonationStatus

    let imageUrl: String?
    let donorSafetyConfirmed: Bool

    let createdAt: Date
    let updatedAt: Date

    // UI helpers
    var titleText: String { "\(itemName) (\(donationCode))" }
    var donorText: String { "\(donorName) (ID: \(donorId))" }
    var locationText: String { donorCity }
    var dateText: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d yyyy"
        return f.string(from: createdAt)
    }

    init?(doc: DocumentSnapshot) {
        let data = doc.data() ?? [:]

        guard
            let ngoId = data["ngoId"] as? String,
            let donorId = data["donorId"] as? String,
            let itemName = data["itemName"] as? String,
            let statusStr = data["status"] as? String,
            let status = DonationStatus(rawValue: statusStr)
        else { return nil }

        let donationNumber =
            (data["donationNumber"] as? Int)
            ?? (data["donationNumber"] as? Int64).map(Int.init)
            ?? (data["donationNumber"] as? NSNumber)?.intValue
            ?? 0

        let donationCode = (data["donationCode"] as? String) ?? doc.documentID

        let donorName = (data["donorName"] as? String) ?? "—"
        let donorCity = (data["donorCity"] as? String) ?? "—"
        let donorEmail = (data["donorEmail"] as? String) ?? "—"
        let donorPhone = (data["donorPhone"] as? String) ?? "—"

        let donorSafetyConfirmed = (data["donorSafetyConfirmed"] as? Bool) ?? false

        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? createdAt

        self.id = doc.documentID
        self.ngoId = ngoId
        self.donorId = donorId
        self.itemName = itemName
        self.status = status

        self.donationNumber = donationNumber
        self.donationCode = donationCode

        self.donorName = donorName
        self.donorCity = donorCity
        self.donorEmail = donorEmail
        self.donorPhone = donorPhone

        self.imageUrl = data["imageUrl"] as? String
        self.donorSafetyConfirmed = donorSafetyConfirmed

        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct FoodInspection {
    let decision: String   // "none" / "accept" / "reject"
    let reason: String
    let description: String
    let collectorId: String
    let collectorName: String
    let evidenceUrl: String
    let inspectedAt: Date?

    init(map: [String: Any]) {
        self.decision = (map["decision"] as? String) ?? "none"
        self.reason = (map["reason"] as? String) ?? ""
        self.description = (map["description"] as? String) ?? ""
        self.collectorId = (map["collectorId"] as? String) ?? ""
        self.collectorName = (map["collectorName"] as? String) ?? ""
        self.evidenceUrl = (map["evidenceUrl"] as? String) ?? ""
        if let ts = map["inspectedAt"] as? Timestamp { self.inspectedAt = ts.dateValue() }
        else { self.inspectedAt = nil }
    }
}
