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

        // Do any additional setup after loading the view.
    }
    func customizeSearchBar() {
        // make background white
        searchBar.searchTextField.backgroundColor = UIColor.white
        
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
