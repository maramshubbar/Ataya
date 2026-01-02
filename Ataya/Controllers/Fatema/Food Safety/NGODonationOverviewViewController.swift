//
//  NGODonationOverviewViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 01/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class NGODonationOverviewViewController: UIViewController {

    @IBOutlet weak var filterSegment: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    private var listener: ListenerRegistration?
    private var allDonations: [DonationItem] = []
    private var shownDonations: [DonationItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Search UI
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = .white
            searchField.layer.cornerRadius = 10
            searchField.clipsToBounds = true
        }

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200

        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self

        filterSegment.addTarget(self, action: #selector(filterChanged), for: .valueChanged)

        tableView.register(
            UINib(nibName: "DonationOverviewCell", bundle: nil),
            forCellReuseIdentifier: DonationOverviewCell.reuseId
        )

        startListening()
    }

    deinit { listener?.remove() }

    private func startListening() {
        guard let ngoId = Auth.auth().currentUser?.uid else { return }

        listener = DonationService.shared.listenNGODonations(ngoId: ngoId) { [weak self] items in
            guard let self else { return }
            self.allDonations = items
            self.applyFilterAndSearch()
        }
    }

    @objc private func filterChanged() {
        applyFilterAndSearch()
    }

    private func applyFilterAndSearch() {
        let seg = filterSegment.selectedSegmentIndex
        let q = (searchBar.text ?? "").lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        var filtered = allDonations

        // 0 All, 1 Pending, 2 Approved, 3 Rejected (عدلي حسب ترتيب segments عندج)
        if seg == 1 { filtered = filtered.filter { $0.status == .pending } }
        if seg == 2 { filtered = filtered.filter { $0.status == .approved } }
        if seg == 3 { filtered = filtered.filter { $0.status == .rejected } }

        if !q.isEmpty {
            filtered = filtered.filter {
                $0.titleText.lowercased().contains(q)
                || $0.donorName.lowercased().contains(q)
                || $0.donorCity.lowercased().contains(q)
            }
        }

        shownDonations = filtered
        tableView.reloadData()
    }

    private func openDetails(donationId: String) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "NGODonationDetailsViewController") as! NGODonationDetailsViewController
        vc.donationId = donationId
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension NGODonationOverviewViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shownDonations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: DonationOverviewCell.reuseId,
            for: indexPath
        ) as! DonationOverviewCell

        let d = shownDonations[indexPath.row]
        cell.configure(item: d)

        cell.onViewDetailsTapped = { [weak self] in
            self?.openDetails(donationId: d.id)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openDetails(donationId: shownDonations[indexPath.row].id)
    }
}

extension NGODonationOverviewViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilterAndSearch()
    }
}
