//
//  DonationDraftSaver.swift
//  Ataya
//
//  Created by Fatema Maitham on 02/01/2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class DonationDraftSaver {

    static let shared = DonationDraftSaver()
    private init() {}

    /// Save draft into Firestore donations/DON-x
    func saveAfterPickup(draft: DraftDonation, completion: @escaping (Error?) -> Void) {

        let db = Firestore.firestore()

        guard let uid = Auth.auth().currentUser?.uid, !uid.isEmpty else {
            completion(NSError(domain: "Auth", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Not logged in"
            ]))
            return
        }

        // ✅ work on mutable copy
        var draft = draft

        // ✅ if you have this field in DraftDonation keep it, otherwise delete this line
        draft.safetyConfirmed = true

        // =========================
        // UPDATE existing donation
        // =========================
        if let existingId = draft.id?.trimmingCharacters(in: .whitespacesAndNewlines),
           !existingId.isEmpty {

            var data = draft.toFirestoreDict()     // ✅ no args
            data["id"] = existingId
            data["donorId"] = uid
            data["status"] = "pending"
            data["updatedAt"] = FieldValue.serverTimestamp()

            if let n = parseDonationNumber(from: existingId) {
                data["donationNumber"] = n
            }

            db.collection("donations").document(existingId)
                .setData(data, merge: true) { error in
                    completion(error)
                }

            return
        }

        // =========================
        // CREATE new donation
        // =========================
        reserveNextDonationNumber(db: db) { result in
            switch result {
            case .failure(let err):
                completion(err)

            case .success(let number):
                let docId = "DON-\(number)"
                draft.id = docId

                var data = draft.toFirestoreDict()  // ✅ no args
                data["id"] = docId
                data["donationNumber"] = number
                data["donorId"] = uid
                data["status"] = "pending"
                data["createdAt"] = FieldValue.serverTimestamp()
                data["updatedAt"] = FieldValue.serverTimestamp()

                db.collection("donations").document(docId)
                    .setData(data, merge: true) { error in
                        completion(error)
                    }
            }
        }
    }

    private func parseDonationNumber(from id: String) -> Int? {
        let trimmed = id.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.uppercased().hasPrefix("DON-") {
            return Int(String(trimmed.dropFirst(4)))
        }
        return Int(trimmed)
    }

    // MARK: - Counter Transaction
    private func reserveNextDonationNumber(
        db: Firestore,
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        let counterRef = db.collection("counters").document("donations")

        db.runTransaction({ tx, errPtr -> Any? in
            let snap: DocumentSnapshot
            do {
                snap = try tx.getDocument(counterRef)
            } catch {
                errPtr?.pointee = error as NSError
                return nil
            }

            let raw = snap.data()?["next"]
            let currentNext =
                (raw as? Int)
                ?? (raw as? Int64).map(Int.init)
                ?? (raw as? NSNumber)?.intValue
                ?? 1

            tx.setData(["next": currentNext + 1], forDocument: counterRef, merge: true)
            return currentNext

        }, completion: { result, error in
            if let error {
                completion(.failure(error))
                return
            }

            let next =
                (result as? Int)
                ?? (result as? Int64).map(Int.init)
                ?? (result as? NSNumber)?.intValue
                ?? 1

            completion(.success(next))
        })
    }
}
