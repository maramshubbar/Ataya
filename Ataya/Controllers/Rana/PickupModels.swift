//
//  PickupModels.swift
//  Ataya
//
//  Created by BP-36-224-09 on 29/12/2025.
//

import Foundation

enum PickupStatus: String {
    case pending = "Pending"
    case accepted = "Accepted"
    case completed = "Completed"
}

struct PickupItem {
    let pickupID: String

    // List screen
    let title: String
    let donor: String
    let location: String
    let date: String
    let imageName: String

    // Details screen
    let itemName: String
    let quantity: String
    let category: String
    let expiryDate: String
    let notes: String
    let scheduledDate: String

    var status: PickupStatus
}
