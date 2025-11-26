//
//  DonateViewController.swift
//  Ataya
//
//  Created by Maram on 26/11/2025.
//

import UIKit

class DonateViewController: UIViewController {

    @IBOutlet weak var cardView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
            
            // Rounded corners
            cardView.layer.cornerRadius = 20
            
            // Shadow
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOpacity = 0.15
            cardView.layer.shadowOffset = CGSize(width: 0, height: 6)
            cardView.layer.shadowRadius = 12
            
            // Required to show shadow
            cardView.layer.masksToBounds = false
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
