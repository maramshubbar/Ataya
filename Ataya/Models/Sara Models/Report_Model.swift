import Foundation

struct SupportReport {
    let id: String
    let title: String
    let type: String
    let date: String
    let details: String
    var status: String
    var feedback: String
    let userId: String

    // Dummy initializer only
    init(id: String,
         title: String,
         type: String,
         date: String,
         details: String,
         status: String = "Pending",
         feedback: String = "",
         userId: String) {
        self.id = id
        self.title = title
        self.type = type
        self.date = date
        self.details = details
        self.status = status
        self.feedback = feedback
        self.userId = userId
    }
}
