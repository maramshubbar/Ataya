//
//  AdminDonationDetailsViewController.swift
//  Ataya
//
//  Created by Maram on 20/12/2025.
//


import UIKit
import FirebaseFirestore

final class AdminDonationDetailsViewController: UIViewController {

    var donationDocId: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    @IBOutlet weak var donationCardView: UIView!
    @IBOutlet weak var donorCardView: UIView!
    @IBOutlet weak var ngoCardView: UIView!
    @IBOutlet weak var adminReviewCardView: UIView!
    @IBOutlet weak var statusBadgeView: UIView?

    @IBOutlet weak var lblDonationTitle: UILabel?
    @IBOutlet weak var lblDonationId: UILabel?
    @IBOutlet weak var lblStatus: UILabel?
    @IBOutlet weak var lblCreatedAt: UILabel?
    @IBOutlet weak var lblDonorId: UILabel?
    @IBOutlet weak var imgDonation: UIImageView?

    @IBOutlet weak var lblCategory: UILabel?
    @IBOutlet weak var lblQuantity: UILabel?
    @IBOutlet weak var lblPackagingType: UILabel?
    @IBOutlet weak var lblAllergenInfo: UILabel?
    @IBOutlet weak var lblNotes: UILabel?
    @IBOutlet weak var lblExpiryDate: UILabel?
    @IBOutlet weak var lblSafetyConfirmed: UILabel?
    @IBOutlet weak var lblPhotoCount: UILabel?

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        donationCardView.applyCardStyleNoShadow()
        donorCardView.applyCardStyleNoShadow()
        ngoCardView.applyCardStyleNoShadow()
        adminReviewCardView.applyCardStyleNoShadow()

        imgDonation?.contentMode = .scaleAspectFit
        imgDonation?.backgroundColor = .clear

        print("✅ Details viewDidLoad docId:", donationDocId ?? "nil")
        print("✅ outlets:",
              lblDonationTitle != nil,
              lblDonationId != nil,
              lblStatus != nil,
              lblCreatedAt != nil,
              lblDonorId != nil,
              imgDonation != nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListeningDonation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
        listener = nil
    }

    deinit { listener?.remove() }

    private func startListeningDonation() {
        listener?.remove()
        listener = nil

        guard let docId = donationDocId, !docId.isEmpty else {
            print("❌ Missing donationDocId")
            return
        }

        listener = db.collection("donations").document(docId)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }

                if let err = err {
                    print("❌ details error:", err.localizedDescription)
                    return
                }

                guard let data = snap?.data() else {
                    print("❌ donation not found for docId:", docId)
                    return
                }

                let donationId = data["id"] as? String ?? docId
                let itemName   = data["itemName"] as? String ?? "—"
                let donorId    = data["donorId"] as? String ?? "—"
                let statusStr  = (data["status"] as? String ?? "pending").lowercased()

                let createdAtText = self.formatTimestamp(data["createdAt"])
                let expiryText    = self.formatTimestamp(data["expiryDate"])

                let category      = data["category"] as? String ?? "—"
                let packagingType = data["packagingType"] as? String ?? "—"
                let allergenInfo  = data["allergenInfo"] as? String ?? "—"
                let notes         = data["notes"] as? String ?? "—"

                let quantityValue = self.numberText(data["quantityValue"])
                let quantityUnit  = data["quantityUnit"] as? String ?? ""
                let quantityText: String = {
                    if quantityValue == "—" { return "—" }
                    if quantityUnit.isEmpty { return quantityValue }
                    return "\(quantityValue) \(quantityUnit)"
                }()

                let safetyConfirmed = data["safetyConfirmed"] as? Bool
                let safetyText = (safetyConfirmed == true) ? "Yes" : "No"

                let photoCountText = self.numberText(data["photoCount"])

                let photoURLs = data["photoURLs"] as? [String] ?? []
                let imageUrl = photoURLs.first ?? ""

                DispatchQueue.main.async {
                    // top card
                    self.lblDonationTitle?.text = itemName
                    self.lblDonationId?.text = donationId
                    self.lblDonorId?.text = donorId
                    self.lblCreatedAt?.text = createdAtText
                    self.lblStatus?.text = statusStr.capitalized
                    self.applyStatusBadge(statusStr)


                    // donation details
                    self.lblCategory?.text = category
                    self.lblQuantity?.text = quantityText
                    self.lblPackagingType?.text = packagingType
                    self.lblAllergenInfo?.text = allergenInfo
                    self.lblNotes?.text = notes
                    self.lblExpiryDate?.text = expiryText
                    self.lblSafetyConfirmed?.text = safetyText
                    self.lblPhotoCount?.text = photoCountText

                    // image from Firebase URL
                    self.imgDonation?.image = nil
                    let clean = imageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !clean.isEmpty {
                        self.imgDonation?.fetchRemoteImage(urlString: clean) { [weak self] img in
                            DispatchQueue.main.async {
                                self?.imgDonation?.image = img
                            }
                        }
                    }

                    print("✅ Details loaded from Firestore:", data)
                }
            }
    }
    
    private func applyStatusBadge(_ statusStr: String) {
        let s = statusStr.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        statusBadgeView?.layer.cornerRadius = 8
        statusBadgeView?.clipsToBounds = true

        switch s {
        case "pending":
            statusBadgeView?.backgroundColor = UIColor(red: 255/255, green: 244/255, blue: 191/255, alpha: 1)
            lblStatus?.textColor = .black

        case "approved":
            statusBadgeView?.backgroundColor = UIColor(red: 213/255, green: 244/255, blue: 214/255, alpha: 1)
            lblStatus?.textColor = .black

        case "rejected":
            statusBadgeView?.backgroundColor = UIColor(red: 242/255, green: 156/255, blue: 148/255, alpha: 1)
            lblStatus?.textColor = .black

        default:
            statusBadgeView?.backgroundColor = UIColor(white: 0.9, alpha: 1)
            lblStatus?.textColor = .black
        }
    }


    // MARK: - Helpers
    private func formatTimestamp(_ any: Any?) -> String {
        guard let ts = any as? Timestamp else { return "—" }
        return Self.dateFormatter.string(from: ts.dateValue())
    }

    private func numberText(_ any: Any?) -> String {
        if let v = any as? Int { return "\(v)" }
        if let v = any as? Int64 { return "\(v)" }
        if let v = any as? Double {
            if v.rounded() == v { return "\(Int(v))" }
            return "\(v)"
        }
        if let v = any as? NSNumber { return v.stringValue }
        return "—"
    }
}
