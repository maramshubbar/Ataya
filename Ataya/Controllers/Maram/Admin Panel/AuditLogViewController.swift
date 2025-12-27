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
    private var listener: ListenerRegistration?

    // كل الداتا من Firestore
    private var allItems: [AuditLogItem] = []

    // الداتا المعروضة بعد الفلتر + البحث
    private var shownItems: [AuditLogItem] = []

    // ✅ DateFormatter ثابت (أفضل للأداء)
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // SearchBar UI
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = .white
            searchField.layer.cornerRadius = 10
            searchField.clipsToBounds = true
        }

        // Delegates
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self

        // Table view style
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160

        // ✅ يخلي الكيبورد يختفي لما يسحبون
        tableView.keyboardDismissMode = .onDrag

        // Register XIB
        let nib = UINib(nibName: "AuditLogTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AuditLogTableViewCell")

        // Segment change (بدون توصيل IBAction)
        filterSegment.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
    }

    // ✅ شغلي الليسنر لما الصفحة تظهر
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListening()
    }

    // ✅ وقفي الليسنر لما الصفحة تختفي (عشان ما يظل يقرأ بالخلفية)
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
        listener = nil
    }

    deinit {
        listener?.remove()
    }

    // MARK: - Firestore Listener
    private func startListening() {
        // ✅ امنعي تكرار listeners
        listener?.remove()
        listener = nil

        // ترتيب حسب createdAt (الأحدث فوق)
        listener = db.collection("audit_logs")
            .order(by: "createdAt", descending: true)
            .limit(to: 100)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }

                if let err = err {
                    print("❌ Audit logs error:", err.localizedDescription)
                    return
                }

                let docs = snap?.documents ?? []
                self.allItems = docs.compactMap { d in
                    let data = d.data()

                    let title = data["title"] as? String ?? ""
                    let user = data["user"] as? String ?? ""
                    let action = data["action"] as? String ?? ""
                    let location = data["location"] as? String ?? ""
                    let status = data["status"] as? String ?? ""
                    let category = data["category"] as? String ?? "System"

                    let ts = data["createdAt"] as? Timestamp
                    let createdAt = ts?.dateValue() ?? Date.distantPast

                    return AuditLogItem(
                        title: title,
                        user: user,
                        action: action,
                        location: location,
                        status: status,
                        category: category,
                        createdAt: createdAt
                    )
                }

                // ✅ UI تحديث على الـ Main Thread
                DispatchQueue.main.async {
                    self.applyFiltersAndReload()
                }
            }
    }

    // MARK: - Filtering / Search
    @objc private func filterChanged() {
        applyFiltersAndReload()
    }

    private func applyFiltersAndReload() {
        let selectedCategory = categoryFromSegmentIndex(filterSegment.selectedSegmentIndex)
        let searchText = (searchBar.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

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
        // حسب UI عندج: All / Donations / Campaigns / Accounts / System
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

    // MARK: - Table View Data
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
        cell.statusValueLabel.text = item.status

        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension AuditLogViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFiltersAndReload()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        applyFiltersAndReload()
    }
}
