//
//  DonationItem.swift
//  Ataya
//
//  Created by Maram on 18/12/2025.
//

import Foundation

struct DonationItem {
    let title: String
    let donorText: String
    let ngoText: String
    let locationText: String
    let dateText: String
    let imageName: String
    let status: Status

    enum Status: String {
        case pending = "Pending"
        case approved = "Approved"
        case rejected = "Rejected"
    }
}

