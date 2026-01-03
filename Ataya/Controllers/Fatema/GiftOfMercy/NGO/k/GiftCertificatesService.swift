import Foundation
import FirebaseFirestore
import FirebaseAuth

final class GiftCertificatesService {

    static let shared = GiftCertificatesService()
    private init() {}

    private let db = Firestore.firestore()

    // MARK: - Listen Orders
    @discardableResult
    func listenOrders(ngoId: String?, completion: @escaping (Result<[GiftCertificateOrder], Error>) -> Void) -> ListenerRegistration {

        let q: Query = db.collection("giftCertificates")
            .order(by: "createdAt", descending: true)

        return q.addSnapshotListener { snap, err in
            if let err {
                completion(.failure(err))
                return
            }
            guard let snap else {
                completion(.success([]))
                return
            }

            var items: [GiftCertificateOrder] = []

            for doc in snap.documents {
                let data = doc.data()

                // optional filter by ngoId if stored in document
                if let ngoId, !ngoId.isEmpty,
                   let docNgo = data["ngoId"] as? String,
                   docNgo != ngoId {
                    continue
                }

                if let item = GiftCertificateOrder.fromFirestore(docId: doc.documentID, data: data) {
                    items.append(item)
                }

            }

            items.sort {
                ($0.createdAt?.dateValue() ?? .distantPast) >
                ($1.createdAt?.dateValue() ?? .distantPast)
            }

            completion(.success(items))
        }
    }

    // MARK: - Actions (Approve / Reject / Sent)

    func approve(orderId: String, completion: @escaping (Error?) -> Void) {
        db.collection("giftCertificates").document(orderId).setData([
            "status": GiftCertificateOrderStatus.approved.rawValue,
            "approvedAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true) { err in
            completion(err)
        }
    }

    func reject(orderId: String, reason: String?, completion: @escaping (Error?) -> Void) {
        var data: [String: Any] = [
            "status": GiftCertificateOrderStatus.rejected.rawValue,
            "rejectedAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        let r = (reason ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !r.isEmpty { data["rejectedReason"] = r }

        db.collection("giftCertificates").document(orderId).setData(data, merge: true) { err in
            completion(err)
        }
    }

    func markSent(orderId: String, completion: @escaping (Error?) -> Void) {
        db.collection("giftCertificates").document(orderId).setData([
            "status": GiftCertificateOrderStatus.sent.rawValue,
            "isSent": true,
            "sentAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true) { err in
            completion(err)
        }
    }
}
