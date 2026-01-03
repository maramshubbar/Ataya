import UIKit
import FirebaseFirestore

struct AuditLogItem {
    let title: String
    let user: String
    let action: String
    let location: String
    let status: String
    let category: String
    let createdAt: Date
}

final class AuditLogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterSegment: UISegmentedControl!

    private let db = Firestore.firestore()

    // ✅ 3 listeners
    private var auditListener: ListenerRegistration?
    private var campaignsListener: ListenerRegistration?
    private var donationsListener: ListenerRegistration?

    private var auditItems: [AuditLogItem] = []
    private var campaignItems: [AuditLogItem] = []
    private var donationItems: [AuditLogItem] = []

    private var allItems: [AuditLogItem] = []
    private var shownItems: [AuditLogItem] = []

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    private let auditLogsCol = "audit_logs"
    private let campaignsCol = "campaigns"
    private let donationsCol = "donations"

    override func viewDidLoad() {
        super.viewDidLoad()

        // ✅ SearchBar UI
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.showsCancelButton = false

        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = .white
            searchField.layer.cornerRadius = 10
            searchField.clipsToBounds = true
        }

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self

        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160
        tableView.keyboardDismissMode = .onDrag

        let nib = UINib(nibName: "AuditLogTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AuditLogTableViewCell")

        filterSegment.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListening()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListening()
    }

    deinit { stopListening() }

    private func stopListening() {
        auditListener?.remove()
        auditListener = nil

        campaignsListener?.remove()
        campaignsListener = nil

        donationsListener?.remove()
        donationsListener = nil
    }

    // MARK: - Firestore Listening

    private func startListening() {
        stopListening()

        // 1) ✅ audit_logs
        auditListener = db.collection(auditLogsCol)
            .order(by: "createdAt", descending: true)
            .limit(to: 200)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }

                if let err = err {
                    print("❌ audit_logs error:", err.localizedDescription)
                    self.auditItems = []
                    self.rebuildMergedAndReload()
                    return
                }

                let docs = snap?.documents ?? []
                self.auditItems = docs.compactMap { d in
                    let data = d.data()

                    let title = self.clean(data["title"] as? String)
                    let user = self.clean(data["user"] as? String)
                    let action = self.clean(data["action"] as? String)
                    let location = self.clean(data["location"] as? String)
                    let status = self.clean(data["status"] as? String)
                    let category = self.clean(data["category"] as? String)

                    let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date.distantPast

                    return AuditLogItem(
                        title: self.nonEmpty(title, fallback: "Activity"),
                        user: self.nonEmpty(user, fallback: "Admin"),
                        action: action,
                        location: self.nonEmpty(location, fallback: "—"),
                        status: status,
                        category: self.nonEmpty(category, fallback: "System"),
                        createdAt: createdAt
                    )
                }

                self.rebuildMergedAndReload()
            }

        // 2) ✅ campaigns -> Campaign Created
        campaignsListener = db.collection(campaignsCol)
            .order(by: "createdAt", descending: true)
            .limit(to: 200)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }

                if let err = err {
                    print("❌ campaigns error:", err.localizedDescription)
                    self.campaignItems = []
                    self.rebuildMergedAndReload()
                    return
                }

                let docs = snap?.documents ?? []
                self.campaignItems = docs.map { d in
                    let data = d.data()

                    let campaignTitle = self.stringValue(data, keys: ["title", "name", "campaignTitle"])
                    let createdByName = self.stringValue(data, keys: ["createdByName", "adminName", "creatorName", "userName"])
                    let ngoName = self.stringValue(data, keys: ["organization", "ngoName", "from", "ngo"])
                    let goal = self.stringValue(data, keys: ["goalAmount", "goal", "targetAmount"])
                    let location = self.stringValue(data, keys: ["location", "city", "country", "address"])
                    let status = self.stringValue(data, keys: ["status"])

                    let createdAt = self.extractDocDate(data) ?? Date.distantPast

                    let campFinal = self.nonEmpty(campaignTitle, fallback: "Campaign")
                    let userFinal = self.nonEmpty(createdByName, fallback: "Admin")

                    var actionText = "Created a new campaign “\(campFinal)”."
                    if !ngoName.isEmpty { actionText += " Under NGO \(ngoName)." }
                    if !goal.isEmpty { actionText += " Goal: \(goal)." }

                    return AuditLogItem(
                        title: "Campaign Created",
                        user: userFinal,
                        action: actionText,
                        location: self.nonEmpty(location, fallback: "—"),
                        status: self.nonEmpty(status, fallback: "Campaign Active"),
                        category: "Campaigns",
                        createdAt: createdAt
                    )
                }

                self.rebuildMergedAndReload()
            }

        // 3) donations -> Donation Submitted / Donation Status Changed
        donationsListener = db.collection(donationsCol)
            .order(by: "createdAt", descending: true)
            .limit(to: 200)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }

                if let err = err {
                    print("❌ donations error:", err.localizedDescription)
                    self.donationItems = []
                    self.rebuildMergedAndReload()
                    return
                }

                let docs = snap?.documents ?? []
                self.donationItems = docs.map { d in
                    let data = d.data()

                    // DonationOverview
                    let donationId = self.stringValue(data, keys: ["id"]).ifEmpty(d.documentID)
                    let itemName = self.stringValue(data, keys: ["itemName", "title", "foodItem"])
                    let donorName = self.stringValue(data, keys: ["donorName", "name", "fullName"])
                    let donorId = self.stringValue(data, keys: ["donorId"])
                    let statusRaw = self.stringValue(data, keys: ["status"])
                    let niceStatus = self.prettyDonationStatus(statusRaw)

                    // Location
                    let location =
                        self.stringValue(data, keys: ["location", "address", "city", "country"])

                    // NGO name
                    let ngoName =
                        self.stringValue(data, keys: ["ngoName", "assignedNgoName", "selectedNgoName", "ngo"])

                    let createdAt = self.extractDocDate(data) ?? Date.distantPast

                    let who = self.nonEmpty(donorName, fallback: donorId.isEmpty ? "Donor" : "Donor \(donorId)")
                    let itemFinal = self.nonEmpty(itemName, fallback: donationId)

                    // Action text
                    var actionText = "\(who) submitted donation “\(itemFinal)” (\(donationId))."
                    if !ngoName.isEmpty {
                        actionText += " Assigned to NGO \(ngoName)."
                    }

                    // Title
                    let title = (statusRaw.isEmpty) ? "Donation Submitted" : "Donation \(niceStatus)"

                    return AuditLogItem(
                        title: title,
                        user: who,
                        action: actionText,
                        location: self.nonEmpty(location, fallback: "—"),
                        status: niceStatus,         // Pending / Approved / Rejected...
                        category: "Donations",
                        createdAt: createdAt
                    )
                }

                self.rebuildMergedAndReload()
            }
    }

    private func rebuildMergedAndReload() {
        allItems = (auditItems + campaignItems + donationItems).sorted { $0.createdAt > $1.createdAt }
        DispatchQueue.main.async { self.applyFiltersAndReload() }
    }

    // MARK: - Filtering / Search

    @objc private func filterChanged() {
        applyFiltersAndReload()
    }

    private func applyFiltersAndReload() {
        let selectedCategory = categoryFromSegmentIndex(filterSegment.selectedSegmentIndex)
        let searchText = clean(searchBar.text).lowercased()

        var items = allItems

        if selectedCategory != "All" {
            items = items.filter { $0.category.caseInsensitiveCompare(selectedCategory) == .orderedSame }
        }

        if !searchText.isEmpty {
            items = items.filter { item in
                let haystack = [
                    item.title, item.user, item.action, item.location, item.status, item.category
                ].joined(separator: " ").lowercased()
                return haystack.contains(searchText)
            }
        }

        shownItems = items
        tableView.reloadData()
    }

    private func categoryFromSegmentIndex(_ index: Int) -> String {
        switch index {
        case 0: return "All"
        case 1: return "Donations"
        case 2: return "Campaigns"
        case 3: return "Accounts"
        case 4: return "System"
        default: return "All"
        }
    }

    private func formatDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    // MARK: - Table View

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shownItems.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AuditLogTableViewCell",
            for: indexPath
        ) as! AuditLogTableViewCell

        let item = shownItems[indexPath.row]

        cell.titleLabel.text = item.title
        cell.userValueLabel.text = item.user
        cell.actionValueLabel.text = item.action
        cell.locationValueLabel.text = item.location
        cell.dateValueLabel.text = formatDate(item.createdAt)

        cell.statusValueLabel.text = item.status.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? item.category : item.status

        cell.selectionStyle = .none
        return cell
    }

    // MARK: - Helpers 

    private func clean(_ s: String?) -> String {
        (s ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func nonEmpty(_ s: String, fallback: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? fallback : s
    }

    private func stringValue(_ data: [String: Any], keys: [String]) -> String {
        for k in keys {
            if let s = data[k] as? String {
                let c = s.trimmingCharacters(in: .whitespacesAndNewlines)
                if !c.isEmpty { return c }
            }
        }
        return ""
    }

    private func extractDocDate(_ data: [String: Any]) -> Date? {
        if let ts = data["createdAt"] as? Timestamp { return ts.dateValue() }
        if let ts = data["created_at"] as? Timestamp { return ts.dateValue() }
        if let ts = data["timestamp"] as? Timestamp { return ts.dateValue() }
        if let ts = data["submittedAt"] as? Timestamp { return ts.dateValue() }
        if let ts = data["updatedAt"] as? Timestamp { return ts.dateValue() }
        if let ts = data["startDate"] as? Timestamp { return ts.dateValue() }
        return nil
    }

    private func prettyDonationStatus(_ raw: String) -> String {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if s.isEmpty { return "Pending" }
        if s == "pending" { return "Pending" }
        if s == "approved" { return "Approved" }
        if s == "rejected" { return "Rejected" }
        if s == "completed" { return "Completed" }
        return raw.isEmpty ? "Pending" : raw
    }
}

// MARK: - UISearchBarDelegate (بدون Cancel)
extension AuditLogViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.setShowsCancelButton(false, animated: false)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = false
        searchBar.setShowsCancelButton(false, animated: false)
        applyFiltersAndReload()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.setShowsCancelButton(false, animated: false)
        searchBar.resignFirstResponder()
    }
}

// ✅ Utility tiny
private extension String {
    func ifEmpty(_ fallback: String) -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? fallback : self
    }
}
