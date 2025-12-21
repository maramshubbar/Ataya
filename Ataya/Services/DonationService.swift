//
//  DonationService.swift
//  Ataya
//
//  Created by Maram on 21/12/2025.
//

import Foundation
import FirebaseFirestore


final class DonationService {
    static let shared = DonationService()
    private init() {}

    private let db = Firestore.firestore()

    // Create donation
    func createDonation(_ donation: Donation, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let ref = try db.collection("donations").addDocument(from: donation)
            completion(.success(ref.documentID))
        } catch {
            completion(.failure(error))
        }
    }

    // Fetch donations for current user (مرة واحدة)
    func fetchMyDonations(completion: @escaping (Result<[Donation], Error>) -> Void) {
        let uid = UserSession.shared.currentUserId

        db.collection("donations")
            .whereField("donorId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .getDocuments { snap, err in
                if let err = err { completion(.failure(err)); return }
                let docs = snap?.documents ?? []
                let items: [Donation] = docs.compactMap { try? $0.data(as: Donation.self) }
                completion(.success(items))
            }
    }

    // Live listener (ممتاز لصفحة Ongoing/My Donations)
    func listenMyDonations(onChange: @escaping (Result<[Donation], Error>) -> Void) -> ListenerRegistration {
        let uid = UserSession.shared.currentUserId

        return db.collection("donations")
            .whereField("donorId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snap, err in
                if let err = err { onChange(.failure(err)); return }
                let docs = snap?.documents ?? []
                let items: [Donation] = docs.compactMap { try? $0.data(as: Donation.self) }
                onChange(.success(items))
            }
    }
}

