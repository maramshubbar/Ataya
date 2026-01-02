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

    func saveAfterPickup(draft: DraftDonation, completion: @escaping (Error?) -> Void) {

        let db = Firestore.firestore()

        guard let uid = Auth.auth().currentUser?.uid, !uid.isEmpty else {
            completion(NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not logged in"]))
            return
        }

        // ✅ IMPORTANT:
        // لا تخلينه دايم true اذا عندج checkbox
        // خليه يجي من الـ UI (مثلاً draft.safetyConfirmed = checkbox.isOn)
        // draft.safetyConfirmed = true

        // ✅ normalize now (important)
        draft.normalizeBeforeSave()

        // ✅ pickup map ONLY pickup fields
        let pickupMap = buildPickupDict(draft: draft)

        // ✅ 0) Fetch donor info from users/{uid} (مرة وحدة قبل الحفظ)
        fetchDonorInfo(db: db, uid: uid) { donorInfo, fetchErr in
            if let fetchErr {
                completion(fetchErr)
                return
            }

            // ===== UPDATE existing =====
            if let existingId = draft.id, !existingId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                var data = draft.toFirestoreDict(isUpdate: true)
                data["id"] = existingId
                data["donorId"] = uid
                data["status"] = "pending"
                data["updatedAt"] = FieldValue.serverTimestamp()

                // ✅ save donor safety (Feature 11 step 1)
                data["donorSafetyConfirmed"] = draft.safetyConfirmed

                // ✅ donor info for NGO details (from Firebase)
                data.merge(donorInfo) { _, new in new }

                // ✅ donationNumber
                if let n = parseDonationNumber(from: existingId) {
                    data["donationNumber"] = n
                    data["donationCode"] = "DON-\(n)" // for UI
                }

                let ref = db.collection("donations").document(existingId)

                // 1) set top-level fields
                ref.setData(data, merge: true) { error in
                    if let error { completion(error); return }

                    // 2) overwrite pickup بالكامل
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

                    // ✅ keep your int for sorting + add code string for display
                    data["donationNumber"] = number
                    data["donationCode"] = docId

                    data["donorId"] = uid

                    // ✅ Feature 11 step 1
                    data["donorSafetyConfirmed"] = draft.safetyConfirmed

                    data["status"] = "pending"
                    data["createdAt"] = FieldValue.serverTimestamp()
                    data["updatedAt"] = FieldValue.serverTimestamp()

                    // ✅ donor info for NGO screens (from Firebase)
                    data.merge(donorInfo) { _, new in new }

                    let ref = db.collection("donations").document(docId)

                    ref.setData(data, merge: true) { error in
                        if let error { completion(error); return }

                        // overwrite pickup بالكامل
                        ref.updateData(["pickup": pickupMap]) { err2 in
                            completion(err2)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Donor Info (from users/{uid})
    private func fetchDonorInfo(
        db: Firestore,
        uid: String,
        completion: @escaping ([String: Any], Error?) -> Void
    ) {
        db.collection("users").document(uid).getDocument { snap, err in
            if let err { completion([:], err); return }

            let u = snap?.data() ?? [:]

            let name = (u["name"] as? String) ?? "—"
            let city = (u["city"] as? String) ?? "—"
            let phone = (u["phone"] as? String) ?? "—"
            let email = (u["email"] as? String) ?? (Auth.auth().currentUser?.email ?? "—")

            // ✅ هذه الحقول بتستخدمينها في Donation Details (Donor Information card)
            let map: [String: Any] = [
                "donorName": name,
                "donorCity": city,
                "donorPhone": phone,
                "donorEmail": email
            ]
            completion(map, nil)
        }
    }

    // MARK: - Pickup map
    private func buildPickupDict(draft: DraftDonation) -> [String: Any] {
        var pickup: [String: Any] = [:]
        if let d = draft.pickupDate { pickup["date"] = d }
        if let t = draft.pickupTime, !t.isEmpty { pickup["time"] = t }
        if !draft.pickupMethod.isEmpty { pickup["method"] = draft.pickupMethod }
        if let a = draft.pickupAddress { pickup["address"] = a.toDict() }
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
