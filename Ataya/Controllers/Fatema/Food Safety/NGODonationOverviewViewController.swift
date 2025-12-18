//
//  NGODonationOverviewViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 01/12/2025.
//

import UIKit

class NGODonationOverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var filterSegment: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var donations: [Donation] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Search bar style (same as your other VC)
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = .white
            searchField.layer.cornerRadius = 10
            searchField.clipsToBounds = true
        }

        // Table
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200

        tableView.dataSource = self
        tableView.delegate = self

        // Register XIB
        tableView.register(UINib(nibName: "DonationCell", bundle: nil),
                           forCellReuseIdentifier: DonationCell.reuseId)

        // TEMP test data (like ReportManagement)
        donations = [
            Donation(title: "Baby Formula (DON-10)",
                     donor: "Ahmed Saleh (ID: D-26)",
                     location: "Manama, Bahrain",
                     dateText: "Nov 6 2025",
                     status: .pending,
                     imageName: "baby_formula"),

            Donation(title: "Canned Beans (DON-11)",
                     donor: "Sara Ali (ID: D-18)",
                     location: "Riffa, Bahrain",
                     dateText: "Nov 7 2025",
                     status: .accepted,
                     imageName: "canned_beans"),

            Donation(title: "Milk Pack (DON-12)",
                     donor: "Noor Hasan (ID: D-09)",
                     location: "Muharraq, Bahrain",
                     dateText: "Nov 8 2025",
                     status: .rejected,
                     imageName: "milk_pack")
        ]
    }

    private func openDetails(donation: Donation) {
        // TODO: push details VC
        // print(donation)
    }
}

extension NGODonationOverviewViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        donations.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: DonationCell.reuseId,
                                                 for: indexPath) as! DonationCell

        let d = donations[indexPath.row]
        cell.configure(with: d)
        cell.selectionStyle = .none

        // Optional: if you have "View Details" button in cell
        cell.onViewDetailsTapped = { [weak self] in
            self?.openDetails(donation: d)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openDetails(donation: donations[indexPath.row])
    }
}
