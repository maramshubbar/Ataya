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

    private var currentNgoId: String { "ngo_demo_1" }

    func listenMyPickups(onChange: @escaping (Result<[PickupItem], Error>) -> Void) -> ListenerRegistration {

        print("🔥 Firestore listen started...")

        return db.collection(collection)
            .whereField("assignedNgoId", isEqualTo: currentNgoId)
            .addSnapshotListener { snapshot, error in

                if let error {
                    print("❌ Firestore listen error:", error.localizedDescription)
                    onChange(.failure(error))
                    return
                }

                guard let snapshot else {
                    onChange(.success([]))
                    return
                }

                print("✅ Firestore docs count:", snapshot.documents.count)

                let items = snapshot.documents.compactMap { doc in
                    PickupItem(doc: doc)
                }

                print("✅ Valid pickups:", items.count)
                onChange(.success(items))
            }
    }

    func updateStatus(docId: String, status: PickupStatus, completion: @escaping (Result<Void, Error>) -> Void) {

        db.collection(collection)
            .document(docId)
            .updateData(["status": status.rawValue]) { error in
                if let error { completion(.failure(error)) }
                else { completion(.success(())) }
            }
    }
}
