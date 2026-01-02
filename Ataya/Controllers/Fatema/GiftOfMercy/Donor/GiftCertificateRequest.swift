//
//  GiftCertificateRequest.swift
//  Ataya
//
//  Created by Fatema Maitham on 31/12/2025.
//


import Foundation
import FirebaseFirestore

struct GiftCertificateRequest {
    let giftId: String
    let giftTitle: String
    let amount: Decimal
    let currency: String

    let pricingMode: MercyGift.PricingMode

    let cardDesignId: String
    let cardDesignTitle: String

    let fromName: String
    let message: String

    let recipientName: String
    let recipientEmail: String

    let createdByUid: String?   // optional
    let createdAt: Timestamp?   // set by server timestamp

    func toFirestoreData() -> [String: Any] {
        return [
            "giftId": giftId,
            "giftTitle": giftTitle,
            "amount": (amount as NSDecimalNumber).doubleValue,
            "currency": currency,
            "pricingMode": pricingMode.rawValue,

            "cardDesignId": cardDesignId,
            "cardDesignTitle": cardDesignTitle,

            "fromName": fromName,
            "message": message,

            "recipient": [
                "name": recipientName,
                "email": recipientEmail
            ],

            "createdByUid": createdByUid as Any,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ]
    }
}
