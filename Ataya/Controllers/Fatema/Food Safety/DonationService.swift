//
//  DonationService.swift
//  Ataya
//
//  Created by Fatema Maitham on 02/01/2026.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

final class DonationService {

    static let shared = DonationService()
    private init() {}

    private let db = Firestore.firestore()

    // ✅ Listen NGO donations (Overview)
    func listenNGODonations(ngoId: String, completion: @escaping ([DonationItem]) -> Void) -> ListenerRegistration {
        return db.collection("donations")
            .whereField("ngoId", isEqualTo: ngoId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snap, _ in
                let items = snap?.documents.compactMap { DonationItem(doc: $0) } ?? []
                completion(items)
            }
    }

    // ✅ Get full donation doc for Details/Inspect
    func getDonation(donationId: String, completion: @escaping (DocumentSnapshot?) -> Void) {
        db.collection("donations").document(donationId).getDocument { doc, _ in
            completion(doc)
        }
    }

    // ✅ Submit inspection (Accept/Reject) + Report + TrustScore + Analytics + Audit
    func submitInspection(
        donationId: String,
        decision: String, // "accept" or "reject"
        reason: String,
        description: String,
        collectorId: String,
        collectorName: String,
        evidenceUrl: String?,
        completion: @escaping (Error?) -> Void
    ) {
        let donationRef = db.collection("donations").document(donationId)
        let reportRef = db.collection("reports").document() // auto id
        let analyticsRef = db.collection("analytics").document("foodSafety")
        let auditRef = donationRef.collection("audit").document()

        db.runTransaction({ tx, errPtr -> Any? in

            guard let donationSnap = try? tx.getDocument(donationRef),
                  let donationData = donationSnap.data()
            else {
                errPtr?.pointee = NSError(domain: "Donation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Donation not found"])
                return nil
            }

            let donorId = (donationData["donorId"] as? String) ?? ""
            let donorName = (donationData["donorName"] as? String) ?? ""
            let ngoId = (donationData["ngoId"] as? String) ?? ""

            // ✅ update donation status
            let newStatus: String = (decision == "reject") ? "rejected" : "approved"

            var inspectionMap: [String: Any] = [
                "decision": decision,
                "reason": reason,
                "description": description,
                "collectorId": collectorId,
                "collectorName": collectorName,
                "inspectedAt": FieldValue.serverTimestamp()
            ]
            if let evidenceUrl, !evidenceUrl.isEmpty {
                inspectionMap["evidenceUrl"] = evidenceUrl
            }

            tx.updateData([
                "status": newStatus,
                "inspection": inspectionMap,
                "updatedAt": FieldValue.serverTimestamp()
            ], forDocument: donationRef)

            // ✅ audit trail (subcollection)
            tx.setData([
                "action": "inspection_submitted",
                "decision": decision,
                "reason": reason,
                "byId": collectorId,
                "byName": collectorName,
                "byRole": "collector",
                "createdAt": FieldValue.serverTimestamp()
            ], forDocument: auditRef)

            // ✅ analytics counters
            let reasonKey = Self.slug(reason)
            tx.setData([
                "totalInspections": FieldValue.increment(Int64(1)),
                "totalRejected": FieldValue.increment(Int64(decision == "reject" ? 1 : 0)),
                "reasons.\(reasonKey)": FieldValue.increment(Int64(decision == "reject" ? 1 : 0))
            ], forDocument: analyticsRef, merge: true)

            // ✅ if reject → create report + reduce trustScore
            if decision == "reject" {
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
                    // trustScore decrement (مثال: -10)
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

    // helper: reason -> safe key
    private static func slug(_ s: String) -> String {
        let lower = s.lowercased()
        let allowed = lower.map { ch -> Character in
            if ch.isLetter || ch.isNumber { return ch }
            return "_"
        }
        // remove repeating underscores roughly
        return String(allowed).replacingOccurrences(of: "__", with: "_")
    }
}
