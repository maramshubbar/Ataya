//
//  ReportManagementViewController.swift
//  Ataya
//
//  Created by Maram on 01/12/2025.
//

import UIKit

class ReportManagementViewController:
    UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var filterSegment: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        
        
        tableView.delegate = self
        tableView.dataSource = self

        // Register XIB
                let nib = UINib(nibName: "ReportCellTableViewCell", bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: "ReportCellTableViewCell")

                tableView.rowHeight = UITableView.automaticDimension
                tableView.estimatedRowHeight = 200
                tableView.separatorStyle = .none
        
    }
    

    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 4
        }

    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ReportCellTableViewCell",
            for: indexPath
        ) as! ReportCellTableViewCell

        // TEMP DATA
        cell.titleLabel.text = "Damaged Food Donation"
        cell.locationLabel.text = "Cairo, Egypt"
        cell.personLabel.text = "Ahmed (ID: D-55)"
        cell.ngoLabel.text = "KindWave (ID: N-06)"
        cell.dateLabel.text = "Nov 5 2025"
        cell.statusLabel.text = "Pending"
        cell.statusBadgeView.backgroundColor = .systemYellow

        return cell
    }
    
    

}
