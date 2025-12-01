//
//  ReportManagementViewController ReportManagementViewController ReportManagementViewController ReportManagementViewController.swift
//  Ataya
//
//  Created by Maram on 29/11/2025.
//

import UIKit

class ReportManagementViewController: UIViewController {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeSearchBar()
        
        filterSegment.addTarget(self, action: #selector(filterChanged(_:)), for: .valueChanged)
        
        
        // Register the ReportCell XIB
           // let nib = UINib(nibName: "ReportCell", bundle: nil)
            //tableView.register(nib, forCellReuseIdentifier: "ReportCell")
       

            // Set data source + delegate

        //tableView.rowHeight = UITableView.automaticDimension
          //  tableView.estimatedRowHeight = 180
        
    
    }
    func customizeSearchBar() {
        
        
    searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = UIColor.white

        searchBar.barTintColor = UIColor(hex: "#F4F4F5")
           searchBar.searchTextField.backgroundColor = UIColor(hex: "#F4F4F5")
        // REMOVE ALL BORDERS
           searchBar.searchTextField.layer.borderWidth = 0
           searchBar.searchTextField.layer.borderColor = UIColor.clear.cgColor
        
        // make background white
       // searchBar.searchTextField.backgroundColor = UIColor.white
        
        // round corners like Figma
        searchBar.searchTextField.layer.cornerRadius = 8
        searchBar.searchTextField.layer.masksToBounds = true
        
        // border to match Figma
        searchBar.searchTextField.layer.borderWidth = 1
        searchBar.searchTextField.layer.borderColor = UIColor.systemGray4.cgColor
        
        // placeholder text color
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [.foregroundColor: UIColor.gray]
        )
    
    }
    
    @objc func filterChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("Filter: All")
        case 1:
            print("Filter: Donations")
        case 2:
            print("Filter: Accounts")
        case 3:
            print("Filter: Resolved")
        default:
            break
        }
    }
    
    @IBOutlet weak var tableView: UITableView!


    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var filterSegment: UISegmentedControl!
}
extension UIColor {
    convenience init(hex: String) {
        let hexString = hex.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }
    
    
}

