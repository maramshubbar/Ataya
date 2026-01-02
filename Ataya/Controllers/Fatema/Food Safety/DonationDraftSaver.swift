import Foundation
import FirebaseFirestore
import FirebaseAuth

final class DonationDraftSaver {

    static let shared = DonationDraftSaver()
    private init() {}

    func saveAfterPickup(draft: DraftDonation, completion: @escaping (Error?) -> Void) {

        let db = Firestore.firestore()

        guard let uid = Auth.auth().currentUser?.uid, !uid.isEmpty else {
            completion(NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not logged in"]))
            return
        }

        let isUpdate = (draft.id?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)

        // ✅ your DraftDonation expects isUpdate
        var base = draft.toFirestoreDict(isUpdate: isUpdate)

        // pickup (إذا موجود داخل الدكت)
        let pickupMap = extractPickupMap(from: base)

        // ===== UPDATE existing =====
        if isUpdate, let existingId = draft.id {

            base["id"] = existingId
            base["donorId"] = uid
            base["status"] = "pending"
            base["updatedAt"] = FieldValue.serverTimestamp()

            if let n = parseDonationNumber(from: existingId) {
                base["donationNumber"] = n
                base["donationCode"] = "DON-\(n)"
            }

            let ref = db.collection("donations").document(existingId)

            ref.setData(base, merge: true) { error in
                if let error { completion(error); return }

                if let pickupMap {
                    ref.updateData(["pickup": pickupMap]) { err2 in completion(err2) }
                } else {
                    completion(nil)
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

                base["id"] = docId
                base["donationNumber"] = number
                base["donationCode"] = docId
                base["donorId"] = uid
                base["status"] = "pending"
                base["createdAt"] = FieldValue.serverTimestamp()
                base["updatedAt"] = FieldValue.serverTimestamp()

                let ref = db.collection("donations").document(docId)

                ref.setData(base, merge: true) { error in
                    if let error { completion(error); return }

                    if let pickupMap {
                        ref.updateData(["pickup": pickupMap]) { err2 in completion(err2) }
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }

    // MARK: - Pickup extractor (NO DraftDonation props needed)
    private func extractPickupMap(from base: [String: Any]) -> [String: Any]? {

        if let pickup = base["pickup"] as? [String: Any], !pickup.isEmpty {
            return pickup
        }

        var pickup: [String: Any] = [:]

        if let d = base["pickupDate"] { pickup["date"] = d }
        if let t = base["pickupTime"] as? String, !t.isEmpty { pickup["time"] = t }
        if let m = base["pickupMethod"] as? String, !m.isEmpty { pickup["method"] = m }

        if let addr = base["pickupAddress"] as? [String: Any], !addr.isEmpty {
            pickup["address"] = addr
        }

        return pickup.isEmpty ? nil : pickup
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
