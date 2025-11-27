//
//  AdminDashboardViewController.swift
//  Ataya
//
//  Created by Maram on 24/11/2025.
//

import UIKit

class AdminDashboardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        donationOverviewButton.layer.borderColor = UIColor(red: 0xFE/255, green: 0xC4/255, blue: 0x00/255, alpha: 1).cgColor
        donationOverviewButton.layer.borderWidth = 0.5
            donationOverviewButton.layer.cornerRadius = 8
            donationOverviewButton.layer.masksToBounds = true
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
    
}
