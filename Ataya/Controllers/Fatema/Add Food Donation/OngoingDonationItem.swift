//
//  OngoingDonationItem.swift
//  Ataya
//
//  Created by Fatema Maitham on 03/01/2026.
//


import Foundation
import FirebaseFirestore

struct OngoingDonationItem {

    let id: String
    let title: String
    let ngoName: String
    let statusText: String    
    let imageUrl: String?
    let updatedAt: Date?

    static func fromFirestore(docId: String, data: [String: Any]) -> OngoingDonationItem {

        let id = (data["id"] as? String) ?? docId

        let title = (data["itemName"] as? String)
        ?? (data["title"] as? String)
        ?? "—"

        let ngoName = (data["ngoName"] as? String)
        ?? (data["ngo_name"] as? String)
        ?? "—"

        let rawStatus = ((data["status"] as? String) ?? "pending").lowercased()

        // ✅ خلي النص يطابق اللي السيل تتوقعه (Ready Pickup / In Progress / Completed)
        let statusText: String
        switch rawStatus {
        case "approved", "ready_pickup", "ready pickup":
            statusText = "Ready Pickup"
        case "completed", "done":
            statusText = "Completed"
        case "rejected":
            statusText = "Rejected"
        default:
            statusText = "In Progress"
        }

        // صور Cloudinary: photoURLs array
        var imageUrl: String? = nil
        if let urls = data["photoURLs"] as? [String], let first = urls.first, !first.isEmpty {
            imageUrl = first
        } else if let single = data["photoURL"] as? String, !single.isEmpty {
            imageUrl = single
        }

        let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
        ?? (data["createdAt"] as? Timestamp)?.dateValue()

        return OngoingDonationItem(
            id: id,
            title: title,
            ngoName: ngoName,
            statusText: statusText,
            imageUrl: imageUrl,
            updatedAt: updatedAt
        )
    }
}
