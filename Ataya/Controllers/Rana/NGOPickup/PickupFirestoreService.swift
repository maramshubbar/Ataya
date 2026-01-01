//
//  PickupFirestoreService.swift
//  Ataya
//
//  Created by BP-36-224-15 on 31/12/2025.
//

import Foundation
import FirebaseFirestore

final class PickupFirestoreService {

    static let shared = PickupFirestoreService()
    private init() {}

    private let db = Firestore.firestore()
    private let collection = "pickups"

    // TEMP until Auth is ready
    private var currentNgoId: String { "ngo_demo_1" }

    func listenMyPickups(onChange: @escaping (Result<[PickupItem], Error>) -> Void) -> ListenerRegistration {
        return db.collection(collection)
            .whereField("assignedNgoId", isEqualTo: currentNgoId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in

                if let error {
                    onChange(.failure(error))
                    return
                }

                let docs = snapshot?.documents ?? []

                let items: [PickupItem] = docs.compactMap { doc in
                    var data = doc.data()
                    data["id"] = doc.documentID

                    do {
                        let json = try JSONSerialization.data(withJSONObject: data, options: [])
                        var item = try JSONDecoder().decode(PickupItem.self, from: json)
                        item.id = doc.documentID
                        return item
                    } catch {
                        print("❌ Decode error for doc:", doc.documentID, error)
                        return nil
                    }
                }

                onChange(.success(items))
            }
    }

    func updateStatus(docId: String, status: PickupStatus, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collection).document(docId).updateData([
            "status": status.rawValue
        ]) { error in
            if let error { completion(.failure(error)) }
            else { completion(.success(())) }
        }
    }
}
