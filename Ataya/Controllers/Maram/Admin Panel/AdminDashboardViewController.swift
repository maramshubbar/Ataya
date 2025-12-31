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

    // ✅ Outlets للأرقام الأربع (اربطيهم على Labels اللي فيها الأرقام)
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

    @IBAction func donationOverviewTapped(_ sender: Any) {
        performSegue(withIdentifier: "sgDonationOverview", sender: self)
    }

    private let cardCornerRadius: CGFloat = 16

    // ✅ Firestore + listeners
    private let db = Firestore.firestore()
    private var statsListener: ListenerRegistration?
    private var activityListener: ListenerRegistration?

    // ✅ بدل let activities
    private var activities: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

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

        // ✅ ابدأ listening بعد ما تجهز UI
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

    // MARK: - Firestore Listening
    private func startListening() {

        // 1) Stats listener
        statsListener = db.collection("admin_stats").document("global")
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err = err {
                    print("❌ Stats error:", err.localizedDescription)
                    return
                }

                let data = snap?.data() ?? [:]

                let registeredUsers     = self.intValue(data["registeredUsers"])
                let totalDonations      = self.intValue(data["totalDonations"])
                let flaggedReports      = self.intValue(data["flaggedReports"])
                let verifiedCollectors  = self.intValue(data["verifiedCollectors"])

                DispatchQueue.main.async {
                    self.lblRegisteredUsersValue.text = self.formatNumber(registeredUsers)
                    self.lblFlaggedReportsValue.text = self.formatNumber(flaggedReports)
                    self.lblVerifiedCollectorsValue.text = self.formatNumber(verifiedCollectors)

                    // إذا تبينه مبلغ:
                    self.lblTotalDonationsValue.text = "$" + self.formatNumber(totalDonations)
                }
            }

        // 2) Recent activity listener
        activityListener = db.collection("audit_logs")
            .order(by: "createdAt", descending: true)
            .limit(to: 10)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err = err {
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

                    // ركّبي النص مثل ما تبين
                    // مثال: "Donation Approved • Zahraa Ali • Manama, Bahrain"
                    var parts: [String] = []
                    if !title.isEmpty { parts.append(title) }
                    if !user.isEmpty { parts.append(user) }
                    if !location.isEmpty { parts.append(location) }
                    if parts.isEmpty { parts.append(category) }

                    return parts.joined(separator: " • ")
                }

                DispatchQueue.main.async {
                    self.tblRecentActivity.reloadData()
                    self.updateRecentActivityTableHeight()
                }
            }
    }

    deinit {
        statsListener?.remove()
        activityListener?.remove()
    }

    // MARK: - Helpers
    private func intValue(_ any: Any?) -> Int {
        if let v = any as? Int { return v }
        if let v = any as? Int64 { return Int(v) }
        if let v = any as? Double { return Int(v) }
        if let v = any as? NSNumber { return v.intValue }
        return 0
    }

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
