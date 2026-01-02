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
    @IBOutlet weak var proceedToInspectionTapped: UIButton!

    var donationId: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        donationCardView.applyCardStyle()
        donorCardView.applyCardStyle()
        collectorCardView.applyCardStyle()
        loadDonation()
    }
    
    @IBAction func proceedToInspectionTapped(_ sender: UIButton) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let vc = storyboard.instantiateViewController(
            withIdentifier: "InspectDonationViewController"
        ) as? NGODonationDetailsViewController {


            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
