//
//  AdminDashboardViewController.swift
//  Ataya
//
//  Created by Maram on 24/11/2025.
//

import UIKit

class AdminDashboardViewController: UIViewController {
    
    
    var tabBarView: CustomTabBarView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()

        
        
        // Do any additional setup after loading the view.
        donationOverviewButton.layer.borderColor = UIColor(red: 0xFE/255, green: 0xC4/255, blue: 0x00/255, alpha: 1).cgColor
        donationOverviewButton.layer.borderWidth = 0.5
        donationOverviewButton.layer.cornerRadius = 8
        donationOverviewButton.layer.masksToBounds = true
        
        auditLogButton.layer.borderColor = UIColor(red: 0xFE/255, green: 0xC4/255, blue: 0x00/255, alpha: 1).cgColor
        auditLogButton.layer.borderWidth = 0.5
        auditLogButton.layer.cornerRadius = 8
        auditLogButton.layer.masksToBounds = true
        
    }
   
    func setupTabBar() {
        print("TAB BAR LOADED")

        // Load the XIB
        let tabBar = CustomTabBarView.loadFromNib()
        self.tabBarView = tabBar

        // Add it to bottom
        view.addSubview(tabBar)

        tabBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 110)
        ])
    }


    
    @IBOutlet weak var donationOverviewButton: UIButton!
    
    @IBOutlet weak var auditLogButton: UIButton!
}

