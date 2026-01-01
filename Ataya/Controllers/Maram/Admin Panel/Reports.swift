//
//  Reports.swift
//  Ataya
//
//  Created by Maram on 18/12/2025.
//
import Foundation

struct Report {
    let title: String
    let location: String
    let reporter: String
    let ngo: String
    let dateText: String
    let status: Status

    enum Status: String {
        case pending  = "Pending"
        case resolved = "Resolved"
    }
}
