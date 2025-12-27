//
//  DonationOverviewViewController.swift
//  Ataya
//
//  Admin - Donation Overview
//

import UIKit
import FirebaseFirestore

final class DonationOverviewViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private var allItems: [DonationItem] = []
    private var shownItems: [DonationItem] = []

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
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = .white
            searchField.layer.cornerRadius = 10
            searchField.clipsToBounds = true
        }

        // Delegates
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self

        // Table styling
        tableView.register(UINib(nibName: "DonationOverviewCell", bundle: nil),
                           forCellReuseIdentifier: DonationOverviewCell.reuseId)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 190
        tableView.keyboardDismissMode = .onDrag
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListening()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
        listener = nil
    }

    deinit { listener?.remove() }

    // MARK: - Firestore Listener (وفق schema المتفق عليه)
    private func startListening() {
        listener?.remove()
        listener = nil

        listener = db.collection("donations")
            .order(by: "createdAt", descending: true)
            .limit(to: 200)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }

                if let err = err {
                    print("❌ donations error:", err.localizedDescription)
                    return
                }

                let docs = snap?.documents ?? []

                self.allItems = docs.compactMap { doc in
                    let data = doc.data()
                    let donationId = doc.documentID

                    // Required fields (حسب اللي اتفقنا عليه)
                    let title = data["title"] as? String ?? ""
                    let donorName = data["donorName"] as? String ?? ""
                    let donorId = data["donorId"] as? String ?? ""
                    let ngoName = data["ngoName"] as? String ?? ""
                    let ngoId = data["ngoId"] as? String ?? ""
                    let city = data["city"] as? String ?? ""
                    let country = data["country"] as? String ?? ""
                    let statusStr = (data["status"] as? String ?? "pending")
                    let imageName = data["imageName"] as? String ?? "aptamil"

                    // Timestamp
                    let ts = data["createdAt"] as? Timestamp
                    let createdAt = ts?.dateValue() ?? Date.distantPast
                    let dateText = Self.dateFormatter.string(from: createdAt)

                    // Title + ID
                    let headerTitle: String = {
                        let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        if clean.isEmpty { return donationId }
                        return "\(clean) (\(donationId))"
                    }()

                    let donorText: String = {
                        if !donorName.isEmpty && !donorId.isEmpty { return "\(donorName) (ID: \(donorId))" }
                        if !donorName.isEmpty { return "\(donorName) (ID: —)" }
                        if !donorId.isEmpty { return "Donor (ID: \(donorId))" }
                        return "Donor (ID: —)"
                    }()

                    let ngoText: String = {
                        if !ngoName.isEmpty && !ngoId.isEmpty { return "\(ngoName) (ID: \(ngoId))" }
                        if !ngoName.isEmpty { return "\(ngoName) (ID: —)" }
                        if !ngoId.isEmpty { return "NGO (ID: \(ngoId))" }
                        return "NGO (ID: —)"
                    }()

                    let locationText: String = {
                        if !city.isEmpty && !country.isEmpty { return "\(city), \(country)" }
                        if !country.isEmpty { return country }
                        if !city.isEmpty { return city }
                        return ""
                    }()

                    return DonationItem(
                        title: headerTitle,
                        donorText: donorText,
                        ngoText: ngoText,
                        locationText: locationText,
                        dateText: dateText,
                        imageName: imageName,
                        status: self.mapStatus(statusStr)
                    )
                }

                DispatchQueue.main.async {
                    self.applySearchAndReload()
                }
            }
    }

    // يرجع DonationItem.Status
    private func mapStatus(_ s: String) -> DonationItem.Status {
        switch s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "approved": return .approved
        case "rejected": return .rejected
        default: return .pending
        }
    }

    private func applySearchAndReload() {
        let searchText = (searchBar.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        var items = allItems

        if !searchText.isEmpty {
            items = items.filter { item in
                let haystack = [
                    item.title,
                    item.donorText,
                    item.ngoText,
                    item.locationText,
                    item.dateText,
                    item.status.rawValue
                ].joined(separator: " ").lowercased()

                return haystack.contains(searchText)
            }
        }

        shownItems = items
        tableView.reloadData()
    }

    private func openDetails(item: DonationItem) {
        // هنا بتفتحين صفحة التفاصيل بعدين
    }
}

// MARK: - TableView
extension DonationOverviewViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shownItems.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: DonationOverviewCell.reuseId,
                                                 for: indexPath) as! DonationOverviewCell

        let item = shownItems[indexPath.row]
        cell.configure(item: item)
        cell.selectionStyle = .none

        cell.onViewDetailsTapped = { [weak self] in
            self?.openDetails(item: item)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openDetails(item: shownItems[indexPath.row])
    }
}

// MARK: - Search
extension DonationOverviewViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applySearchAndReload()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
