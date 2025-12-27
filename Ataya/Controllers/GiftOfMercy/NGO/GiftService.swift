// FILE: GiftService.swift

import Foundation
import FirebaseFirestore

final class GiftService {

    static let shared = GiftService()
    private init() {}

    private let db = Firestore.firestore()
    private var giftsRef: CollectionReference { db.collection("gifts") }

    // MARK: - LISTEN

    /// Realtime listener for gifts.
    /// If ngoId provided -> returns only that NGO's gifts.
    @discardableResult
    func listenGifts(
        ngoId: String?,
        completion: @escaping (Result<[Gift], Error>) -> Void
    ) -> ListenerRegistration {

        var q: Query = giftsRef

        if let ngoId, !ngoId.isEmpty {
            q = q.whereField(Gift.Keys.ngoId, isEqualTo: ngoId)
        }

        // Order newest first
        q = q.order(by: Gift.Keys.createdAt, descending: true)

        return q.addSnapshotListener { snap, err in
            if let err {
                completion(.failure(err))
                return
            }

            let items = snap?.documents.compactMap { Gift(doc: $0) } ?? []
            completion(.success(items))
        }
    }

    // MARK: - CREATE / UPDATE

    /// Creates or updates a gift document (merge).
    /// ✅ createdAt set only once (new docs)
    /// ✅ updatedAt always updated
    func upsertGift(_ gift: Gift, completion: @escaping (Error?) -> Void) {

        // IMPORTANT: ensure gift.id is valid
        guard !gift.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(NSError(
                domain: "GiftService",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Gift id is empty"]
            ))
            return
        }

        let docRef = giftsRef.document(gift.id)
        let data = gift.toFirestoreDict() // our Gift.swift already handles createdAt/updatedAt + pricing cleanup

        docRef.setData(data, merge: true, completion: completion)
    }

    // MARK: - QUICK UPDATES

    func setGiftActive(
        giftId: String,
        isActive: Bool,
        completion: @escaping (Error?) -> Void
    ) {
        giftsRef.document(giftId).updateData([
            Gift.Keys.isActive: isActive,
            Gift.Keys.updatedAt: FieldValue.serverTimestamp()
        ], completion: completion)
    }

    func deleteGift(
        giftId: String,
        completion: @escaping (Error?) -> Void
    ) {
        giftsRef.document(giftId).delete(completion: completion)
    }

    // MARK: - Single fetch (optional)

    func fetchGift(
        giftId: String,
        completion: @escaping (Result<Gift, Error>) -> Void
    ) {
        giftsRef.document(giftId).getDocument { snap, err in
            if let err { completion(.failure(err)); return }
            guard let snap, let gift = Gift(doc: snap) else {
                completion(.failure(NSError(
                    domain: "GiftService",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Gift not found"]
                )))
                return
            }
            completion(.success(gift))
        }
    }
}
