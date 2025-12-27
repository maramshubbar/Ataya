import Foundation

struct RecurringDonationDraft {
    var docId: String?

    var frequency: String?
    var startDate: Date?
    var nextPickupDate: Date?

    var foodCategoryName: String?
    var foodItemName: String?
    var estimatedQuantity: Double?
    var unit: String?
    var description: String?
}
