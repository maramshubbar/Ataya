//
//  CardDesignService.swift
//  Ataya
//

import Foundation
import FirebaseFirestore

final class CardDesignService {

    static let shared = CardDesignService()
    private init() {}

    private let db = Firestore.firestore()
    private var ref: CollectionReference { db.collection("cardDesigns") }

    // MARK: - Live listener

    func listenDesigns(
        ngoId: String?,
        completion: @escaping (Result<[CardDesign], Error>) -> Void
    ) -> ListenerRegistration {

        var q: Query = ref.order(by: CardDesign.Keys.createdAt, descending: true)

        if let ngoId, !ngoId.isEmpty {
            q = q.whereField(CardDesign.Keys.ngoId, isEqualTo: ngoId)
        }

        return q.addSnapshotListener { snap, err in
            if let err { completion(.failure(err)); return }
            let items = snap?.documents.compactMap { CardDesign(doc: $0) } ?? []
            completion(.success(items))
        }
    }

    // MARK: - Create/Update (Upsert)

    func upsertDesign(_ design: CardDesign, completion: @escaping (Error?) -> Void) {
        let docRef = ref.document(design.id)

        docRef.getDocument { snapshot, error in
            if let error { completion(error); return }

            var data = design.toFirestoreDict()
            data[CardDesign.Keys.updatedAt] = FieldValue.serverTimestamp()

            // createdAt only once (if doc doesn't exist yet)
            if snapshot?.exists != true {
                data[CardDesign.Keys.createdAt] = FieldValue.serverTimestamp()
            }

            docRef.setData(data, merge: true, completion: completion)
        }
    }

    // MARK: - Delete (optional)

    func deleteDesign(id: String, completion: @escaping (Error?) -> Void) {
        ref.document(id).delete(completion: completion)
    }

    // MARK: - Default (ONE default only)

    func setDefault(designId: String, completion: @escaping (Error?) -> Void) {
        setDefault(designId: designId, ngoId: nil, completion: completion)
    }

    func setDefault(designId: String, ngoId: String?, completion: @escaping (Error?) -> Void) {

        var q: Query = ref
        if let ngoId, !ngoId.isEmpty {
            q = q.whereField(CardDesign.Keys.ngoId, isEqualTo: ngoId)
        }

        q.getDocuments { snap, err in
            if let err { completion(err); return }

            let docs = snap?.documents ?? []

            let batch = self.db.batch()

            // set all to false, and selected one to true
            for doc in docs {
                let isSelected = (doc.documentID == designId)
                batch.updateData([CardDesign.Keys.isDefault: isSelected], forDocument: doc.reference)
            }

            if !docs.contains(where: { $0.documentID == designId }) {
                batch.setData([CardDesign.Keys.isDefault: true], forDocument: self.ref.document(designId), merge: true)
            }

            batch.commit(completion: completion)
        }
    }
}
