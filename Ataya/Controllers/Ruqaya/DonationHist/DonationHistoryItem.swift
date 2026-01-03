//
//  DonationHistoryItem.swift
//  DonationHistory
//
//  Created by Ruqaya Habib on 31/12/2025.
//


import Foundation

enum DonationStatus: String {
    case completed = "Completed"
    case rejected  = "Rejected"
}

struct DonationHistoryItem {


    let title: String
    let ngoName: String
    let location: String
    let dateText: String
    let status: DonationStatus


    let donationId: String
    let quantity: String
    let category: String
    let expiryDate: String
    let packaging: String
    let allergenInfo: String

    let collectorName: String
    let assignedDate: String
    let pickupStatus: String
    let phone: String
    let email: String
    let collectorNotes: String

    let reviewDate: String
    let decision: String
    let remarks: String

    let imageName: String?
}


