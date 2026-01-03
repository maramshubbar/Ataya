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

    // ✅ Rule settings
    private let ptsPerSuccessfulDonation = 100
    private let ptsPerVerifiedFoodQuality = 50
    private let ptsAfter10DonationsMilestone = 200
    private let ptsForClearPhotos = 30
    private let ptsPerCampaignSupported = 100

    // ✅ what counts as successful?
    private let successfulStatuses: Set<String> = [
        "completed", "delivered", "success",
        "successful",
        "collected"
    ]

    func recomputeAndSaveCurrentUser(completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(NSError(
                domain: "Auth",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Not logged in"]
            ))
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

                        // ✅ livesTouched: إذا موجود في الدوكيومنت خذه، إذا مو موجود احسبه تلقائيًا
                        if let l = data["livesTouched"] as? Int {
                            livesTouched += l
                        } else if let n = data["livesTouched"] as? NSNumber {
                            livesTouched += n.intValue
                        } else {
                            livesTouched += self.estimateLivesTouched(from: data)
                        }
                    }

                    // verified food quality (Bool)
                    let verified = (data["verifiedFoodQuality"] as? Bool) ?? false
                    if isSuccessful && verified { verifiedFoodQualityCount += 1 }

                    // clear photos: simple rule (>= 2 photos)
                    if let urls = data["imageUrls"] as? [String], urls.count >= 2 {
                        if isSuccessful { clearPhotosCount += 1 }
                    }

                    // campaign supported
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

                // ✅ isNew من الفايربيس: إذا ما عنده أي تقدم
                let isNew = (successfulDonations == 0 && livesTouched == 0 && points == 0)

                // ---------- save into rewards/{uid} ----------
                let rewardsDict: [String: Any] = [
                    "userId": uid,
                    "successfulDonations": successfulDonations,
                    "livesTouched": livesTouched,
                    "points": points,
                    "tier": tier,
                    "campaignsSupported": campaignsSupported,
                    "verifiedFoodQualityCount": verifiedFoodQualityCount,
                    "clearPhotosCount": clearPhotosCount,
                    "isNew": isNew,
                    "updatedAt": FieldValue.serverTimestamp()
                ]

                self.db.collection("rewards").document(uid).setData(rewardsDict, merge: true) { saveErr in
                    completion?(saveErr)
                }
            }
    }

    // MARK: - ✅ livesTouched estimation (بدون Firestore field)

    /// يحسب livesTouched من الـ items/الكمية إذا موجودة، وإلا يعطي fallback ثابت
    private func estimateLivesTouched(from data: [String: Any]) -> Int {

        // 1) لو donation فيها items array (الأكثر احتمالاً)
        let possibleItemsKeys = ["items", "donationItems", "foodItems", "selectedItems"]
        for key in possibleItemsKeys {
            if let items = data[key] as? [[String: Any]] {
                var total = 0
                for item in items {
                    let q = doubleValue(item["quantityValue"])
                    let unit = (item["quantityUnit"] as? String ?? "").lowercased()
                    total += livesFrom(quantity: q, unit: unit)
                }
                // إذا طلع 0 (مثلاً items بدون كمية) -> fallback
                return total > 0 ? total : 10
            }
        }

        // 2) لو الكمية مباشرة داخل donation
        if data["quantityValue"] != nil || data["quantityUnit"] != nil {
            let q = doubleValue(data["quantityValue"])
            let unit = (data["quantityUnit"] as? String ?? "").lowercased()
            let calc = livesFrom(quantity: q, unit: unit)
            return calc > 0 ? calc : 10
        }

        // 3) fallback ثابت (إذا ما عندنا أي معلومات كمية)
        return 10
    }

    /// قواعد تقديرية بسيطة:
    /// - كل 0.25kg = 1 person
    /// - grams تتحول لـ kg
    /// - pcs/pc/piece كل قطعة = 1
    /// - liter تقديري: كل 0.3L = 1
    private func livesFrom(quantity q: Double, unit: String) -> Int {
        guard q > 0 else { return 0 }

        let kgPerPerson = 0.25

        if unit.contains("kg") {
            return Int(ceil(q / kgPerPerson))
        }

        if unit.contains("g") {
            let kg = q / 1000.0
            return Int(ceil(kg / kgPerPerson))
        }

        if unit.contains("pcs") || unit.contains("pc") || unit.contains("piece") {
            return Int(ceil(q))
        }

        if unit.contains("l") || unit.contains("liter") || unit.contains("litre") {
            let lPerPerson = 0.3
            return Int(ceil(q / lPerPerson))
        }

        // وحدة غير معروفة → اعتبر كل 1 = شخص
        return Int(ceil(q))
    }

    private func doubleValue(_ any: Any?) -> Double {
        if let d = any as? Double { return d }
        if let i = any as? Int { return Double(i) }
        if let n = any as? NSNumber { return n.doubleValue }
        if let s = any as? String {
            return Double(s.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        }
        return 0
    }
}
