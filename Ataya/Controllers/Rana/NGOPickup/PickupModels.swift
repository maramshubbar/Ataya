//
//  PickupModels.swift
//  Ataya
//
//  Created by BP-36-224-09 on 29/12/2025.
//

import Foundation
import FirebaseFirestore

enum PickupStatus: String, Codable {
    case pending = "Pending"
    case accepted = "Accepted"
    case completed = "Completed"
}

struct PickupItem: Codable {
    var id: String?               // Firestore docId
    let pickupID: String

    let title: String
    let donor: String
    let location: String
    let date: String
    let imageName: String

    let itemName: String
    let quantity: String
    let category: String
    let expiryDate: String
    let notes: String
    let scheduledDate: String

    var status: PickupStatus
    let assignedNgoId: String

    var createdAt: Timestamp?
}

