import Foundation
import FirebaseFirestore

struct RecurringDonation {
    let docId: String

    let userId: String
    let frequency: String
    let startDate: Date
    let nextPickupDate: Date
    let status: String

    let foodCategoryName: String
    let foodItemName: String
    let estimatedQuantity: Double
    let unit: String
    let description: String?

    let createdAt: Date
    let updatedAt: Date

    init?(doc: QueryDocumentSnapshot) {
        let d = doc.data()

        guard
            let userId = d["userId"] as? String,
            let frequency = d["frequency"] as? String,
            let status = d["status"] as? String,
            let startTS = d["startDate"] as? Timestamp,
            let nextTS = d["nextPickupDate"] as? Timestamp,
            let cat = d["foodCategoryName"] as? String,
            let item = d["foodItemName"] as? String,
            let qty = d["estimatedQuantity"] as? Double,
            let unit = d["unit"] as? String,
            let createdTS = d["createdAt"] as? Timestamp,
            let updatedTS = d["updatedAt"] as? Timestamp
        else { return nil }

        self.docId = doc.documentID
        self.userId = userId
        self.frequency = frequency
        self.startDate = startTS.dateValue()
        self.nextPickupDate = nextTS.dateValue()
        self.status = status

        self.foodCategoryName = cat
        self.foodItemName = item
        self.estimatedQuantity = qty
        self.unit = unit
        self.description = d["description"] as? String

        self.createdAt = createdTS.dateValue()
        self.updatedAt = updatedTS.dateValue()
    }
}
