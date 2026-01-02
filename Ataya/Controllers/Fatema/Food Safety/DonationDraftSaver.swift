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

        // ✅ 1) base dict from your DraftDonation (NO arguments)
        var base = draft.toFirestoreDict()

        // ✅ 2) donor safety (if your DraftDonation has it)
        // (إذا ما عندج draft.safetyConfirmed لا تلمسينه)
        base["donorSafetyConfirmed"] = base["donorSafetyConfirmed"] ?? true

        // ✅ 3) pickup map (try to extract from dict only)
        let pickupMap = extractPickupMap(from: base)

        // ✅ 4) Fetch donor info then save (so NGO screens show name/city)
        fetchDonorInfo(db: db, uid: uid) { donorInfo, fetchErr in
            if let fetchErr { completion(fetchErr); return }

            // ===== UPDATE existing =====
            if let existingId = (base["id"] as? String), !existingId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                base["id"] = existingId
                base["donorId"] = uid
                base["status"] = "pending"
                base["updatedAt"] = FieldValue.serverTimestamp()

                // merge donor info snapshot
                base.merge(donorInfo) { _, new in new }

                if let n = self.parseDonationNumber(from: existingId) {
                    base["donationNumber"] = n
                    base["donationCode"] = "DON-\(n)"
                }

                let ref = db.collection("donations").document(existingId)

                ref.setData(base, merge: true) { error in
                    if let error { completion(error); return }

                    // overwrite pickup فقط إذا موجود
                    if let pickupMap {
                        ref.updateData(["pickup": pickupMap]) { err2 in completion(err2) }
                    } else {
                        completion(nil)
                    }
                }
                return
            }

            // ===== CREATE new =====
            self.reserveNextDonationNumber(db: db) { result in
                switch result {
                case .failure(let err):
                    completion(err)

                case .success(let number):
                    let docId = "DON-\(number)"

                    base["id"] = docId
                    base["donationNumber"] = number
                    base["donationCode"] = docId
                    base["donorId"] = uid
                    base["status"] = "pending"
                    base["createdAt"] = FieldValue.serverTimestamp()
                    base["updatedAt"] = FieldValue.serverTimestamp()

                    // merge donor info snapshot
                    base.merge(donorInfo) { _, new in new }

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
    }

    // MARK: - Donor Info
    private func fetchDonorInfo(
        db: Firestore,
        uid: String,
        completion: @escaping ([String: Any], Error?) -> Void
    ) {
        db.collection("users").document(uid).getDocument { snap, err in
            if let err { completion([:], err); return }

            let u = snap?.data() ?? [:]
            let name  = (u["name"] as? String) ?? "—"
            let city  = (u["city"] as? String) ?? "—"
            let phone = (u["phone"] as? String) ?? "—"
            let email = (u["email"] as? String) ?? (Auth.auth().currentUser?.email ?? "—")

            completion([
                "donorName": name,
                "donorCity": city,
                "donorPhone": phone,
                "donorEmail": email
            ], nil)
        }
    }

    // MARK: - Pickup extractor (NO DraftDonation properties)
    private func extractPickupMap(from base: [String: Any]) -> [String: Any]? {

        // 1) إذا draft.toFirestoreDict() أصلاً فيه pickup جاهز
        if let pickup = base["pickup"] as? [String: Any], !pickup.isEmpty {
            return pickup
        }

        // 2) إذا مخزّن مفصول keys (اختياري)
        var pickup: [String: Any] = [:]

        if let d = base["pickupDate"] { pickup["date"] = d }
        if let t = base["pickupTime"] as? String, !t.isEmpty { pickup["time"] = t }
        if let m = base["pickupMethod"] as? String, !m.isEmpty { pickup["method"] = m }

        // address ممكن يكون dict جاهز
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
