//
//  AuditLogViewController.swift
//  Ataya
//
//  Created by Maram on 02/12/2025.
//

import UIKit

struct AuditLogItem {
    let title: String
    let user: String
    let action: String
    let location: String
    let date: String
    let status: String
}


class AuditLogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var filterSegment: UISegmentedControl!
    
    // REAL DATA (temporary but real records)
    let auditItems: [AuditLogItem] = [
        AuditLogItem(
            title: "Donation Approved",
            user: "Zahraa Ali",
            action: "Approved donation Baby Formula (DON-100) for collection by WarmMeal (N-07).",
            location: "Manama, Bahrain",
            date: "Nov 6, 2025 – 10:42 PM",
            status: "Action Completed"
        ),
        AuditLogItem(
            title: "NGO Suspended",
            user: "Admin Sarah Ibrahim",
            action: "Suspended NGO United Care Foundation (N-34) due to repeated violations.",
            location: "Johannesburg, South Africa",
            date: "Nov 7, 2025 – 9:15 AM",
            status: "Account Suspended"
        ),
        AuditLogItem(
            title: "Campaign Created",
            user: "Walaa Ahmed",
            action: "Created a new campaign 'Winter Warmth Drive' with a goal of $50,000.",
            location: "Kuwait City, Kuwait",
            date: "Nov 5, 2025 – 2:30 PM",
            status: "Campaign Active"
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = .white
            searchField.layer.cornerRadius = 10
            searchField.clipsToBounds = true
        }
        
        // Remove separator lines
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 0
        
        // Auto height for XIB cell
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160
        
        // Register XIB
        let nib = UINib(nibName: "AuditLogTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AuditLogTableViewCell")
        
        // Set delegates
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Table View Data
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return auditItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AuditLogTableViewCell",
            for: indexPath
        ) as! AuditLogTableViewCell
        
        let item = auditItems[indexPath.row]
        
        // TOP TITLE
        cell.titleLabel.text = item.title
        
        // VALUE LABELS (RIGHT SIDE)
        cell.userValueLabel.text = item.user
        cell.actionValueLabel.text = item.action
        cell.locationValueLabel.text = item.location
        cell.dateValueLabel.text = item.date
        cell.statusValueLabel.text = item.status
        
        // FIXED TITLES (LEFT SIDE) — set once in XIB for clean design
        
        return cell
    }
}
