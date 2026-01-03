import Foundation
import FirebaseFirestore

final class GiftCertificatesService {

    static let shared = GiftCertificatesService()
    private init() {}

    private let db = Firestore.firestore()
    private let col = "giftCertificates"

    @discardableResult
    func listenOrders(completion: @escaping (Result<[GiftCertificateOrder], Error>) -> Void) -> ListenerRegistration {

        let q = db.collection(col)
            .order(by: "createdAt", descending: true)

        return q.addSnapshotListener { snap, err in
            if let err {
                print("❌ listenOrders error:", err)
                completion(.failure(err))
                return
            }

            guard let snap else {
                completion(.success([]))
                return
            }

            print("✅ giftCertificates docs:", snap.documents.count)

            var items: [GiftCertificateOrder] = []

            for doc in snap.documents {
                let data = doc.data()

                if let order = GiftCertificateOrder.fromFirestore(docId: doc.documentID, data: data) {
                    items.append(order)
                } else {
                    print("⚠️ parse failed doc:", doc.documentID, data)
                }
            }

            completion(.success(items))
        }
    }
}
