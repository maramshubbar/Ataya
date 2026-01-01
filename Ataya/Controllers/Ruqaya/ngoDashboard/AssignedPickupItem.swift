//
//  AssignedPickupModel.swift
//  Ataya
//
//  Created by Ruqaya Habib on 30/12/2025.
//

import Foundation

struct AssignedPickupItem {

    // ✅ Dashboard fields (لازم يكونون أول وبنفس ترتيب الinit)
    let title: String
    let donor: String
    let location: String
    let status: String
    let imageName: String

    // ✅ Details page fields
    let donationId: String
    let itemName: String
    let quantity: String
    let category: String
    let expiryDate: String
    let packaging: String
    let allergenInfo: String

    let donorName: String
    let contactNumber: String
    let email: String
    let donorLocation: String

    let scheduledDate: String
    let pickupWindow: String
    let distance: String
    let estimatedTime: String
    let donorNotes: String
}



