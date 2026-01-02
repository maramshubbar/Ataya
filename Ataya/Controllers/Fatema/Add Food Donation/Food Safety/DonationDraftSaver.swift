import Foundation
import FirebaseFirestore
import FirebaseAuth

final class DonationDraftSaver {

    static let shared = DonationDraftSaver()
    private init() {}

    func saveAfterPickup(draft: DraftDonation, completion: @escaping (Error?) -> Void) {

        let db = Firestore.firestore()

        guard let uid = Auth.auth().currentUser?.uid, !uid.isEmpty else {
            completion(NSError(domain: "Auth", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Not logged in"
            ]))
            return
        }

        // Confirm safety before saving
        draft.safetyConfirmed = true
        draft.normalizeBeforeSave()

        // pickup map (nested pickup only)
        let pickupMap = buildPickupDict(draft: draft)

        // ===== UPDATE existing =====
        if let existingId = draft.id,
           !existingId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            var data = draft.toFirestoreDict(isUpdate: true)
            data["id"] = existingId
            data["donorId"] = uid
            data["status"] = "pending"
            data["updatedAt"] = FieldValue.serverTimestamp()

            if let n = parseDonationNumber(from: existingId) {
                data["donationNumber"] = n
            }

            let ref = db.collection("donations").document(existingId)

            ref.setData(data, merge: true) { error in
                if let error { completion(error); return }
                ref.updateData(["pickup": pickupMap]) { err2 in
                    completion(err2)
                }
            }
            return
        }

        // ===== CREATE new =====
        reserveNextDonationNumber(db: db) { [weak self] result in
            guard let self else { return }

            switch result {
            case .failure(let err):
                completion(err)

            case .success(let number):
                let docId = "DON-\(number)"
                draft.id = docId

                var data = draft.toFirestoreDict(isUpdate: false)
                data["id"] = docId
                data["donationNumber"] = number
                data["donorId"] = uid
                data["status"] = "pending"
                data["createdAt"] = FieldValue.serverTimestamp()
                data["updatedAt"] = FieldValue.serverTimestamp()

                let ref = db.collection("donations").document(docId)

                ref.setData(data, merge: true) { error in
                    if let error { completion(error); return }
                    ref.updateData(["pickup": pickupMap]) { err2 in
                        completion(err2)
                    }
                }
            }
        }
    }

    private func buildPickupDict(draft: DraftDonation) -> [String: Any] {
        var pickup: [String: Any] = [:]
        if let d = draft.pickupDate { pickup["date"] = d }
        if let t = draft.pickupTime, !t.isEmpty { pickup["time"] = t }
        if !draft.pickupMethod.isEmpty { pickup["method"] = draft.pickupMethod }
        if let a = draft.pickupAddress { pickup["address"] = a.toFirestoreDict() }
        return pickup
    }

    private func parseDonationNumber(from id: String) -> Int? {
        let trimmed = id.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.uppercased().hasPrefix("DON-") {
            return Int(String(trimmed.dropFirst(4)))
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
