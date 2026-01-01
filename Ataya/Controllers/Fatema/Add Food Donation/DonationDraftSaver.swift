//
//  DonationDraftSaver.swift
//  Ataya
//
//  Created by Fatema Maitham on 01/01/2026.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

final class DonationDraftSaver {

    static let shared = DonationDraftSaver()
    private init() {}

    func saveAfterPickup(draft: DraftDonation, completion: @escaping (Error?) -> Void) {

        let db = Firestore.firestore()

        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not logged in"]))
            return
        }

        draft.safetyConfirmed = true

        // إذا عنده ID مسبقًا -> Update
        if let existingId = draft.id, !existingId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            var data = draft.toFirestoreDict()
            data["id"] = existingId
            data["donorId"] = uid
            data["status"] = "pending"
            data["updatedAt"] = FieldValue.serverTimestamp()
            data["pickup"] = buildPickupDict(draft: draft)

            if let n = parseDonationNumber(from: existingId) {
                data["donationNumber"] = n
            }

            db.collection("donations").document(existingId).setData(data, merge: true) { error in
                completion(error)
            }
            return
        }

        // NEW -> احجز DON-xx ثم Create
        reserveNextDonationNumber(db: db) { result in
            switch result {
            case .failure(let err):
                completion(err)

            case .success(let number):
                let docId = "DON-\(number)"
                draft.id = docId

                var data = draft.toFirestoreDict()
                data["id"] = docId
                data["donationNumber"] = number
                data["donorId"] = uid
                data["status"] = "pending"
                data["createdAt"] = FieldValue.serverTimestamp()
                data["updatedAt"] = FieldValue.serverTimestamp()
                data["pickup"] = self.buildPickupDict(draft: draft)

                db.collection("donations").document(docId).setData(data, merge: true) { error in
                    completion(error)
                }
            }
        }
    }

    private func buildPickupDict(draft: DraftDonation) -> [String: Any] {
        var pickup: [String: Any] = [:]

        if let d = draft.pickupDate { pickup["date"] = d }
        if let t = draft.pickupTime { pickup["time"] = t }
        if !draft.pickupMethod.isEmpty { pickup["method"] = draft.pickupMethod }

        if let a = draft.pickupAddress {
            pickup["address"] = a.toDict()
        }

        return pickup
    }

    private func parseDonationNumber(from id: String) -> Int? {
        let trimmed = id.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.uppercased().hasPrefix("DON-") {
            let numPart = String(trimmed.dropFirst(4))
            return Int(numPart)
        }
        return Int(trimmed)
    }

    private func reserveNextDonationNumber(
        db: Firestore,
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        let counterRef = db.collection("counters").document("donations")

        db.runTransaction({ (tx, errorPointer) -> Any? in
            let snap: DocumentSnapshot
            do {
                snap = try tx.getDocument(counterRef)
            } catch let err {
                errorPointer?.pointee = err as NSError
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
