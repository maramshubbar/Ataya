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
}


