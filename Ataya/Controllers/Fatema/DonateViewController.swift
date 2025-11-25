//
//  DonateViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/11/2025.
//

import Foundation
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
