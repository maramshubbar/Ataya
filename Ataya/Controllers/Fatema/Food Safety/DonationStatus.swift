//
//  DonationStatus.swift
//  Ataya
//
//  Created by Fatema Maitham on 02/01/2026.
//


import Foundation
import FirebaseFirestore


extension DonationItem {

    init?(doc: DocumentSnapshot) {
        let data = doc.data() ?? [:]

        let itemName  = (data["itemName"] as? String) ?? "—"
        let code      = (data["donationCode"] as? String) ?? doc.documentID

        let donorName = (data["donorName"] as? String) ?? "—"
        let donorId   = (data["donorId"] as? String) ?? "—"
        let city      = (data["donorCity"] as? String) ?? "—"

        let statusStr = (data["status"] as? String) ?? "pending"
        guard let st = DonationItem.Status(rawValue: statusStr) else { return nil }

        let created = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let f = DateFormatter()
        f.dateFormat = "MMM d yyyy"

        let img = (data["imageUrl"] as? String) ?? ""

        self.docId = doc.documentID
        self.title = "\(itemName) (\(code))"
        self.donorText = "\(donorName) (ID: \(donorId))"
        self.ngoText = ""
        self.locationText = city
        self.dateText = f.string(from: created)
        self.imageUrl = img
        self.status = st
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
