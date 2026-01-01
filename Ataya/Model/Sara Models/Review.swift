import Foundation

struct Review {
    let reviewerName: String
    let rating: Int
    let comment: String
    let date: Date
}

struct UserProfile {
    let id: String
    let name: String
    let role: String // Donor / Collector / NGO
    var reviews: [Review]

    var averageRating: Double {
        guard !reviews.isEmpty else { return 0 }
        let total = reviews.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(reviews.count)
    }
}
