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

           // ✅ صيغة مضمونة لإخفاء الديفايدر
           filterSegment.setDividerImage(UIImage(),
                                         forLeftSegmentState: .normal,
                                         rightSegmentState: .normal,
                                         barMetrics: .default)

           // Text attributes — all BLACK
           let normalText: [NSAttributedString.Key: Any] = [
               .font: UIFont.systemFont(ofSize: 13, weight: .regular),
               .foregroundColor: UIColor.black
           ]

           let selectedText: [NSAttributedString.Key: Any] = [
               .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
               .foregroundColor: UIColor.black
           ]

           filterSegment.setTitleTextAttributes(normalText, for: .normal)
           filterSegment.setTitleTextAttributes(normalText, for: .highlighted) // ✅ يمنع الأبيض وقت الضغط
           filterSegment.setTitleTextAttributes(selectedText, for: .selected)
           filterSegment.setTitleTextAttributes(selectedText, for: [.selected, .highlighted])
       }

       private func loadDummy() {
           allItems = [
               DonationHistoryItem(title: "Chicken Box", ngoName: "HopPal", location: "Manama, Bahrain", dateText: "Aug 22, 2025", status: .completed),
               DonationHistoryItem(title: "Canned beans", ngoName: "PureRelief", location: "Ottawa, Canada", dateText: "Jun 03, 2025", status: .completed),
               DonationHistoryItem(title: "Frozen fruits", ngoName: "AidBridge", location: "Berlin, Germany", dateText: "Feb 12, 2025", status: .rejected)
           ]
       }

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

       // (موجودة الحين مثل ما عندك)
       private func showDetails(for item: DonationHistoryItem) {
           let msg = """
           \(item.title)
           NGO: \(item.ngoName)
           \(item.location)
           \(item.dateText)
           Status: \(item.status.rawValue)
           """
           let alert = UIAlertController(title: "Donation Details", message: msg, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
   }

   // MARK: - UITableView
   extension DonationHistoryViewController: UITableViewDataSource, UITableViewDelegate {

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           filteredItems.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

           let item = filteredItems[indexPath.row]

           guard let cell = tableView.dequeueReusableCell(withIdentifier: "DonationCell", for: indexPath) as? DonationCell else {
               return UITableViewCell()
           }

           cell.configure(with: item)

           cell.onTapDetails = { [weak self] in
               self?.openDetails(item)
           }


           return cell
       }

       func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 0.01 }
       func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { UIView() }
   }

   // MARK: - UISearchBar
   extension DonationHistoryViewController: UISearchBarDelegate {

       func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           applyFiltersAndReload()
       }

       func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           searchBar.resignFirstResponder()
       }
       
       private func openDetails(_ item: DonationHistoryItem) {
           let sb = UIStoryboard(name: "Main", bundle: nil)
           let vc = sb.instantiateViewController(withIdentifier: "DonationDetailsViewController")
           navigationController?.pushViewController(vc, animated: true)
       }

  }


