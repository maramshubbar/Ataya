//
//  NGODonationOverviewViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 01/12/2025.
//

import UIKit

final class NGODonationOverviewViewController: UIViewController {
    
    @IBOutlet weak var filterSegment: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var listener: AnyObject?
    private var allDonations: [DonationItem] = []
    private var shownDonations: [DonationItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
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
    
    deinit {
        (listener as? NSObject)?.perform(Selector(("remove")))
    }
    
    private func startListening() {
        guard let ngoId = Auth.auth().currentUser?.uid else { return }
        
        let reg = DonationService.shared.listenNGODonations(ngoId: ngoId) { [weak self] items in
            guard let self else { return }
            self.allDonations = items
            self.applyFilterAndSearch()
        }
        self.listener = reg
    }
    @objc private func filterChanged() {
        applyFilterAndSearch()
    }
    
    private func applyFilterAndSearch() {
        let seg = filterSegment.selectedSegmentIndex
        let query = (searchBar.text ?? "").lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        var filtered = allDonations
        
        // Segments: 0 All, 1 Pending, 2 Rejected, 3 Approved
        if seg == 1 { filtered = filtered.filter { $0.status == .pending } }
        if seg == 2 { filtered = filtered.filter { $0.status == .rejected } }
        if seg == 3 { filtered = filtered.filter { $0.status == .approved } }
        
        if !query.isEmpty {
            filtered = filtered.filter {
                $0.titleText.lowercased().contains(query)
                || $0.donorName.lowercased().contains(query)
                || $0.locationText.lowercased().contains(query)
            }
        }
        
        shownDonations = filtered
        tableView.reloadData()
    }
    
    private func openDetails(donation: DonationItem) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "NGODonationDetailsViewController") as! NGODonationDetailsViewController
        vc.donationId = donation.id
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
        cell.configure(item: d) // ✅ لازم تحدث cell configure لتستخدم imageUrl
        cell.onViewDetailsTapped = { [weak self] in self?.openDetails(donation: d) }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openDetails(donation: shownDonations[indexPath.row])
    }
}
extension NGODonationOverviewViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilterAndSearch()
    }
}
