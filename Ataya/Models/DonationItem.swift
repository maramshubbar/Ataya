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
        case pending
        case approved
        case rejected

        // للعرض في UI
        var displayText: String {
            switch self {
            case .pending: return "Pending"
            case .approved: return "Approved"
            case .rejected: return "Rejected"
            }
        }
    }
}


