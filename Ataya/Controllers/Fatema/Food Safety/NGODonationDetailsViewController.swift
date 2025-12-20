//
//  NGODonationDetailsViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 02/12/2025.
//

import UIKit

class NGODonationDetailsViewController: UIViewController {
    @IBOutlet weak var donationCardView: UIView!
    @IBOutlet weak var donorCardView: UIView!
    @IBOutlet weak var collectorCardView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        donationCardView.applyCardStyle()
        donorCardView.applyCardStyle()
        collectorCardView.applyCardStyle()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
