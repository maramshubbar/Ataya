//
//  DonationHistoryViewController.swift
//  DonationHistory
//
//  Created by Ruqaya Habib on 31/12/2025.
//

import UIKit

class DonationHistoryViewController: UIViewController {


    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    private var selectedItem: DonationHistoryItem?
    
    private var allItems: [DonationHistoryItem] = []
       private var filteredItems: [DonationHistoryItem] = []

       override func viewDidLoad() {
           super.viewDidLoad()

           title = "Donation History"
           navigationItem.largeTitleDisplayMode = .never
           view.backgroundColor = .systemBackground

           setupTable()
           setupSearch()
           setupFilter()

           loadDummy()
           applyFiltersAndReload()
       }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 215
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .systemBackground
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 20, right: 0)
    }

    private func setupSearch() {
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.autocapitalizationType = .none
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .systemGray6
        searchBar.searchTextField.layer.cornerRadius = 10
        searchBar.searchTextField.clipsToBounds = true
    }

    private func setupFilter() {
        filterSegment.selectedSegmentIndex = 0
        filterSegment.addTarget(self, action: #selector(filterChanged), for: .valueChanged)

        filterSegment.backgroundColor = .systemGray6
        filterSegment.selectedSegmentTintColor = .white

        filterSegment.setDividerImage(
            UIImage(),
            forLeftSegmentState: .normal,
            rightSegmentState: .normal,
            barMetrics: .default
        )

        let normalText: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.black
        ]

        let selectedText: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: UIColor.black
        ]

        filterSegment.setTitleTextAttributes(normalText, for: .normal)
        filterSegment.setTitleTextAttributes(normalText, for: .highlighted)
        filterSegment.setTitleTextAttributes(selectedText, for: .selected)
        filterSegment.setTitleTextAttributes(selectedText, for: [.selected, .highlighted])
    }

    // MARK: - Dummy Data

    private func loadDummy() {
        allItems = [

            DonationHistoryItem(
                title: "Chicken Box",
                ngoName: "HopPal",
                location: "Manama, Bahrain",
                dateText: "Aug 22, 2025",
                status: .completed,

                donationId: "DON-101",
                quantity: "2 boxes",
                category: "Prepared Food",
                expiryDate: "Aug 25, 2025",
                packaging: "Sealed",
                allergenInfo: "None",

                collectorName: "Ali Ahmed",
                assignedDate: "Aug 22, 2025",
                pickupStatus: "Picked up",
                phone: "+973 3333 3333",
                email: "ali@hopal.org",
                collectorNotes: "Handle with care",

                reviewDate: "Aug 23, 2025",
                decision: "Approved",
                remarks: "All good",

                imageName: nil
            ),

            DonationHistoryItem(
                title: "Canned beans",
                ngoName: "PureRelief",
                location: "Ottawa, Canada",
                dateText: "Jun 03, 2025",
                status: .completed,

                donationId: "DON-102",
                quantity: "12 packs (400g)",
                category: "Canned Goods",
                expiryDate: "11/2028",
                packaging: "Sealed & Intact",
                allergenInfo: "Soy",

                collectorName: "Mariam Hassan",
                assignedDate: "Jun 03, 2025",
                pickupStatus: "Picked up",
                phone: "+973 3444 4444",
                email: "mariam@purerelief.org",
                collectorNotes: "Box is heavy",

                reviewDate: "Jun 04, 2025",
                decision: "Approved",
                remarks: "OK",

                imageName: nil
            ),

            DonationHistoryItem(
                title: "Frozen fruits",
                ngoName: "AidBridge",
                location: "Berlin, Germany",
                dateText: "Feb 12, 2025",
                status: .rejected,

                donationId: "DON-103",
                quantity: "5 bags",
                category: "Frozen",
                expiryDate: "Mar 01, 2025",
                packaging: "Frozen bags",
                allergenInfo: "None",

                collectorName: "Sara Ali",
                assignedDate: "Feb 12, 2025",
                pickupStatus: "Cancelled",
                phone: "+973 3555 5555",
                email: "sara@aidbridge.org",
                collectorNotes: "Not suitable",

                reviewDate: "Feb 12, 2025",
                decision: "Rejected",
                remarks: "Temperature issue",

                imageName: nil
            )
        ]
    }

    // MARK: - Filtering

    @objc private func filterChanged() {
        applyFiltersAndReload()
    }

    private func applyFiltersAndReload() {
        let q = (searchBar.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let selected = filterSegment.selectedSegmentIndex

        filteredItems = allItems.filter { item in
            let matchStatus: Bool
            switch selected {
            case 1: matchStatus = (item.status == .completed)
            case 2: matchStatus = (item.status == .rejected)
            default: matchStatus = true
            }

            let matchSearch: Bool
            if q.isEmpty { matchSearch = true }
            else {
                matchSearch =
                    item.title.lowercased().contains(q) ||
                    item.ngoName.lowercased().contains(q) ||
                    item.location.lowercased().contains(q)
            }

            return matchStatus && matchSearch
        }

        tableView.reloadData()
    }

    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDonationDetails",
           let vc = segue.destination as? DonationDetailsRViewControllerViewController {
            vc.item = selectedItem
        }
    }
}

    // MARK: - UITableView
    extension DonationHistoryViewController: UITableViewDataSource, UITableViewDelegate {

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            filteredItems.count
        }

        func tableView(_ tableView: UITableView,
            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = filteredItems[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "DonationCell",
            for: indexPath
        )
                as? DonationCell else {
            
                    return UITableViewCell()
        }

        cell.configure(with: item)

        cell.onTapDetails = { [weak self] in
            self?.selectedItem = item
            self?.performSegue(withIdentifier: "showDonationDetails", sender: nil)
        }

        return cell
    }
}

        // MARK: - UISearchBar
        extension DonationHistoryViewController: UISearchBarDelegate {

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            applyFiltersAndReload()
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }

  }


