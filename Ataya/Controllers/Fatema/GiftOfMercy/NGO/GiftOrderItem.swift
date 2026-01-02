//
//  GiftOrderItem.swift
//  Ataya
//
//  Created by Fatema Maitham on 02/01/2026.
//


import Foundation
import FirebaseFirestore

struct GiftOrderItem {
    let id: String
    let donorId: String
    let ngoId: String

    let recipientName: String
    let recipientEmail: String
    let personalMessage: String
    let cardId: String

    let status: String          // "pending" or "sent"
    let createdAt: Date

    init(
        id: String,
        donorId: String,
        ngoId: String,
        recipientName: String,
        recipientEmail: String,
        personalMessage: String,
        cardId: String,
        status: String,
        createdAt: Date
    ) {
        self.id = id
        self.donorId = donorId
        self.ngoId = ngoId
        self.recipientName = recipientName
        self.recipientEmail = recipientEmail
        self.personalMessage = personalMessage
        self.cardId = cardId
        self.status = status
        self.createdAt = createdAt
    }

    // Firestore -> Model
    init?(doc: QueryDocumentSnapshot) {
        let d = doc.data()

        guard
            let id = d["id"] as? String,
            let donorId = d["donorId"] as? String,
            let ngoId = d["ngoId"] as? String,
            let recipientName = d["recipientName"] as? String,
            let recipientEmail = d["recipientEmail"] as? String,
            let personalMessage = d["personalMessage"] as? String,
            let cardId = d["cardId"] as? String,
            let status = d["status"] as? String
        else { return nil }

        self.id = id
        self.donorId = donorId
        self.ngoId = ngoId
        self.recipientName = recipientName
        self.recipientEmail = recipientEmail
        self.personalMessage = personalMessage
        self.cardId = cardId
        self.status = status

        self.createdAt = (d["createdAt"] as? Timestamp)?.dateValue() ?? Date()
    }

    // Model -> Firestore
    func toDict() -> [String: Any] {
        return [
            "id": id,
            "donorId": donorId,
            "ngoId": ngoId,
            "recipientName": recipientName,
            "recipientEmail": recipientEmail,
            "personalMessage": personalMessage,
            "cardId": cardId,
            "status": status,
            "createdAt": FieldValue.serverTimestamp()
        ]
    }
}
