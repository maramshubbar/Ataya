//
//  AdminDonationDetailsViewController.swift
//  Ataya
//
//  Created by Maram on 20/12/2025.
//


 
import UIKit
 
class AdminDonationDetailsViewController: UIViewController {
    
    @IBOutlet weak var donationCardView: UIView!
    @IBOutlet weak var donorCardView: UIView!
    @IBOutlet weak var ngoCardView: UIView!
    @IBOutlet weak var adminReviewCardView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        donationCardView.applyCardStyle()
        donorCardView.applyCardStyle()
        ngoCardView.applyCardStyle()
        adminReviewCardView.applyCardStyle()
    }
}
