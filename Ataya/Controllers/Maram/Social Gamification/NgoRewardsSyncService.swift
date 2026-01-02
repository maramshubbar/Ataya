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
    private let ptsPerSuccessfulPickup = 100
    private let ptsPerVerifiedFoodQuality = 50
    private let ptsAfter10PickupsMilestone = 200
    private let ptsForPhotos = 30
    private let ptsPerCampaignSupported = 100

    // what counts as successful
    private let successfulStatuses: Set<String> = ["completed", "delivered", "success"]

    func recomputeAndSaveCurrentNgo(completion: ((Error?) -> Void)? = nil) {

        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(NSError(domain: "Auth", code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Not logged in"]))
            return
        }

        db.collection("donations")
            .whereField("ngoId", isEqualTo: uid) // ✅ تأكدي هذا اسم الحقل عندكم
            .getDocuments { [weak self] snap, err in
                guard let self else { return }

                if let err {
                    completion?(err)
                    return
                }

                let docs = snap?.documents ?? []

                var successfulPickups = 0
                var lives = 0
                var verifiedCount = 0
                var photoCount = 0
                var campaignIds = Set<String>()

                for doc in docs {
                    let d = doc.data()

                    let status = (d["status"] as? String ?? "").lowercased()
                    let isSuccessful = self.successfulStatuses.contains(status)
                    if !isSuccessful { continue }

                    successfulPickups += 1

                    // lives
                    lives += self.intValue(d["livesImpacted"])
                    if lives == 0 { lives += self.intValue(d["livesTouched"]) }
                    if lives == 0 { lives += self.intValue(d["servings"]) }

                    // verified
                    let verified =
                        (d["verifiedFoodQuality"] as? Bool)
                        ?? (d["foodQualityVerified"] as? Bool)
                        ?? false
                    if verified { verifiedCount += 1 }

                    // photos
                    if let arr = d["imageUrls"] as? [String], !arr.isEmpty { photoCount += 1 }
                    else if let arr = d["imageURLs"] as? [String], !arr.isEmpty { photoCount += 1 }

                    // campaigns
                    if let c = d["campaignId"] as? String, !c.isEmpty { campaignIds.insert(c) }
                }

                if lives == 0 { lives = successfulPickups }

                var points = 0
                points += successfulPickups * self.ptsPerSuccessfulPickup
                points += verifiedCount * self.ptsPerVerifiedFoodQuality
                points += photoCount * self.ptsForPhotos
                points += campaignIds.count * self.ptsPerCampaignSupported
                if successfulPickups >= 10 { points += self.ptsAfter10PickupsMilestone }

                // ✅ نحفظ في rewardsNgo/{uid}
                let ref = self.db.collection("rewardsNgo").document(uid)
                ref.setData([
                    "successfulPickups": successfulPickups,
                    "livesImpacted": lives,
                    "points": points,
                    "campaignsSupported": campaignIds.count,
                    "updatedAt": FieldValue.serverTimestamp()
                ], merge: true) { saveErr in
                    completion?(saveErr)
                }
            }
    }

    // ✅ helper هنا بدل NgoRewardsMetrics.intValue
    private func intValue(_ any: Any?) -> Int {
        if let i = any as? Int { return i }
        if let d = any as? Double { return Int(d) }
        if let n = any as? NSNumber { return n.intValue }
        if let s = any as? String { return Int(s.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0 }
        return 0
    }
}
