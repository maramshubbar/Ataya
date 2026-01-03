//
//  GiftCertificateModels.swift
//  Ataya
//
//  Keep ONLY this file for GiftCertificate models to avoid duplicates
//

import Foundation
import FirebaseFirestore

// MARK: - Status

enum GiftCertificateOrderStatus: String, Codable {
    case pending, approved, rejected, sent

    static func fromFirestore(_ data: [String: Any]) -> GiftCertificateOrderStatus {
        // 1) explicit status string
        if let s = (data["status"] as? String)?.lowercased(),
           let st = GiftCertificateOrderStatus(rawValue: s) {
            return st
        }

        // 2) fallbacks
        if let isSent = data["isSent"] as? Bool, isSent { return .sent }
        if data["sentAt"] != nil { return .sent }
        if data["approvedAt"] != nil { return .approved }
        if data["rejectedAt"] != nil { return .rejected }

        return .pending
    }
}

// MARK: - Recipient

struct GiftCertificateRecipient: Codable {
    let name: String
    let email: String

    static func fromFirestore(_ raw: Any?) -> GiftCertificateRecipient {
        guard let dict = raw as? [String: Any] else {
            return .init(name: "", email: "")
        }

        let name =
            (dict["name"] as? String) ??
            (dict["fullName"] as? String) ??
            (dict["recipientName"] as? String) ?? ""

        let email =
            (dict["email"] as? String) ??
            (dict["recipientEmail"] as? String) ?? ""

        return .init(name: name, email: email)
    }
}

// MARK: - Order

struct GiftCertificateOrder: Identifiable {
    let id: String

    let amount: Double
    let currency: String

    let cardDesignId: String
    let cardDesignTitle: String

    let createdAt: Timestamp?
    let createdByUid: String

    let fromName: String
    let message: String

    let giftId: String
    let giftTitle: String

    let pricingMode: String
    let recipient: GiftCertificateRecipient

    let status: GiftCertificateOrderStatus

    static func fromFirestore(docId: String, data: [String: Any]) -> GiftCertificateOrder? {

        let amount = readDouble(data["amount"]) ?? 0

        return GiftCertificateOrder(
            id: docId,
            amount: amount,
            currency: (data["currency"] as? String) ?? "BHD",
            cardDesignId: (data["cardDesignId"] as? String) ?? "",
            cardDesignTitle: (data["cardDesignTitle"] as? String) ?? "",
            createdAt: data["createdAt"] as? Timestamp,
            createdByUid: (data["createdByUid"] as? String) ?? "",
            fromName: (data["fromName"] as? String) ?? "",
            message: (data["message"] as? String) ?? "",
            giftId: (data["giftId"] as? String) ?? "",
            giftTitle: (data["giftTitle"] as? String) ?? "",
            pricingMode: (data["pricingMode"] as? String) ?? "fixed",
            recipient: GiftCertificateRecipient.fromFirestore(data["recipient"]),
            status: GiftCertificateOrderStatus.fromFirestore(data)
        )
    }

    private static func readDouble(_ value: Any?) -> Double? {
        if let d = value as? Double { return d }
        if let i = value as? Int { return Double(i) }
        if let n = value as? NSNumber { return n.doubleValue }
        if let s = value as? String, let d = Double(s) { return d }
        return nil
    }
}
