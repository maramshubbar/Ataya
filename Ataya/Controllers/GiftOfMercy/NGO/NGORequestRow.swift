//
//  NGORequestRow.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//


import UIKit

// MARK: - Model (Dummy)
struct NGORequestRow {
    enum Status { case pending, sent }

    let id: String
    let giftName: String
    let donorName: String
    let dateText: String
    let status: Status
}
