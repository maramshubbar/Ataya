//
//  ReportManagementViewController.swift
//  Ataya
//
//  Created by Maram on 01/12/2025.
//

import UIKit

class ReportManagementViewController:
    UIViewController {
    
    
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
    }
}
