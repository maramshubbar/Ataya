//
//  NgoRewardsSyncService.swift
//  Ataya
//
//  Created by Maram on 02/01/2026.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

final class NgoRewardsSyncService {

    static let shared = NgoRewardsSyncService()
    private init() {}

    private let db = Firestore.firestore()

    // Points rules
    private let ptsPerPickup = 100
    private let ptsAfter10PickupsMilestone = 200
    private let ptsForPhoto = 30

    private let countedStatuses: Set<String> = [
        "accepted", "completed", "collected", "delivered", "successful", "success"
    ]

//    func recomputeAndSaveCurrentNgo(completion: ((Error?) -> Void)? = nil) {
//
//        guard let uid = Auth.auth().currentUser?.uid else {
//            completion?(NSError(domain: "Auth", code: 0,
//                                userInfo: [NSLocalizedDescriptionKey: "Not logged in"]))
//            return
//        }
//
//        let userRef = db.collection("users").document(uid)
//        userRef.getDocument { [weak self] snap, err in
//            guard let self else { return }
//            if let err { completion?(err); return }
//
//            let data = snap?.data() ?? [:]
//
//            var keys: [String] = [uid]
//            let possibleNgoKey =
//                (data["ngoId"] as? String) ??
//                (data["ngoCode"] as? String) ??
//                (data["ngoPublicId"] as? String) ??
//                (data["assignedNgoId"] as? String)
//
//            if let k = possibleNgoKey, !k.isEmpty, k != uid {
//                keys.append(k)
//            }
//
//            self.fetchPickups(forNgoKeys: keys) { result in
//                switch result {
//                case .failure(let e):
//                    completion?(e)
//
//                case .success(let docs):
//                    self.computeAndSave(uid: uid, pickupDocs: docs, completion: completion)
//                }
//            }
//        }
//    }

    // MARK: - Fetch pickups

    private func fetchPickups(forNgoKeys keys: [String],
                              completion: @escaping (Result<[QueryDocumentSnapshot], Error>) -> Void) {

        let group = DispatchGroup()
        var allDocsById: [String: QueryDocumentSnapshot] = [:]
        var firstError: Error?

        for key in keys {
            group.enter()
            db.collection("pickups")
                .whereField("assignedNgoId", isEqualTo: key)
                .getDocuments { snap, err in
                    defer { group.leave() }

                    if let err {
                        firstError = firstError ?? err
                        return
                    }

                    for doc in snap?.documents ?? [] {
                        allDocsById[doc.documentID] = doc
                    }
                }
        }

        group.notify(queue: .main) {
            if let firstError { completion(.failure(firstError)); return }
            completion(.success(Array(allDocsById.values)))
        }
    }

    // MARK: - Compute + Save users/{uid}.rewardsNgo

    private func computeAndSave(uid: String,
                                pickupDocs: [QueryDocumentSnapshot],
                                completion: ((Error?) -> Void)?) {

        var countedPickups = 0
        var lives = 0
        var photoCount = 0

        for doc in pickupDocs {
            let d = doc.data()

            let status = (d["status"] as? String ?? "").lowercased()
            guard countedStatuses.contains(status) else { continue }

            countedPickups += 1

            // lives from quantity
            lives += estimateLives(from: d)

            let imageName = (d["imageName"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !imageName.isEmpty { photoCount += 1 }
        }

        if lives == 0, countedPickups > 0 {
            lives = countedPickups * 10
        }

        var points = 0
        points += countedPickups * ptsPerPickup
        points += photoCount * ptsForPhoto
        if countedPickups >= 10 { points += ptsAfter10PickupsMilestone }

        let tier = NgoTier.from(points: points)

        db.collection("users").document(uid).setData([
            "rewardsNgo": [
                "successfulPickups": countedPickups,
                "livesImpacted": lives,
                "points": points,
                "tierTitle": tier.title,
                "updatedAt": FieldValue.serverTimestamp()
            ]
        ], merge: true) { err in
            completion?(err)
        }
    }

    // MARK: - lives estimation from quantity string

    private func estimateLives(from d: [String: Any]) -> Int {

        let ready = intValue(d["livesImpacted"])
        if ready > 0 { return ready }

        let qStr = (d["quantity"] as? String ?? "").lowercased()
        let number = extractFirstNumber(from: qStr)

        if qStr.contains("box") || qStr.contains("boxes") {
            return max(1, number * 10)
        }

        if qStr.contains("pc") || qStr.contains("pcs") || qStr.contains("piece") {
            return max(1, number)
        }

        if number > 0 { return max(1, number * 5) }
        // fallback
        return 10
    }

    private func extractFirstNumber(from s: String) -> Int {
        let digits = s.split { !$0.isNumber }
        if let first = digits.first, let n = Int(first) { return n }
        return 0
    }

    private func intValue(_ any: Any?) -> Int {
        if let i = any as? Int { return i }
        if let d = any as? Double { return Int(d) }
        if let n = any as? NSNumber { return n.intValue }
        if let s = any as? String { return Int(s.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0 }
        return 0
    }
}
private enum NgoTier {
    case starter, silver, gold, diamond

    static func from(points: Int) -> NgoTier {
        switch points {
        case 0..<500: return .starter
        case 500..<1500: return .silver
        case 1500..<2500: return .gold
        default: return .diamond
        }
    }

    var title: String {
        switch self {
        case .starter: return "Reliable NGO"
        case .silver:  return "Silver Partner"
        case .gold:    return "Gold Partner"
        case .diamond: return "Diamond Partner"
        }
    }

    var medalAssetName: String {
        switch self {
        case .starter: return "tier_starter"
        case .silver:  return "tier_silver"
        case .gold:    return "tier_gold"
        case .diamond: return "tier_diamond"
        }
    }
}
