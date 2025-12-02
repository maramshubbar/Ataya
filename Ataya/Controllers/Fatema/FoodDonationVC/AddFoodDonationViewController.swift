//
//  AddFoodDonationViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 27/11/2025.
//

import UIKit

class AddFoodDonationViewController: UIViewController {
    @IBOutlet weak var uploadPhotosCard: UIView!
    @IBOutlet weak var enterDetailsCard: UIView!
    @IBOutlet weak var safetySubmitCard: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCards()
        // Do any additional setup after loading the view.
    }
    
    func setupCards() {

        // Card 1 — Active (yellow border)
        styleCard(uploadPhotosCard,
                  bgColor: UIColor(hex: "#FFFAE8"),
                  borderColor: UIColor(hex: "#FFD83F"))

        // Card 2 — Inactive (gray border)
        styleCard(enterDetailsCard,
                  bgColor: UIColor.white,
                  borderColor: UIColor(hex: "#DADADA"))

        // Card 3 — Inactive (gray border)
        styleCard(safetySubmitCard,
                  bgColor: UIColor.white,
                  borderColor: UIColor(hex: "#DADADA"))
    }

    func styleCard(_ view: UIView, bgColor: UIColor, borderColor: UIColor) {
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = borderColor.cgColor
        view.backgroundColor = bgColor
        view.layer.masksToBounds = true
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

