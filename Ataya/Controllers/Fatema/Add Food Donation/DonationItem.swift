//
//  DonationItem.swift
//  Ataya
//
//  Created by Maram on 18/12/2025.
//

import Foundation

struct DonationItem {

    enum Status: String {
        case pending  = "Pending"
        case approved = "Approved"
        case rejected = "Rejected"
    }

    let title: String
    let donorText: String
    let locationText: String
    let dateText: String
    let status: Status
    let imageName: String
}

