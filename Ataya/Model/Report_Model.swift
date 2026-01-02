import Foundation
import FirebaseFirestore

struct Report {
    let id: String
    let title: String
    let type: String
    let date: String
    let details: String
    var status: String
    var feedback: String
    let userId: String

    init(id: String, data: [String: Any]) {
        self.id = id
        self.title = data["ticketLabel"] as? String ?? "No Title"
        self.type = data["category"] as? String ?? "No Type"

        if let timestamp = data["createdAt"] as? Timestamp {
            let dateValue = timestamp.dateValue()
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            self.date = formatter.string(from: dateValue)
        } else {
            self.date = "No Date"
        }

        self.details = data["userIssue"] as? String ?? ""
        self.status = data["status"] as? String ?? "Pending"
        self.feedback = data["adminReply"] as? String ?? ""
        self.userId = data["userId"] as? String ?? ""
    }
}
