//
//  ReportManagementViewController.swift
//  Ataya
//
//  Created by Maram on 01/12/2025.
//
//
//  ReportManagementViewController.swift
//  Ataya
//
//  Created by Maram on 01/12/2025.
//
import UIKit
import FirebaseFirestore

struct ReportItem {
    let id: String
    let title: String

    let location: String
    let reporterText: String
    let ngoText: String

    let dateText: String
    let type: String           // donation / accounts
    let statusRaw: String      // pending / resolved
    let createdAt: Date
}

final class ReportManagementViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private let collectionName = "reports"

    private var allReports: [ReportItem] = []
    private var shownReports: [ReportItem] = []

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // SearchBar UI
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.showsCancelButton = false
        searchBar.delegate = self

        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = .white
            searchField.layer.cornerRadius = 10
            searchField.clipsToBounds = true
        }

        // Segment change
        filterSegment.addTarget(self, action: #selector(filterChanged), for: .valueChanged)

        // Table setup
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: "ReportCardCell", bundle: nil),
                           forCellReuseIdentifier: ReportCardCell.reuseId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 170
        tableView.keyboardDismissMode = .onDrag
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
        listener?.remove()
        listener = nil
    }

    private func formatNameWithId(name: String, id: String?) -> String {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanId = (id ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if cleanName.lowercased().contains("(id:") { return cleanName }
        if cleanId.isEmpty { return cleanName }
        return "\(cleanName) (ID: \(cleanId))"
    }

    private func displayStatusText(_ raw: String) -> String {
        raw.lowercased() == "resolved" ? "Resolved" : "Pending"
    }

    // MARK: - Firestore Listener
    private func startListening() {
        stopListening()

        let query = db.collection(collectionName)
            .order(by: "createdAt", descending: true)
            .limit(to: 200)

        listener = query.addSnapshotListener { [weak self] snap, err in
            guard let self else { return }

            if let err = err {
                print("❌ reports error:", err.localizedDescription)
                return
            }

            let docs = snap?.documents ?? []
            self.allReports = docs.compactMap { doc in
                let data = doc.data()

                let title = (data["title"] as? String ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                // ✅ type
                let typeFromFS = (data["type"] as? String ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased()

                let reporterName = (data["reporter"] as? String ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                let ngoName = (data["ngo"] as? String ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                let donorId = (data["donorId"] as? String ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                let ngoCode = (data["ngoCode"] as? String ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                let reporterText = self.formatNameWithId(name: reporterName, id: donorId)

                // status
                let statusRaw = (data["status"] as? String ?? "pending")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased()

                let ts = data["createdAt"] as? Timestamp
                let createdAt = ts?.dateValue() ?? Date.distantPast
                let dateText = Self.dateFormatter.string(from: createdAt)

  
                let inferredType: String = {
                    if !typeFromFS.isEmpty { return typeFromFS }   // donation / accounts

                    let t = title.lowercased()
                    if t.contains("donation") { return "donation" }

                    if !ngoName.isEmpty { return "accounts" }

                    // fallback
                    return "donation"
                }()

                // location
                let locationFromFS = (data["location"] as? String ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                let finalLocation: String
                let finalNgoText: String

                if inferredType == "donation" {
                    finalLocation = ""
                    finalNgoText = ""
                } else {
                    finalLocation = locationFromFS
                    finalNgoText = ngoName.isEmpty ? "" : self.formatNameWithId(name: ngoName, id: ngoCode)
                }

                return ReportItem(
                    id: doc.documentID,
                    title: title,
                    location: finalLocation,
                    reporterText: reporterText,
                    ngoText: finalNgoText,
                    dateText: dateText,
                    type: inferredType,
                    statusRaw: statusRaw,
                    createdAt: createdAt
                )
            }

            DispatchQueue.main.async {
                self.applyFiltersAndReload()
            }
        }
    }

    // MARK: - Filters + Search
    @objc private func filterChanged() {
        applyFiltersAndReload()
    }

    private func selectedSegmentKey() -> String {
        switch filterSegment.selectedSegmentIndex {
        case 0: return "all"
        case 1: return "donation"
        case 2: return "accounts"
        case 3: return "resolved"
        default: return "all"
        }
    }

    private func applyFiltersAndReload() {
        let key = selectedSegmentKey()
        let searchText = (searchBar.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        var items = allReports

        switch key {
        case "donation":
            items = items.filter { $0.type == "donation" }
        case "accounts":
            items = items.filter { $0.type == "accounts" }
        case "resolved":
            items = items.filter { $0.statusRaw == "resolved" }
        default:
            break
        }

        if !searchText.isEmpty {
            items = items.filter { r in
                let haystack = [
                    r.title, r.location, r.reporterText, r.ngoText, r.type, r.statusRaw, r.dateText
                ].joined(separator: " ").lowercased()
                return haystack.contains(searchText)
            }
        }

        shownReports = items
        tableView.reloadData()
    }

    private func openDetails(report: ReportItem) {
        // later
    }
}

// MARK: - UITableView
extension ReportManagementViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shownReports.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: ReportCardCell.reuseId,
                                                 for: indexPath) as! ReportCardCell

        let r = shownReports[indexPath.row]
        cell.configure(
            title: r.title,
            location: r.location,     // donation = ""
            reporter: r.reporterText,
            ngo: r.ngoText,           // donation = ""
            date: r.dateText,
            status: displayStatusText(r.statusRaw)
        )

        cell.selectionStyle = .none
        cell.onViewDetailsTapped = { [weak self] in
            self?.openDetails(report: r)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openDetails(report: shownReports[indexPath.row])
    }
}

// MARK: - UISearchBarDelegate
extension ReportManagementViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.setShowsCancelButton(false, animated: false)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.setShowsCancelButton(false, animated: false)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFiltersAndReload()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
