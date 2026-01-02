//
//  Donation.swift
//  Ataya
//
//  Created by Fatema Maitham on 18/12/2025.
//


import Foundation

struct Donation {
    enum Status: String {
        case pending = "Pending"
        case accepted = "Accepted"
        case rejected = "Rejected"
    }

    let title: String
    let donor: String
    let location: String
    let dateText: String
    let status: Status
    let imageName: String
}
