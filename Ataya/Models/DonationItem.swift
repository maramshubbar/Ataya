//
//  DonationItem.swift
//  Ataya
//
//  Created by Maram on 18/12/2025.
//

import Foundation

struct DonationItem {

    enum Status: String {
        case pending, approved, rejected

        var displayText: String {
            switch self {
            case .pending:  return "Pending"
            case .approved: return "Approved"
            case .rejected: return "Rejected"
            }
        }
    }

    let docId: String
    let title: String
    let donorText: String
    let ngoText: String
    let locationText: String
    let dateText: String
    let imageUrl: String
    let status: Status
}
