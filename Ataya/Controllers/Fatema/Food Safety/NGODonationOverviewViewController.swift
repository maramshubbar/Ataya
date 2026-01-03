//
//  NGODonationOverviewViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 01/12/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

final class NGODonationOverviewViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private var allItems: [DonationItem] = []
    private var shownItems: [DonationItem] = []

    private enum DetailsVCId {
        static let pending  = "PendingDonationDetailsVC"
        static let approved = "ApprovedDonationDetailsVC"
        static let rejected = "RejectedDonationDetailsVC"
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Donation Overview"

        // SearchBar style
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = .white
            searchField.layer.cornerRadius = 10
            searchField.clipsToBounds = true
        }
        searchBar.delegate = self

        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false

        tableView.register(
            UINib(nibName: "DonationOverviewCell", bundle: nil),
            forCellReuseIdentifier: DonationOverviewCell.reuseId
        )

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
                    let statusStr  = data["status"] as? String ?? "pending"

                    let donorName  = data["donorName"] as? String ?? "Donor"
                    let donorId    = data["donorId"] as? String ?? "—"
                    let donorText  = "\(donorName) (ID: \(donorId))"
                        .replacingOccurrences(of: "— (ID: —)", with: "—")

                    let city    = data["donorCity"] as? String ?? "—"
                    let country = data["donorCountry"] as? String ?? "—"
                    let locationText = "\(city), \(country)".replacingOccurrences(of: "—, —", with: "—")

                    let ts = data["createdAt"] as? Timestamp
                    let createdAt = ts?.dateValue() ?? Date.distantPast
                    let dateText = Self.dateFormatter.string(from: createdAt)

                    let photoURLs = data["photoURLs"] as? [String] ?? []
                    let imageUrl = photoURLs.first ?? ""

                    let clean = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
                    let title = clean.isEmpty ? donationId : "\(clean) (\(donationId))"

                    return DonationItem(
                        docId: doc.documentID,
                        title: title,
                        donorText: donorText,
                        ngoText: "NGO (ID: —)",
                        locationText: locationText,
                        dateText: dateText,
                        imageUrl: imageUrl,
                        status: self.mapStatus(statusStr)
                    )
                }

                DispatchQueue.main.async { self.applySearchAndReload() }
            }
    }

    private func mapStatus(_ s: String) -> DonationItem.Status {
        let v = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        switch v {
        case "approved", "successful", "completed", "collected", "accept":
            return .approved
        case "rejected", "reject":
            return .rejected
        default:
            return .pending
        }
    }

    private func applySearchAndReload() {
        let q = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if q.isEmpty {
            shownItems = allItems
        } else {
            shownItems = allItems.filter {
                [$0.title, $0.donorText, $0.locationText, $0.dateText, $0.status.rawValue]
                    .joined(separator: " ")
                    .lowercased()
                    .contains(q)
            }
        }

        tableView.reloadData()
    }

    private func openDetails(item: DonationItem) {

        let vcId: String
        switch item.status {
        case .pending:
            vcId = DetailsVCId.pending
        case .approved:
            vcId = DetailsVCId.approved
        case .rejected:
            vcId = DetailsVCId.rejected
        }

        print("➡️ openDetails vcId:", vcId, "docId:", item.docId, "status:", item.status.rawValue)

        let vc = storyboard!.instantiateViewController(withIdentifier: vcId) as! NGODonationDetailsViewController
        vc.donationId = item.docId
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension NGODonationOverviewViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shownItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: DonationOverviewCell.reuseId,
            for: indexPath
        ) as! DonationOverviewCell

        let item = shownItems[indexPath.row]
        cell.configure(item: item)

        cell.onViewDetailsTapped = { [weak self] in
            self?.openDetails(item: item)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
}

extension NGODonationOverviewViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { applySearchAndReload() }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { searchBar.resignFirstResponder() }
}
