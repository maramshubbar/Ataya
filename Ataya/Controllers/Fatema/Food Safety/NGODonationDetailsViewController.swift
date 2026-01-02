//
//  NGODonationDetailsViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 02/12/2025.
//

import UIKit
import FirebaseFirestore

final class NGODonationDetailsViewController: UIViewController {

    // ✅ يجي من Overview (docId)
    var donationId: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // MARK: - Cards / Button
    @IBOutlet weak var donationCardView: UIView!
    @IBOutlet weak var donorCardView: UIView!
    @IBOutlet weak var collectorCardView: UIView!
    @IBOutlet weak var proceedButton: UIButton!

    // MARK: - Status
    @IBOutlet weak var statusBadgeView: UIView?
    @IBOutlet weak var statusLabel: UILabel?

    // MARK: - Donation card
    @IBOutlet weak var donationIdLabel: UILabel?
    @IBOutlet weak var itemNameLabel: UILabel?
    @IBOutlet weak var quantityLabel: UILabel?
    @IBOutlet weak var categoryLabel: UILabel?
    @IBOutlet weak var expiryDateLabel: UILabel?
    @IBOutlet weak var packagingLabel: UILabel?
    @IBOutlet weak var allergenLabel: UILabel?
    @IBOutlet weak var notesLabel: UILabel?
    @IBOutlet weak var donationImageView: UIImageView?

    // MARK: - Donor card
    @IBOutlet weak var donorNameLabel: UILabel?
    @IBOutlet weak var donorAddressLabel: UILabel?
    @IBOutlet weak var donorCityCountryLabel: UILabel?
    @IBOutlet weak var pickupMethodLabel: UILabel?
    @IBOutlet weak var donorEmailLabel: UILabel?
    @IBOutlet weak var donorPhoneLabel: UILabel?
    @IBOutlet weak var donorNotesLabel: UILabel?

    // MARK: - Pickup card
    @IBOutlet weak var pickupDateLabel: UILabel?
    @IBOutlet weak var pickupTimeLabel: UILabel?
    @IBOutlet weak var pickupStatusLabel: UILabel?
    @IBOutlet weak var locationTypeLabel: UILabel?

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        print("✅ Details donationId:", donationId ?? "nil")

        title = "Donation Details"

        styleCard(donationCardView)
        styleCard(donorCardView)
        styleCard(collectorCardView)

        proceedButton.layer.cornerRadius = 12
        proceedButton.clipsToBounds = true
        proceedButton.backgroundColor = .atayaYellow
        proceedButton.setTitleColor(.black, for: .normal)
        proceedButton.setTitleColor(.black.withAlphaComponent(0.4), for: .disabled)

        donationImageView?.contentMode = .scaleAspectFit
        donationImageView?.clipsToBounds = true
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

    private func styleCard(_ v: UIView) {
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(white: 0.85, alpha: 1).cgColor
        v.clipsToBounds = true
    }

    private func startListeningDonation() {
        listener?.remove()
        listener = nil

        let docId = (donationId ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !docId.isEmpty else {
            print("❌ Details: donationId is NIL (not passed from overview)")
            proceedButton.isEnabled = false
            proceedButton.alpha = 0.5
            return
        }

        proceedButton.isEnabled = true
        proceedButton.alpha = 1

        listener = db.collection("donations").document(docId)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }

                if let err = err {
                    print("❌ NGO details error:", err.localizedDescription)
                    return
                }

                guard let data = snap?.data() else {
                    print("❌ donation not found:", docId)
                    return
                }

                let donationCode = (data["id"] as? String) ?? docId
                let itemName     = (data["itemName"] as? String) ?? "—"
                let statusStr    = (data["status"] as? String ?? "pending")

                let category     = (data["category"] as? String) ?? "—"
                let packaging    = (data["packagingType"] as? String) ?? (data["packaging"] as? String) ?? "—"
                let allergen     = (data["allergenInfo"] as? String) ?? "—"
                let notes        = (data["notes"] as? String) ?? "—"

                let expiryText   = self.formatTimestamp(data["expiryDate"])
                    .replacingOccurrences(of: "—", with: (data["expiry"] as? String) ?? "—")

                let quantityValue = self.numberText(data["quantityValue"])
                let quantityUnit  = (data["quantityUnit"] as? String) ?? ""
                let quantityText: String = {
                    if quantityValue == "—" { return "—" }
                    if quantityUnit.isEmpty { return quantityValue }
                    return "\(quantityValue) \(quantityUnit)"
                }()

                let photoURLs = data["photoURLs"] as? [String] ?? []
                let imageUrl  = photoURLs.first ?? ""

                let donorName = (data["donorName"] as? String) ?? "—"
                let donorId   = (data["donorId"] as? String) ?? "—"
                let donorNameLine = "\(donorName) (ID: \(donorId))"
                    .replacingOccurrences(of: "— (ID: —)", with: "—")

                let donorAddress = (data["donorAddress"] as? String) ?? "—"
                let city = (data["donorCity"] as? String) ?? "—"
                let country = (data["donorCountry"] as? String) ?? "—"
                let cityCountry = "\(city), \(country)".replacingOccurrences(of: "—, —", with: "—")

                let pickupMethod = (data["pickupMethod"] as? String) ?? "—"
                let donorEmail = (data["donorEmail"] as? String) ?? "—"
                let donorPhone = (data["donorPhone"] as? String) ?? "—"
                let donorNotes = (data["donorNotes"] as? String) ?? "—"

                var pickupDateText = "—"
                var pickupTimeText = "—"
                var pickupStatusText = "—"
                var locationTypeText = "—"

                if let pickup = data["pickup"] as? [String: Any] {
                    pickupDateText = self.formatTimestamp(pickup["date"])
                    pickupTimeText = (pickup["time"] as? String) ?? (pickup["timeSlot"] as? String) ?? "—"
                    pickupStatusText = (pickup["status"] as? String) ?? "—"
                    locationTypeText = (pickup["locationType"] as? String) ?? "—"
                } else {
                    pickupDateText = self.formatTimestamp(data["pickupDate"])
                    pickupTimeText = (data["pickupTime"] as? String) ?? "—"
                    pickupStatusText = (data["pickupStatus"] as? String) ?? "—"
                    locationTypeText = (data["locationType"] as? String) ?? "—"
                }

                DispatchQueue.main.async {
                    self.donationIdLabel?.text = donationCode
                    self.itemNameLabel?.text = itemName
                    self.quantityLabel?.text = quantityText
                    self.categoryLabel?.text = category
                    self.expiryDateLabel?.text = expiryText
                    self.packagingLabel?.text = packaging
                    self.allergenLabel?.text = allergen
                    self.notesLabel?.text = notes

                    self.applyStatusBadge(statusStr)
                    self.loadImage(into: self.donationImageView, urlString: imageUrl)

                    self.donorNameLabel?.text = donorNameLine
                    self.donorAddressLabel?.text = donorAddress
                    self.donorCityCountryLabel?.text = cityCountry
                    self.pickupMethodLabel?.text = pickupMethod
                    self.donorEmailLabel?.text = donorEmail
                    self.donorPhoneLabel?.text = donorPhone
                    self.donorNotesLabel?.text = donorNotes

                    self.pickupDateLabel?.text = pickupDateText
                    self.pickupTimeLabel?.text = pickupTimeText
                    self.pickupStatusLabel?.text = pickupStatusText
                    self.locationTypeLabel?.text = locationTypeText
                }
            }
    }

    private func applyStatusBadge(_ status: String) {
        let s = status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        statusLabel?.text = s.capitalized
        statusBadgeView?.layer.cornerRadius = 10
        statusBadgeView?.clipsToBounds = true

        switch s {
        case "approved":
            statusBadgeView?.backgroundColor = UIColor(hex: "#D5F4D6")
        case "rejected":
            statusBadgeView?.backgroundColor = UIColor(hex: "#F29C94")
        default:
            statusBadgeView?.backgroundColor = UIColor(hex: "#FFF4BF")
        }
        statusLabel?.textColor = .black
    }

    // ✅ Proceed -> Inspect (Push ONLY)
    @IBAction func proceedToInspectionTapped(_ sender: UIButton) {

        let id = (donationId ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty else {
            print("❌ Details: donationId NIL before opening Inspect")
            return
        }

        print("➡️ Opening Inspect with id:", id)

        let vc = storyboard!.instantiateViewController(withIdentifier: "InspectDonationViewController") as! InspectDonationViewController
        vc.donationId = id
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Helpers
    private func formatTimestamp(_ any: Any?) -> String {
        if let ts = any as? Timestamp {
            return Self.dateFormatter.string(from: ts.dateValue())
        }
        return "—"
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

    private func loadImage(into imageView: UIImageView?, urlString: String) {
        imageView?.image = nil
        let clean = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty, let url = URL(string: clean) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { imageView?.image = img }
        }.resume()
    }
}
