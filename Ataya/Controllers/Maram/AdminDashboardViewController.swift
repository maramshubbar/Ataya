//
//  AdminDashboardViewController.swift
//  Ataya
//
//  Created by Maram on 24/11/2025.
//

import UIKit

class AdminDashboardViewController: UIViewController {
    var customTabBar: CustomTabBarView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
       // customTabBar.setSelected(tab: .home)

        

        // Do any additional setup after loading the view.
        donationOverviewButton.layer.borderColor = UIColor(red: 0xFE/255, green: 0xC4/255, blue: 0x00/255, alpha: 1).cgColor
        donationOverviewButton.layer.borderWidth = 0.5
            donationOverviewButton.layer.cornerRadius = 8
            donationOverviewButton.layer.masksToBounds = true
        
        auditLogButton.layer.borderColor = UIColor(red: 0xFE/255, green: 0xC4/255, blue: 0x00/255, alpha: 1).cgColor
        auditLogButton.layer.borderWidth = 0.5
        auditLogButton.layer.cornerRadius = 8
        auditLogButton.layer.masksToBounds = true
        
        setupTabBar()
        self.view.bringSubviewToFront(customTabBar)
        customTabBar.isHidden = false
        customTabBar.alpha = 1

        
    }
    private func setupTabBar() {
        // Load tab bar from the nib
        let tabBar = CustomTabBarView.loadFromNib()
        self.customTabBar = tabBar
        
        
        
        // Add it to the main view
        view.addSubview(tabBar)
        
        // Enable AutoLayout
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Pin to bottom
        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 110)
        ])
    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBOutlet weak var donationOverviewButton: UIButton!
    
    @IBOutlet weak var auditLogButton: UIButton!
}

