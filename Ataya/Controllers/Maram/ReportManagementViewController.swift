//
//  ReportManagementViewController.swift
//  Ataya
//
//  Created by Maram on 01/12/2025.
//

import UIKit

class ReportManagementViewController:
    UIViewController, UITableViewDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var filterSegment: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    var reports: [Report] = []   // ✅ هذا اللي كان ناقص

    override func viewDidLoad() {
        super.viewDidLoad()
        // Remove top & bottom lines
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        
        // Make the search field perfectly white
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = .white     // PURE WHITE
            searchField.layer.cornerRadius = 10
            searchField.clipsToBounds = true
        }
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: "ReportCardCell", bundle: nil),
                           forCellReuseIdentifier: ReportCardCell.reuseId)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 170

        tableView.dataSource = self
        tableView.delegate = self
        // (مؤقت) بيانات تجريبية عشان يشتغل ويبين الكارد
                reports = [
                    Report(title: "Damaged Food Donation",
                           location: "Cairo, Egypt",
                           reporter: "Ahmed Saleh (ID: D-55)",
                           ngo: "KindWave (ID: N-06)",
                           dateText: "Nov 5 2025",
                           status: .pending),

                    Report(title: "Late Collection",
                           location: "Jakarta, Indonesia",
                           reporter: "PureRelief (ID: N-10)",
                           ngo: "",
                           dateText: "Jan 13 2025",
                           status: .resolved)
                ]
        tableView.dataSource = self
               tableView.delegate = self
    }
    
    func openDetails(report: Report) {
        // push to details VC
    }

}
extension ReportManagementViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: ReportCardCell.reuseId,
                                                 for: indexPath) as! ReportCardCell

        let r = reports[indexPath.row]
        cell.configure(
            title: r.title,
            location: r.location,
            reporter: r.reporter,
            ngo: r.ngo,
            date: r.dateText,
            status: r.status.rawValue
        )

        cell.selectionStyle = .none

        cell.onViewDetailsTapped = { [weak self] in
            self?.openDetails(report: r)
        }

        return cell
    }
}
