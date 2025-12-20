//
//  AddFoodDonationViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 27/11/2025.
//

import UIKit

class AddFoodDonationViewController: UIViewController{
    var draft = DraftDonation()
    
    @IBAction func nextTapped(_ sender: UIButton) {
            // save Add Food fields into draft here...

            performSegue(withIdentifier: "toUploadPhotos", sender: nil)
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toUploadPhotos",
               let vc = segue.destination as? UploadPhotosViewController {
                vc.draft = draft
            }
        }

    @IBOutlet weak var uploadPhotosCard: UIView!
    @IBOutlet weak var enterDetailsCard: UIView!
    @IBOutlet weak var safetySubmitCard: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupCards()
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
}
