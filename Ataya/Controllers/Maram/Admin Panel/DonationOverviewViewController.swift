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

    private var selectedDocId: String?

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = .white
            searchField.layer.cornerRadius = 10
            searchField.clipsToBounds = true
        }

        searchBar.delegate = self
        searchBar.showsCancelButton = false

        tableView.dataSource = self
        tableView.delegate = self

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

                    let donationId = data["id"] as? String ?? doc.documentID
                    let itemName   = data["itemName"] as? String ?? ""
                    let donorId    = data["donorId"] as? String ?? ""
                    let statusStr  = data["status"] as? String ?? "pending"

                    let ts = data["createdAt"] as? Timestamp
                    let createdAt = ts?.dateValue() ?? Date.distantPast
                    let dateText = Self.dateFormatter.string(from: createdAt)

                    let photoURLs = data["photoURLs"] as? [String] ?? []
                    let imageUrl = photoURLs.first ?? ""

                    let headerTitle: String = {
                        let clean = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if clean.isEmpty { return donationId }
                        return "\(clean) (\(donationId))"
                    }()

                    let donorText: String = donorId.isEmpty ? "Donor (ID: —)" : "Donor (ID: \(donorId))"

                    return DonationItem(
                        docId: doc.documentID,
                        title: headerTitle,
                        donorText: donorText,
                        ngoText: "NGO (ID: —)",
                        locationText: "",
                        dateText: dateText,
                        imageUrl: imageUrl,
                        status: self.mapStatus(statusStr)
                    )
                }

                DispatchQueue.main.async {
                    self.applySearchAndReload()
                }
            }
    }

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

        if searchText.isEmpty {
            shownItems = allItems
            tableView.reloadData()
            return
        }

        shownItems = allItems.filter { item in
            let haystack = [
                item.title,
                item.donorText,
                item.dateText,
                item.status.rawValue
            ].joined(separator: " ").lowercased()

            return haystack.contains(searchText)
        }

        tableView.reloadData()
    }


    private func openDetails(item: DonationItem) {
        selectedDocId = item.docId
        print("✅ openDetails docId:", item.docId)
        performSegue(withIdentifier: "sgDonationDetails", sender: self)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "sgDonationDetails" else { return }

        let dest = segue.destination

        let detailsVC =
            (dest as? UINavigationController)?.topViewController as? AdminDonationDetailsViewController
            ?? dest as? AdminDonationDetailsViewController

        detailsVC?.donationDocId = selectedDocId
        print("✅ Passing docId to details:", selectedDocId ?? "nil")

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
