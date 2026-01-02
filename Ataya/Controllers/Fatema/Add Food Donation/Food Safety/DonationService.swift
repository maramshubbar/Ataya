//
//  DonationService 2.swift
//  Ataya
//
//  Created by Fatema Maitham on 02/01/2026.
//

import Foundation
import FirebaseFirestore

final class DonationService {

    static let shared = DonationService()
    private init() {}

    private let db = Firestore.firestore()

    // NGO Overview
    func listenNGODonations(ngoId: String, completion: @escaping ([DonationItem]) -> Void) -> ListenerRegistration {
        db.collection("donations")
            .whereField("ngoId", isEqualTo: ngoId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snap, _ in
                let items = snap?.documents.compactMap { DonationItem(doc: $0) } ?? []
                completion(items)
            }
    }

    func getDonation(donationId: String, completion: @escaping (DocumentSnapshot?) -> Void) {
        db.collection("donations").document(donationId).getDocument { doc, _ in
            completion(doc)
        }
    }

    // ✅ get user name (collector)
    func fetchUserName(uid: String, completion: @escaping (String) -> Void) {
        db.collection("users").document(uid).getDocument { snap, _ in
            let name = (snap?.data()?["name"] as? String) ?? "—"
            completion(name)
        }
    }

    // ✅ Feature 11 step 2 + 3 + 4 + 5 + 6 (transaction)
    func submitInspection(
        donationId: String,
        decision: String,   // "accept" / "reject"
        reason: String,
        description: String,
        collectorId: String,
        collectorName: String,
        evidenceUrl: String?,
        completion: @escaping (Error?) -> Void
    ) {
        let donationRef = db.collection("donations").document(donationId)

        // ✅ CHANGED: reports -> ngo-reports
        let reportRef = db.collection("ngo-reports").document()

        let analyticsRef = db.collection("analytics").document("foodSafety")
        let auditRef = donationRef.collection("audit").document()

        db.runTransaction({ tx, errPtr -> Any? in
            let donationSnap: DocumentSnapshot
            do {
                donationSnap = try tx.getDocument(donationRef)
            } catch {
                errPtr?.pointee = error as NSError
                return nil
            }

            let donationData = donationSnap.data() ?? [:]
            let donorId = (donationData["donorId"] as? String) ?? ""
            let donorName = (donationData["donorName"] as? String) ?? "—"
            let ngoId = (donationData["ngoId"] as? String) ?? ""

            let d = decision.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let newStatus: String = (d == "reject") ? "rejected" : "approved"

            var inspectionMap: [String: Any] = [
                "decision": d,
                "reason": reason,
                "description": description,
                "collectorId": collectorId,
                "collectorName": collectorName,
                "inspectedAt": FieldValue.serverTimestamp()
            ]
            if let evidenceUrl, !evidenceUrl.isEmpty {
                inspectionMap["evidenceUrl"] = evidenceUrl
            }

            // ✅ update donation
            tx.updateData([
                "status": newStatus,
                "inspection": inspectionMap,
                "updatedAt": FieldValue.serverTimestamp()
            ], forDocument: donationRef)

            // ✅ audit trail
            tx.setData([
                "action": "inspection_submitted",
                "decision": d,
                "reason": reason,
                "byId": collectorId,
                "byName": collectorName,
                "byRole": "collector",
                "createdAt": FieldValue.serverTimestamp()
            ], forDocument: auditRef)

            // ✅ analytics (SAFE حتى لو accept والـ reason فاضي)
            tx.setData([
                "totalInspections": FieldValue.increment(Int64(1)),
                "totalRejected": FieldValue.increment(Int64(d == "reject" ? 1 : 0))
            ], forDocument: analyticsRef, merge: true)

            // ✅ reasons count فقط إذا reject + key مو فاضي
            if d == "reject" {
                let trimmedReason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
                let reasonKey = Self.slug(trimmedReason)
                if !reasonKey.isEmpty {
                    tx.setData([
                        "reasons.\(reasonKey)": FieldValue.increment(Int64(1))
                    ], forDocument: analyticsRef, merge: true)
                }

                // ✅ if reject -> ngo-reports + trustScore decrement
                tx.setData([
                    "donationId": donationId,
                    "donorId": donorId,
                    "donorName": donorName,
                    "ngoId": ngoId,
                    "collectorId": collectorId,
                    "collectorName": collectorName,
                    "decision": "reject",
                    "reason": reason,
                    "description": description,
                    "evidenceUrl": evidenceUrl ?? "",
                    "status": "open",
                    "createdAt": FieldValue.serverTimestamp()
                ], forDocument: reportRef)

                if !donorId.isEmpty {
                    let donorRef = self.db.collection("users").document(donorId)
                    tx.setData([
                        "trustScore": FieldValue.increment(Int64(-10)),
                        "rejectedCount": FieldValue.increment(Int64(1))
                    ], forDocument: donorRef, merge: true)
                }
            }

            return nil
        }, completion: { _, error in
            completion(error)
        })
    }

    private static func slug(_ s: String) -> String {
        let lower = s.lowercased()
        let allowed = lower.map { ch -> Character in
            if ch.isLetter || ch.isNumber { return ch }
            return "_"
        }
        return String(allowed)
            .replacingOccurrences(of: "__", with: "_")
            .replacingOccurrences(of: "___", with: "_")
    }
}
