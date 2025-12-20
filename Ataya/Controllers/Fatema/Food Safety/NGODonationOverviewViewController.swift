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

    private var donations: [DonationItem] = []

        override func viewDidLoad() {
            super.viewDidLoad()

            // Search bar UI
            searchBar.backgroundImage = UIImage()
            searchBar.searchBarStyle = .minimal
            if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
                searchField.backgroundColor = .white
                searchField.layer.cornerRadius = 10
                searchField.clipsToBounds = true
            }

            // Table UI
            tableView.separatorStyle = .none
            tableView.backgroundColor = .clear
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 200

            tableView.dataSource = self
            tableView.delegate = self

            // ✅ IMPORTANT:
            // إذا اسم الـ XIB عندك مو "DonationOverviewCell" غيريه هنا لنفس اسم ملف الـ xib بالضبط
            tableView.register(
                UINib(nibName: "DonationOverviewCell", bundle: nil),
                forCellReuseIdentifier: DonationOverviewCell.reuseId
            )

            // TEMP test data
            donations = [
                DonationItem(
                    title: "Baby Formula (DON-10)",
                    donorText: "Ahmed Saleh (ID: D-26)",
                    locationText: "Manama, Bahrain",
                    dateText: "Nov 6 2025",
                    status: .pending,
                    imageName: "baby_formula"
                ),
                DonationItem(
                    title: "Canned Beans (DON-11)",
                    donorText: "Sara Ali (ID: D-18)",
                    locationText: "Riffa, Bahrain",
                    dateText: "Nov 7 2025",
                    status: .approved,
                    imageName: "canned-beans"
                ),
                DonationItem(
                    title: "Eggs (DON-12)",
                    donorText: "Noor Hasan (ID: D-09)",
                    locationText: "Muharraq, Bahrain",
                    dateText: "Nov 8 2025",
                    status: .rejected,
                    imageName: "eggs"
                )
            ]

            tableView.reloadData()
        }

        private func openDetails(donation: DonationItem) {
            print("Open details for:", donation.title)
            // TODO: push details VC
        }
    }

extension NGODonationOverviewViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        donations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: DonationOverviewCell.reuseId,
            for: indexPath
        ) as! DonationOverviewCell
        
        let d = donations[indexPath.row]
        cell.configure(item: d)
        
        cell.onViewDetailsTapped = { [weak self] in
            self?.openDetails(donation: d)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openDetails(donation: donations[indexPath.row])
    }
}
