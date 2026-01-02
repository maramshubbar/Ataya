//
//  RewardsSyncService.swift
//  Ataya
//
//  Created by Maram on 02/01/2026.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

final class RewardsSyncService {

    static let shared = RewardsSyncService()
    private init() {}

    private let db = Firestore.firestore()

    // ✅ Rule settings (مثل اللي تحت بالصورة)
    private let ptsPerSuccessfulDonation = 100
    private let ptsPerVerifiedFoodQuality = 50
    private let ptsAfter10DonationsMilestone = 200
    private let ptsForClearPhotos = 30
    private let ptsPerCampaignSupported = 100

    // 🔸 what counts as successful?
    private let successfulStatuses: Set<String> = ["completed", "delivered", "success"]

    func recomputeAndSaveCurrentUser(completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not logged in"]))
            return
        }

        let donationsRef = db.collection("donations")

        donationsRef
            .whereField("donorId", isEqualTo: uid)
            .getDocuments { [weak self] snap, err in
                guard let self else { return }

                if let err {
                    completion?(err)
                    return
                }

                let docs = snap?.documents ?? []

                // ---------- compute counts ----------
                var successfulDonations = 0
                var verifiedFoodQualityCount = 0
                var clearPhotosCount = 0
                var campaignsSupported = 0
                var livesTouched = 0

                for d in docs {
                    let data = d.data()

                    let status = (data["status"] as? String ?? "").lowercased()
                    let isSuccessful = self.successfulStatuses.contains(status)

                    if isSuccessful {
                        successfulDonations += 1

                        // livesTouched (optional): if you store it per donation
                        if let l = data["livesTouched"] as? Int { livesTouched += l }
                        else if let n = data["livesTouched"] as? NSNumber { livesTouched += n.intValue }
                    }

                    // verified food quality (Bool)
                    let verified = (data["verifiedFoodQuality"] as? Bool) ?? false
                    if isSuccessful && verified { verifiedFoodQualityCount += 1 }

                    // clear photos: simple rule (>= 2 photos)
                    if let urls = data["imageUrls"] as? [String], urls.count >= 2 {
                        if isSuccessful { clearPhotosCount += 1 }
                    }

                    // campaign supported: if donation has campaignId
                    if let campaignId = data["campaignId"] as? String, !campaignId.isEmpty {
                        if isSuccessful { campaignsSupported += 1 }
                    }
                }

                // ---------- compute points ----------
                var points = 0
                points += successfulDonations * self.ptsPerSuccessfulDonation
                points += verifiedFoodQualityCount * self.ptsPerVerifiedFoodQuality
                points += clearPhotosCount * self.ptsForClearPhotos
                points += campaignsSupported * self.ptsPerCampaignSupported

                if successfulDonations >= 10 {
                    points += self.ptsAfter10DonationsMilestone
                }

                // tier from points
                let tier = RewardTier.from(points: points).title

                // ---------- save into users/{uid}.rewards ----------
                let rewardsDict: [String: Any] = [
                    "successfulDonations": successfulDonations,
                    "livesTouched": livesTouched,                    // إذا ما عندج field في donations بيظل 0
                    "points": points,                               // ✅ لازم Number مو String
                    "tier": tier,
                    "campaignsSupported": campaignsSupported,
                    "verifiedFoodQualityCount": verifiedFoodQualityCount,
                    "clearPhotosCount": clearPhotosCount,
                    "updatedAt": FieldValue.serverTimestamp()
                ]

                self.db.collection("users").document(uid).setData([
                    "rewards": rewardsDict
                ], merge: true) { saveErr in
                    completion?(saveErr)
                }
            }
    }
}
