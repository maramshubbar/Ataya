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
    @IBOutlet weak var proceedButton: UIButton?

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

    // MARK: - Pickup/Collection card
    @IBOutlet weak var pickupDateLabel: UILabel?
    @IBOutlet weak var pickupTimeLabel: UILabel?
    @IBOutlet weak var pickupStatusLabel: UILabel?
    @IBOutlet weak var locationTypeLabel: UILabel?
    @IBOutlet weak var collectionNotesLabel: UILabel?

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()

    // MARK: - Mode (3 statuses)
    private enum DonationStatus: Equatable {
        case pending
        case approved
        case rejected
        case other(String)

        init(from raw: String?) {
            let s = (raw ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()

            if s.contains("pend") { self = .pending; return }

            // ✅ Approved bucket (يشمل Successful/Collected/Completed...)
            if s == "approved" || s.contains("success") || s.contains("collect") || s.contains("complete") || s == "accept" {
                self = .approved
                return
            }

            // ✅ Rejected bucket
            if s == "rejected" || s.contains("reject") {
                self = .rejected
                return
            }

            self = s.isEmpty ? .pending : .other(s)
        }

        var title: String {
            switch self {
            case .pending:  return "Pending"
            case .approved: return "Approved"
            case .rejected: return "Rejected"
            case .other:    return "Pending"
            }
        }

        var canProceedToInspection: Bool {
            if case .pending = self { return true }
            return false
        }

        var badgeHex: String {
            switch self {
            case .approved: return "#D5F4D6" // ✅ أخضر
            case .rejected: return "#F29C94" // ✅ أحمر
            default:        return "#FFF4BF" // ✅ أصفر
            }
        }
    }

    private var currentStatus: DonationStatus = .pending

    // ✅ يخلي زر proceed يختفي بدون يترك مساحة (اختياري)
    private var proceedHeightConstraint: NSLayoutConstraint?
    private var proceedOriginalHeight: CGFloat = 0

    // ✅ caching عشان لا يسوي fetch كل مرة
    private var lastDonorUid: String?
    private var lastPickupKeySig: String?
    private var lastReportKeySig: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        print("✅ Details donationId:", donationId ?? "nil")
        title = "Donation Details"

        styleCard(donationCardView)
        styleCard(donorCardView)
        styleCard(collectorCardView)

        proceedButton?.layer.cornerRadius = 12
        proceedButton?.clipsToBounds = true
        proceedButton?.backgroundColor = .atayaYellow
        proceedButton?.setTitleColor(.black, for: .normal)
        proceedButton?.setTitleColor(.black.withAlphaComponent(0.4), for: .disabled)
        proceedButton?.setTitle("Proceed to Inspection", for: .normal)

        donationImageView?.contentMode = .scaleAspectFit
        donationImageView?.clipsToBounds = true

        collectionNotesLabel?.numberOfLines = 0

        // placeholders
        setDonorUIPlaceholders(publicId: "—")
        setPickupUIPlaceholders()
        collectionNotesLabel?.text = "—"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if proceedOriginalHeight == 0 {
            proceedOriginalHeight = max(1, proceedButton?.bounds.height ?? 0)
        }

        if proceedHeightConstraint == nil, let btn = proceedButton {
            if let c = btn.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .equal }) {
                proceedHeightConstraint = c
            }
        }
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
            applyMode(.pending)
            return
        }

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

                // ✅ IDs
                let donationCode = (data["id"] as? String) ?? docId
                let donorUid = (data["donorId"] as? String) ?? ""
                let donorPublicId = (data["donorPublicId"] as? String)
                                 ?? (data["donorCode"] as? String)
                                 ?? donorUid

                // ✅ basic donation info
                let itemName  = (data["itemName"] as? String) ?? "—"
                let statusRaw = (data["status"] as? String) ?? "pending"
                let status    = DonationStatus(from: statusRaw)

                let category  = (data["category"] as? String) ?? "—"
                let packaging = (data["packagingType"] as? String) ?? (data["packaging"] as? String) ?? "—"
                let allergen  = (data["allergenInfo"] as? String) ?? "—"
                let notes     = (data["notes"] as? String) ?? "—"

                let expiryText = self.formatDate(data["expiryDate"])
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

                // ✅ donor info FROM donation doc (fallback)
                let donorNameFromDonation   = (data["donorName"] as? String) ?? "—"
                let donorEmailFromDonation  = (data["donorEmail"] as? String) ?? "—"
                let donorPhoneFromDonation  = (data["donorPhone"] as? String) ?? "—"
                let donorAddressFromDonation = (data["donorAddress"] as? String) ?? "—"
                let donorCityFromDonation   = (data["donorCity"] as? String) ?? "—"
                let donorCountryFromDonation = (data["donorCountry"] as? String) ?? "—"
                let donorCityCountryFromDonation =
                    "\(donorCityFromDonation), \(donorCountryFromDonation)"
                        .replacingOccurrences(of: "—, —", with: "—")
                let pickupMethodFromDonation = (data["pickupMethod"] as? String) ?? "—"
                let donorNotesFromDonation   = (data["donorNotes"] as? String) ?? "—"

                // ✅ pickup placeholders from donation doc (إذا موجود)
                let pickupDict = data["pickup"] as? [String: Any]
                let pickupDateText = self.formatDate(pickupDict?["date"] ?? data["pickupDate"])
                let pickupTimeText = (pickupDict?["time"] as? String)
                                  ?? (pickupDict?["timeSlot"] as? String)
                                  ?? (data["pickupTime"] as? String) ?? "—"
                let pickupStatusText = (pickupDict?["status"] as? String)
                                    ?? (data["pickupStatus"] as? String) ?? "—"
                let locationTypeText = (pickupDict?["locationType"] as? String)
                                    ?? (data["locationType"] as? String) ?? "—"

                DispatchQueue.main.async {
                    // donation card
                    self.donationIdLabel?.text = donationCode
                    self.itemNameLabel?.text = itemName
                    self.quantityLabel?.text = quantityText
                    self.categoryLabel?.text = category
                    self.expiryDateLabel?.text = expiryText
                    self.packagingLabel?.text = packaging
                    self.allergenLabel?.text = allergen
                    self.notesLabel?.text = notes

                    self.applyMode(status)
                    self.loadImage(into: self.donationImageView, urlString: imageUrl)

                    // ✅ Donor UI from donation doc first
                    let donorNameLine =
                        "\(donorNameFromDonation) (ID: \(donorPublicId))"
                            .replacingOccurrences(of: "— (ID: —)", with: "—")

                    self.donorNameLabel?.text = donorNameLine
                    self.donorAddressLabel?.text = donorAddressFromDonation
                    self.donorCityCountryLabel?.text = donorCityCountryFromDonation
                    self.pickupMethodLabel?.text = pickupMethodFromDonation
                    self.donorEmailLabel?.text = donorEmailFromDonation
                    self.donorPhoneLabel?.text = donorPhoneFromDonation
                    self.donorNotesLabel?.text = donorNotesFromDonation

                    // pickup basic
                    self.pickupDateLabel?.text = pickupDateText
                    self.pickupTimeLabel?.text = pickupTimeText
                    self.pickupStatusLabel?.text = pickupStatusText
                    self.locationTypeLabel?.text = locationTypeText
                }

                // ✅ مفاتيح البحث (أحيانًا collections ثانية تستخدم donationCode بدل docId)
                let keys = [docId, donationCode].filter { !$0.isEmpty }

                // ✅ fetch donor from users/{donorId} (يحسّن البيانات إذا موجودة)
                self.fetchDonorFromUsersIfNeeded(uid: donorUid, fallbackPublicId: donorPublicId)

                // ✅ fetch pickup from pickups
                self.fetchPickupIfNeeded(keys: keys)

                // ✅ fetch inspection/report (reports) عشان يعبي Collection Info + Notes
                self.fetchLatestNgoReportIfNeeded(keys: keys, currentStatus: status)
            }
    }

    // ✅ هنا “المود” حق الثلاث حالات
    private func applyMode(_ status: DonationStatus) {
        currentStatus = status

        statusLabel?.text = status.title
        statusBadgeView?.layer.cornerRadius = 10
        statusBadgeView?.clipsToBounds = true
        statusBadgeView?.backgroundColor = UIColor(hex: status.badgeHex)
        statusLabel?.textColor = .black

        let showProceed = status.canProceedToInspection

        proceedButton?.isEnabled = showProceed
        proceedButton?.alpha = showProceed ? 1 : 0
        proceedButton?.isUserInteractionEnabled = showProceed
        proceedButton?.isHidden = !showProceed

        if let h = proceedHeightConstraint {
            h.constant = showProceed ? (proceedOriginalHeight == 0 ? 52 : proceedOriginalHeight) : 0
            view.layoutIfNeeded()
        }
    }

    // ✅ Proceed -> Inspect (Push ONLY) + ممنوع إذا مو Pending
    @IBAction func proceedToInspectionTapped(_ sender: UIButton) {

        guard currentStatus.canProceedToInspection else {
            showAlert("Inspection is only for Pending donations.")
            return
        }

        let id = (donationId ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty else { return }

        let vc = storyboard!.instantiateViewController(withIdentifier: "InspectDonationViewController") as! InspectDonationViewController
        vc.donationId = id
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - DONOR (users/{uid})
    private func setDonorUIPlaceholders(publicId: String) {
        let idText = publicId.isEmpty ? "—" : publicId

        donorNameLabel?.text = "— (ID: \(idText))"
        donorAddressLabel?.text = "—"
        donorCityCountryLabel?.text = "—"
        pickupMethodLabel?.text = "—"
        donorEmailLabel?.text = "—"
        donorPhoneLabel?.text = "—"
        donorNotesLabel?.text = "—"
    }

    private func fetchDonorFromUsersIfNeeded(uid: String, fallbackPublicId: String) {
        let clean = uid.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        guard lastDonorUid != clean else { return }
        lastDonorUid = clean

        db.collection("users").document(clean).getDocument { [weak self] snap, err in
            guard let self else { return }

            if let err = err {
                print("❌ users/\(clean) error:", err.localizedDescription)
                return
            }

            guard let u = snap?.data() else {
                // إذا users ناقص، خلاص خليه على بيانات donation
                return
            }

            let name = (u["name"] as? String)
                    ?? (u["fullName"] as? String)
                    ?? (u["displayName"] as? String)
                    ?? (u["username"] as? String)
                    ?? "—"

            let publicId = (u["id"] as? String)
                        ?? (u["userId"] as? String)
                        ?? (u["donorId"] as? String)
                        ?? fallbackPublicId
                        ?? clean

            let email = (u["email"] as? String) ?? ""
            let phone = (u["phone"] as? String)
                     ?? (u["phoneNumber"] as? String)
                     ?? ""

            let address = (u["address"] as? String)
                       ?? (u["location"] as? String)
                       ?? ""

            let city = (u["city"] as? String) ?? ""
            let country = (u["country"] as? String) ?? ""
            let cityCountry = "\(city), \(country)".replacingOccurrences(of: ", ", with: ", ").trimmingCharacters(in: .whitespacesAndNewlines)

            DispatchQueue.main.async {
                // ✅ override only if values are non-empty
                let nameLine = "\(name) (ID: \(publicId))".replacingOccurrences(of: "— (ID: —)", with: "—")
                if !(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) && name != "—" {
                    self.donorNameLabel?.text = nameLine
                }
                if !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.donorAddressLabel?.text = address
                }
                if !cityCountry.replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                   cityCountry != "—" {
                    self.donorCityCountryLabel?.text = cityCountry
                }
                if !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.donorEmailLabel?.text = email
                }
                if !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.donorPhoneLabel?.text = phone
                }
            }
        }
    }

    // MARK: - PICKUP (pickups)
    private func setPickupUIPlaceholders() {
        pickupDateLabel?.text = "—"
        pickupTimeLabel?.text = "—"
        pickupStatusLabel?.text = "—"
        locationTypeLabel?.text = "—"
    }

    private func fetchPickupIfNeeded(keys: [String]) {
        let sig = keys.joined(separator: "|")
        guard !sig.isEmpty else { return }
        guard lastPickupKeySig != sig else { return }
        lastPickupKeySig = sig

        tryPickupsQuery(field: "donationId", keys: keys) { [weak self] doc in
            guard let self else { return }

            if doc == nil {
                self.tryPickupsQuery(field: "donationDocId", keys: keys) { [weak self] doc2 in
                    guard let self else { return }

                    if doc2 == nil {
                        self.tryPickupsQuery(field: "donationCode", keys: keys) { [weak self] doc3 in
                            guard let self else { return }
                            if let doc3 { self.applyPickupDoc(doc3) }
                        }
                    } else {
                        self.applyPickupDoc(doc2!)
                    }
                }
            } else {
                self.applyPickupDoc(doc!)
            }
        }
    }

    private func tryPickupsQuery(field: String, keys: [String], completion: @escaping (QueryDocumentSnapshot?) -> Void) {
        db.collection("pickups")
            .whereField(field, in: keys)
            .limit(to: 1)
            .getDocuments { snap, err in
                if let err = err {
                    print("❌ pickups query error (\(field)):", err.localizedDescription)
                    completion(nil)
                    return
                }
                completion(snap?.documents.first)
            }
    }

    private func applyPickupDoc(_ doc: QueryDocumentSnapshot) {
        let p = doc.data()

        let dateText = formatDate(p["date"])
        let timeText =
            (p["time"] as? String)
            ?? (p["timeSlot"] as? String)
            ?? formatTime(p["time"])
            ?? "—"

        let statusText = (p["status"] as? String) ?? "—"
        let locationText =
            (p["locationType"] as? String)
            ?? (p["location"] as? String)
            ?? "—"

        DispatchQueue.main.async {
            if (self.pickupDateLabel?.text ?? "—") == "—" { self.pickupDateLabel?.text = dateText }
            if (self.pickupTimeLabel?.text ?? "—") == "—" { self.pickupTimeLabel?.text = timeText }
            if (self.pickupStatusLabel?.text ?? "—") == "—" { self.pickupStatusLabel?.text = statusText }
            if (self.locationTypeLabel?.text ?? "—") == "—" { self.locationTypeLabel?.text = locationText }
        }
    }

    // MARK: - NGO REPORT (reports) يعبي Collection + Notes
    private func fetchLatestNgoReportIfNeeded(keys: [String], currentStatus: DonationStatus) {
        let sig = keys.joined(separator: "|")
        guard !sig.isEmpty else { return }
        guard lastReportKeySig != sig else { return }
        lastReportKeySig = sig

        tryReportQuery(field: "donationId", keys: keys) { [weak self] doc in
            guard let self else { return }

            if doc == nil {
                self.tryReportQuery(field: "donationDocId", keys: keys) { [weak self] doc2 in
                    guard let self else { return }
                    if let doc2 { self.applyReportDoc(doc2, currentStatus: currentStatus) }
                }
            } else {
                self.applyReportDoc(doc!, currentStatus: currentStatus)
            }
        }
    }

    private func tryReportQuery(field: String, keys: [String], completion: @escaping (QueryDocumentSnapshot?) -> Void) {
        db.collection("reports")
            .whereField(field, in: keys)
            .limit(to: 1)
            .getDocuments { snap, err in
                if let err = err {
                    print("❌ reports query error (\(field)):", err.localizedDescription)
                    completion(nil)
                    return
                }
                completion(snap?.documents.first)
            }
    }

    private func applyReportDoc(_ doc: QueryDocumentSnapshot, currentStatus: DonationStatus) {
        let r = doc.data()

        let decision = (r["decision"] as? String) ?? ""
        let createdAt = r["createdAt"] ?? r["updatedAt"]

        let decisionLower = decision.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let statusText: String = {
            if decisionLower == "reject" { return "Rejected upon inspection" }
            if decisionLower == "accept" { return "Approved upon inspection" }
            switch currentStatus {
            case .rejected: return "Rejected"
            case .approved: return "Approved"
            default: return "—"
            }
        }()

        let dateText = formatDate(createdAt)
        let timeText = formatTime(createdAt) ?? "—"

        // ✅ NOTES from reports
        let reason = ((r["reason"] as? String) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let desc   = ((r["description"] as? String) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let extra  = ((r["notes"] as? String) ?? (r["note"] as? String) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        let parts = [reason, desc, extra].filter { !$0.isEmpty }
        let finalNotes = parts.isEmpty ? "—" : parts.joined(separator: " • ")

        DispatchQueue.main.async {
            if (self.pickupStatusLabel?.text ?? "—") == "—" { self.pickupStatusLabel?.text = statusText }
            if (self.pickupDateLabel?.text ?? "—") == "—" { self.pickupDateLabel?.text = dateText }
            if (self.pickupTimeLabel?.text ?? "—") == "—" { self.pickupTimeLabel?.text = timeText }
            if (self.locationTypeLabel?.text ?? "—") == "—" { self.locationTypeLabel?.text = "NGO Collection Centre" }

            self.collectionNotesLabel?.text = finalNotes
//            self.collectionNotesRowStack?.isHidden = (finalNotes == "—")
        }
    }

                
    // MARK: - Helpers
    private func formatDate(_ any: Any?) -> String {
        if let ts = any as? Timestamp {
            return Self.dateFormatter.string(from: ts.dateValue())
        }
        if let d = any as? Date {
            return Self.dateFormatter.string(from: d)
        }
        return "—"
    }

    private func formatTime(_ any: Any?) -> String? {
        if let ts = any as? Timestamp {
            return Self.timeFormatter.string(from: ts.dateValue())
        }
        if let d = any as? Date {
            return Self.timeFormatter.string(from: d)
        }
        return nil
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

    private func showAlert(_ msg: String) {
        let a = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
