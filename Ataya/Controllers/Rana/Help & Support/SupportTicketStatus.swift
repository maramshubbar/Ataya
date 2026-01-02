//
//  SupportTicketStatus.swift
//  Ataya
//
//  Created by BP-36-224-15 on 02/01/2026.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

enum SupportTicketStatus: String {
    case pending = "Pending"
    case resolved = "Resolved"
}

struct SupportTicket {
    let id: String
    let userId: String
    let ticketLabel: String
    let category: String
    let status: SupportTicketStatus
    let userIssue: String
    let adminReply: String?
    let createdAt: Date
    let updatedAt: Date

    var displayId: String { "#\(id)" }
    var titleSafe: String { ticketLabel.isEmpty ? "Support Ticket" : ticketLabel }

    init?(id: String, data: [String: Any]) {
        guard
            let userId = data["userId"] as? String,
            let ticketLabel = data["ticketLabel"] as? String,
            let category = data["category"] as? String,
            let statusRaw = data["status"] as? String,
            let userIssue = data["userIssue"] as? String
        else { return nil }

        self.id = id
        self.userId = userId
        self.ticketLabel = ticketLabel
        self.category = category
        self.status = SupportTicketStatus(rawValue: statusRaw) ?? .pending
        self.userIssue = userIssue

        // ✅ Firestore might store null as NSNull, so convert safely
        if let reply = data["adminReply"] as? String {
            self.adminReply = reply
        } else {
            self.adminReply = nil
        }

        let createdTS = data["createdAt"] as? Timestamp
        let updatedTS = data["updatedAt"] as? Timestamp
        self.createdAt = createdTS?.dateValue() ?? Date()
        self.updatedAt = updatedTS?.dateValue() ?? Date()
    }
}

final class SupportTicketService {
    static let shared = SupportTicketService()
    private init() {}

    private let db = Firestore.firestore()
    private var ticketsRef: CollectionReference { db.collection("supportTickets") }

    // ✅ Create Ticket (Team-safe demo: works even without login)
    func createTicket(ticketLabel: String,
                      category: String,
                      userIssue: String,
                      completion: @escaping (Result<Void, Error>) -> Void) {

        let uid = Auth.auth().currentUser?.uid ?? "DEMO_USER"

        let doc = ticketsRef.document()
        let now = Timestamp(date: Date())

        let data: [String: Any] = [
            "userId": uid,
            "ticketLabel": ticketLabel,
            "category": category,
            "status": SupportTicketStatus.pending.rawValue,
            "userIssue": userIssue,
            "adminReply": NSNull(),
            "createdAt": now,
            "updatedAt": now
        ]

        doc.setData(data) { err in
            if let err {
                completion(.failure(err))
            } else {
                completion(.success(()))
            }
        }
    }

    // ✅ Listen to My Tickets
    func listenMyTickets(includeOnlyReplied: Bool,
                         onChange: @escaping (Result<[SupportTicket], Error>) -> Void) -> ListenerRegistration? {

        let uid = Auth.auth().currentUser?.uid ?? "DEMO_USER"

        let query = ticketsRef
            .whereField("userId", isEqualTo: uid)
            .order(by: "updatedAt", descending: true)

        return query.addSnapshotListener { snapshot, error in
            if let error {
                onChange(.failure(error))
                return
            }

            guard let snapshot else {
                onChange(.success([]))
                return
            }

            var items: [SupportTicket] = snapshot.documents.compactMap { doc in
                SupportTicket(id: doc.documentID, data: doc.data())
            }

            if includeOnlyReplied {
                items = items.filter {
                    let reply = $0.adminReply?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    return !reply.isEmpty
                }
            }

            onChange(.success(items))
        }
    }

    // ✅ Listen to a Single Ticket
    func listenTicket(ticketId: String,
                      onChange: @escaping (Result<SupportTicket?, Error>) -> Void) -> ListenerRegistration {

        ticketsRef.document(ticketId).addSnapshotListener { snapshot, error in
            if let error {
                onChange(.failure(error))
                return
            }

            guard let snapshot, snapshot.exists else {
                onChange(.success(nil))
                return
            }

            let ticket = SupportTicket(id: snapshot.documentID, data: snapshot.data() ?? [:])
            onChange(.success(ticket))
        }
    }
}
