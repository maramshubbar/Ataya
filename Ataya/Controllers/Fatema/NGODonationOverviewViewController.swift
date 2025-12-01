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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the XIB for the table view
        let nib = UINib(nibName: "DonationCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "DonationCell")

        // Setup tableView
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - TABLE VIEW DATA SOURCE

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 // TEMP: number of test rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "DonationCell",
            for: indexPath
        ) as! DonationCell

        // TEMP TEST DATA
        cell.titleLabel.text = "Baby Formula (DON-10)"
        cell.donorLabel.text = "Ahmed Saleh (ID: D-26)"
        cell.locationLabel.text = "Manama, Bahrain"
        cell.dateLabel.text = "Nov 6 2025"

        cell.statusLabel.text = "Pending"
        cell.statusContainerView.backgroundColor = UIColor(
            red: 1.0,
            green: 0.98,
            blue: 0.85,
            alpha: 1.0
        )

        cell.productImageView.image = UIImage(named: "baby_formula")

        return cell
    }

    // OPTIONAL: row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200 // Adjust based on your design
    }
}
