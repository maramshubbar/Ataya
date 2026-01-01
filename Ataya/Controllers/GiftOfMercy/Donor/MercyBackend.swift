//
//  MercyBackend.swift
//  Ataya
//
//  Created by Fatema Maitham on 29/12/2025.
//

import Foundation
import FirebaseFirestore

enum MercyBackend {

    static func listenActiveGifts(
        completion: @escaping (Result<[MercyGift], Error>) -> Void
    ) -> ListenerRegistration {

        let db = Firestore.firestore()

        let query = db.collection("gifts")
            .whereField("isActive", isEqualTo: true)

        return query.addSnapshotListener { snap, err in
            if let err {
                completion(.failure(err))
                return
            }

            let docs = snap?.documents ?? []
            let items = docs.compactMap { MercyGift($0) }
            completion(.success(items))
        }
    }

    static func submitGiftCertificate(
        request: GiftCertificateRequest,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let db = Firestore.firestore()

        // ✅ يعطيج docId حقيقي
        let ref = db.collection("giftCertificates").document()

        ref.setData(request.toFirestoreData()) { err in
            if let err {
                completion(.failure(err))
            } else {
                completion(.success(ref.documentID))
            }
        }
    }
}
