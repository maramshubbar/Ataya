//
//  AddFoodDonationViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 27/11/2025.
//

import UIKit

class AddFoodDonationViewController: UIViewController{
    var draft = DraftDonation()
    
    //Still not checked this method
//    @IBAction func nextTapped(_ sender: UIButton) {
//            // save Add Food fields into draft here...
//
//            performSegue(withIdentifier: "toUploadPhotos", sender: nil)
//        }

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
        setupCards()
    }
    
    func setupCards() {

        // Card 1 — Active (yellow border)
        styleCard(uploadPhotosCard,
                  bgColor: UIColor.atayaHex("#FFFAE8"),
                  borderColor: UIColor.atayaHex("#FFD83F"))

        styleCard(enterDetailsCard,
                  bgColor: .white,
                  borderColor: UIColor.atayaHex("#DADADA"))

        styleCard(safetySubmitCard,
                  bgColor: .white,
                  borderColor: UIColor.atayaHex("#DADADA"))

    }

    func styleCard(_ view: UIView, bgColor: UIColor, borderColor: UIColor) {
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = borderColor.cgColor
        view.backgroundColor = bgColor
        view.layer.masksToBounds = true
    }
}
