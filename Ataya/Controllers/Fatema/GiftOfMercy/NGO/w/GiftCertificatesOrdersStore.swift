//
//  GiftCertificatesOrdersStore.swift
//  Ataya
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class GiftCertificatesOrdersStore: ObservableObject {

    enum Filter: Int, CaseIterable {
        case all, pending, rejected, approved

        var title: String {
            switch self {
            case .all: return "All"
            case .pending: return "Pending"
            case .rejected: return "Rejected"
            case .approved: return "Approved"
            }
        }
    }

    @Published var searchText: String = ""
    @Published var filter: Filter = .all
    @Published private(set) var shown: [GiftCertificateOrder] = []

    private var all: [GiftCertificateOrder] = []
    private var listener: ListenerRegistration?

    private let db = Firestore.firestore()

    func start() {
        stop()

        let ngoId = Auth.auth().currentUser?.uid

        let q: Query = db.collection("giftCertificates")
            .order(by: "createdAt", descending: true)

        listener = q.addSnapshotListener { [weak self] snap, err in
            guard let self else { return }

            if let err {
                print("❌ listenOrders:", err.localizedDescription)
                self.all = []
                self.apply()
                return
            }
            guard let snap else {
                self.all = []
                self.apply()
                return
            }

            var items: [GiftCertificateOrder] = []
            for doc in snap.documents {
                let data = doc.data()

                // optional filter by ngoId if you store it
                if let ngoId,
                   let docNgo = data["ngoId"] as? String,
                   docNgo != ngoId {
                    continue
                }

                // ✅ FIX: use docId label (matches models file)
                if let item = GiftCertificateOrder.fromFirestore(docId: doc.documentID, data: data) {
                    items.append(item)
                }
            }

            self.all = items.sorted {
                ($0.createdAt?.dateValue() ?? .distantPast) > ($1.createdAt?.dateValue() ?? .distantPast)
            }
            self.apply()
        }
    }

    func stop() {
        listener?.remove()
        listener = nil
    }

    func apply() {
        var base = all

        switch filter {
        case .all:
            break
        case .pending:
            base = base.filter { $0.status == .pending }
        case .rejected:
            base = base.filter { $0.status == .rejected }
        case .approved:
            // approved تشمل sent بعد
            base = base.filter { $0.status == .approved || $0.status == .sent }
        }

        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty {
            shown = base
        } else {
            shown = base.filter { o in
                let hay = [
                    o.giftTitle, o.cardDesignTitle, o.fromName,
                    o.recipient.name, o.recipient.email
                ].joined(separator: " ").lowercased()
                return hay.contains(q)
            }
        }
    }

    // MARK: - Actions

    func approve(orderId: String) async throws {
        try await db.collection("giftCertificates").document(orderId).setData([
            "status": GiftCertificateOrderStatus.approved.rawValue,
            "approvedAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    func reject(orderId: String, reason: String?) async throws {
        var data: [String: Any] = [
            "status": GiftCertificateOrderStatus.rejected.rawValue,
            "rejectedAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if let reason, !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            data["rejectedReason"] = reason
        }
        try await db.collection("giftCertificates").document(orderId).setData(data, merge: true)
    }

    func markSent(orderId: String) async throws {
        try await db.collection("giftCertificates").document(orderId).setData([
            "status": GiftCertificateOrderStatus.sent.rawValue,
            "isSent": true,
            "sentAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
}
