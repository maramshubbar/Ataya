//
//  AdminDashboardViewController.swift
//  Ataya
//
//  Created by Maram on 24/11/2025.
//

import UIKit
import FirebaseFirestore

final class AdminDashboardViewController: UIViewController {

    // MARK: - Outlets (Cards)
    @IBOutlet private weak var cardRegisteredUsers: UIView!
    @IBOutlet private weak var cardTotalDonations: UIView!
    @IBOutlet private weak var cardFlaggedReports: UIView!
    @IBOutlet private weak var cardVerifiedCollectors: UIView!

    // ✅ Outlets للأرقام الأربع
    @IBOutlet private weak var lblRegisteredUsersValue: UILabel!
    @IBOutlet private weak var lblTotalDonationsValue: UILabel!
    @IBOutlet private weak var lblFlaggedReportsValue: UILabel!
    @IBOutlet private weak var lblVerifiedCollectorsValue: UILabel!

    // Quick Links Views
    @IBOutlet weak var donationOverviewCard: UIView!
    @IBOutlet weak var auditLogCard: UIView!

    // Recent Activity Table
    @IBOutlet weak var tblRecentActivity: UITableView!
    @IBOutlet weak var tblRecentActivityHeight: NSLayoutConstraint!

    // MARK: - Actions
    @IBAction func donationOverviewTapped(_ sender: Any) {
        performSegue(withIdentifier: "sgDonationOverview", sender: self)
    }

    private let cardCornerRadius: CGFloat = 16

    // MARK: - Firestore
    private let db = Firestore.firestore()

    // ✅ Listeners (بدل admin_stats)
    private var registeredUsersListener: ListenerRegistration?
    private var totalDonationsListener: ListenerRegistration?
    private var flaggedReportsListener: ListenerRegistration?
    private var verifiedCollectorsListener: ListenerRegistration?
    private var activityListener: ListenerRegistration?

    // Recent activity text rows
    private var activities: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Quick links tap
        donationOverviewCard.isUserInteractionEnabled = true
        auditLogCard.isUserInteractionEnabled = true

        donationOverviewCard.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(openDonationOverview))
        )
        auditLogCard.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(openAuditLog))
        )

        // Table setup
        tblRecentActivity.dataSource = self
        tblRecentActivity.delegate = self
        tblRecentActivity.isScrollEnabled = false
        tblRecentActivity.rowHeight = UITableView.automaticDimension
        tblRecentActivity.estimatedRowHeight = 120

        // Quick links border
        styleCard(donationOverviewCard)
        styleCard(auditLogCard)

        // Cards shadow
        let cards: [UIView] = [
            cardRegisteredUsers,
            cardTotalDonations,
            cardFlaggedReports,
            cardVerifiedCollectors
        ]
        cards.forEach { $0.applyCardShadow(cornerRadius: cardCornerRadius) }

        // ✅ Start listeners
        startListening()
    }

    @objc private func openDonationOverview() {
        performSegue(withIdentifier: "sgDonationOverview", sender: self)
    }

    @objc private func openAuditLog() {
        performSegue(withIdentifier: "sgAuditLog", sender: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let cards: [UIView] = [
            cardRegisteredUsers,
            cardTotalDonations,
            cardFlaggedReports,
            cardVerifiedCollectors
        ]
        cards.forEach { $0.updateShadowPath(cornerRadius: cardCornerRadius) }

        updateRecentActivityTableHeight()
    }

    private func updateRecentActivityTableHeight() {
        tblRecentActivity.layoutIfNeeded()
        tblRecentActivityHeight.constant = tblRecentActivity.contentSize.height
    }

    private func styleCard(_ v: UIView) {
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1).cgColor
        v.layer.masksToBounds = true
        v.backgroundColor = .white
    }

    // MARK: - Firestore Listening (REAL DATA)
    private func startListening() {

        // 1) Registered Users = donor + collector (من users)
        registeredUsersListener = db.collection("users")
            .whereField("role", in: ["donor", "ngo"])
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err {
                    print("❌ RegisteredUsers error:", err.localizedDescription)
                    return
                }
                let count = snap?.documents.count ?? 0
                DispatchQueue.main.async {
                    self.lblRegisteredUsersValue.text = self.formatNumber(count)
                }
            }

        // 2) Total Donations = COUNT documents in donations (مو مبلغ)
        // إذا تبين فقط المكتملة: ضيفي whereField("status", isEqualTo: "completed")
        totalDonationsListener = db.collection("donations")
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err {
                    print("❌ TotalDonations error:", err.localizedDescription)
                    return
                }
                let count = snap?.documents.count ?? 0
                DispatchQueue.main.async {
                    self.lblTotalDonationsValue.text = self.formatNumber(count)
                }
            }

        // 3) Flagged Reports = status == "flagged" (من reports)
        flaggedReportsListener = db.collection("reports")
            .whereField("status", isEqualTo: "flagged")
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err {
                    print("❌ FlaggedReports error:", err.localizedDescription)
                    return
                }
                let count = snap?.documents.count ?? 0
                DispatchQueue.main.async {
                    self.lblFlaggedReportsValue.text = self.formatNumber(count)
                }
            }

        // 4) Verified Collectors = role == collector AND isVerified == true (من users)
        verifiedCollectorsListener = db.collection("users")
            .whereField("role", isEqualTo: "ngo")
            .whereField("isVerified", isEqualTo: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err {
                    print("❌ VerifiedCollectors error:", err.localizedDescription)
                    return
                }
                let count = snap?.documents.count ?? 0
                DispatchQueue.main.async {
                    self.lblVerifiedCollectorsValue.text = self.formatNumber(count)
                }
            }

        // 5) Recent Activity (من audit_logs)
        activityListener = db.collection("audit_logs")
            .order(by: "createdAt", descending: true)
            .limit(to: 10)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err {
                    print("❌ Activity error:", err.localizedDescription)
                    return
                }

                let docs = snap?.documents ?? []
                self.activities = docs.map { doc in
                    let d = doc.data()
                    let title = d["title"] as? String ?? ""
                    let user = d["user"] as? String ?? ""
                    let location = d["location"] as? String ?? ""
                    let category = d["category"] as? String ?? ""

                    // مثال: "Donation Approved • Zahraa Ali • Manama, Bahrain"
                    var parts: [String] = []
                    if !title.isEmpty { parts.append(title) }
                    if !user.isEmpty { parts.append(user) }
                    if !location.isEmpty { parts.append(location) }
                    if parts.isEmpty, !category.isEmpty { parts.append(category) }
                    if parts.isEmpty { parts.append("Activity") }

                    return parts.joined(separator: " • ")
                }

                DispatchQueue.main.async {
                    self.tblRecentActivity.reloadData()
                    self.updateRecentActivityTableHeight()
                }
            }
    }

    deinit {
        registeredUsersListener?.remove()
        totalDonationsListener?.remove()
        flaggedReportsListener?.remove()
        verifiedCollectorsListener?.remove()
        activityListener?.remove()
    }

    // MARK: - Helpers
    private func formatNumber(_ n: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}

// MARK: - Card Shadow Helpers
private extension UIView {

    func applyCardShadow(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.09
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 4)

        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    func updateShadowPath(cornerRadius: CGFloat) {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}

// MARK: - Table DataSource / Delegate
extension AdminDashboardViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cellActivity", for: indexPath)

        // IMPORTANT: تأكدي lblActivityText Tag = 2 في Storyboard
        let lbl = cell.viewWithTag(2) as? UILabel
        lbl?.text = activities[indexPath.row]
        lbl?.numberOfLines = 0

        cell.selectionStyle = .none
        return cell
    }
}
