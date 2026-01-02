//
//  PickupModels.swift
//  Ataya
//
//  Created by BP-36-224-09 on 29/12/2025.
//
import Foundation
import FirebaseFirestore

enum PickupStatus: String {
    case pending = "Pending"
    case accepted = "Accepted"
    case completed = "Completed"
}

struct PickupItem {

    // Firestore doc id (internal)
    var id: String?

    // Main
    let pickupID: String
    let title: String
    let donor: String
    let location: String
    let date: String
    let imageName: String?

    // Details
    let itemName: String
    let quantity: String
    let category: String
    let expiryDate: String
    let notes: String
    let scheduledDate: String

    // Status
    var status: PickupStatus
    let assignedNgoId: String

    // Meta
    let createdAt: Timestamp?

    // ✅ SAFE initializer (won't fail بسبب pickupID)
    init?(doc: QueryDocumentSnapshot) {
        let data = doc.data()

        // required fields (الموجودة عندك)
        guard
            let title = data["title"] as? String,
            let donor = data["donor"] as? String,
            let location = data["location"] as? String,
            let itemName = data["itemName"] as? String,
            let quantity = data["quantity"] as? String,
            let category = data["category"] as? String,
            let expiryDate = data["expiryDate"] as? String,
            let statusRaw = data["status"] as? String,
            let status = PickupStatus(rawValue: statusRaw),
            let assignedNgoId = data["assignedNgoId"] as? String
        else {
            print("❌ Invalid pickup document:", doc.documentID, "data:", data)
            return nil
        }

        self.id = doc.documentID

        // ✅ pickupID: إذا ما موجود في الفايرستور خليه documentID
        self.pickupID = (data["pickupID"] as? String) ?? doc.documentID

        self.title = title
        self.donor = donor
        self.location = location
        self.itemName = itemName
        self.quantity = quantity
        self.category = category
        self.expiryDate = expiryDate
        self.status = status
        self.assignedNgoId = assignedNgoId

        // optional / safe
        self.imageName = data["imageName"] as? String
        self.notes = data["notes"] as? String ?? ""

        // عندك الاثنين في الفايرستور: date و scheduledDate
        self.date = (data["date"] as? String) ?? (data["scheduledDate"] as? String) ?? ""
        self.scheduledDate = (data["scheduledDate"] as? String) ?? (data["date"] as? String) ?? ""

        self.createdAt = data["createdAt"] as? Timestamp
    }
}
