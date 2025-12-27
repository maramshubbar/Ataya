//
//  CardDesignService.swift
//  Ataya
//
//  Created by Fatema Maitham on 27/12/2025.
//


import Foundation
import FirebaseFirestore

final class CardDesignService {

    static let shared = CardDesignService()
    private init() {}

    private let db = Firestore.firestore()
    private var ref: CollectionReference { db.collection("cardDesigns") }

    // ✅ Live listener
    func listenDesigns(ngoId: String?, completion: @escaping (Result<[CardDesign], Error>) -> Void) -> ListenerRegistration {

        var q: Query = ref.order(by: "createdAt", descending: true)

        if let ngoId, !ngoId.isEmpty {
            q = q.whereField("ngoId", isEqualTo: ngoId)
        }

        return q.addSnapshotListener { snap, err in
            if let err { completion(.failure(err)); return }
            let items = snap?.documents.compactMap { CardDesign(doc: $0) } ?? []
            completion(.success(items))
        }
    }

    // ✅ Create/Update
    func upsertDesign(_ design: CardDesign, completion: @escaping (Error?) -> Void) {
        var data = design.toFirestoreDict()
        data["updatedAt"] = FieldValue.serverTimestamp()

        // createdAt only once
        if design.createdAt == nil {
            data["createdAt"] = FieldValue.serverTimestamp()
        }

        ref.document(design.id).setData(data, merge: true, completion: completion)
    }

    // ✅ Delete (اختياري)
    func deleteDesign(id: String, completion: @escaping (Error?) -> Void) {
        ref.document(id).delete(completion: completion)
    }

    // ✅ Make ONE default only (Transaction)
    func setDefault(designId: String, completion: @escaping (Error?) -> Void) {
        db.runTransaction({ txn, errPtr -> Any? in
            let all = try txn.getDocuments(self.ref)

            // set all to false
            for doc in all.documents {
                txn.updateData(["isDefault": false], forDocument: doc.reference)
            }

            // set chosen to true
            txn.updateData(["isDefault": true], forDocument: self.ref.document(designId))
            return nil
        }, completion: { _, error in
            completion(error)
        })
    }
}
