//
//  UserSelectionViewController.swift
//  Ataya
//
//  Created by Ruqaya Habib on 29/11/2025.
//

import UIKit

class UserSelectionViewController: UIViewController {


    @IBOutlet weak var donorView: UIView!
    
    @IBOutlet weak var ngoView: UIView!
    
    @IBOutlet weak var adminView: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    private let atayaYellow = UIColor(red: 0xF7/255.0, green: 0xD4/255.0, blue: 0x4C/255.0, alpha: 1.0)

    
    var selectedUser: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let cards = [donorView, ngoView, adminView]
        for card in cards {
            card?.layer.cornerRadius = 8
            card?.layer.borderWidth = 1
            card?.layer.borderColor = UIColor.lightGray.cgColor
            card?.layer.masksToBounds = true
        }
        
        nextButton.layer.cornerRadius = 8
        nextButton.layer.masksToBounds = true
        let donorTap = UITapGestureRecognizer(target: self, action: #selector(donorTapped))
        donorView.addGestureRecognizer(donorTap)

        let ngoTap = UITapGestureRecognizer(target: self, action: #selector(ngoTapped))
        ngoView.addGestureRecognizer(ngoTap)

        let adminTap = UITapGestureRecognizer(target: self, action: #selector(adminTapped))
        adminView.addGestureRecognizer(adminTap)
        
        
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
        updateNextButton()


    }
    
    
    private func updateNextButton() {
        let enabled = (selectedUser != nil)
        nextButton.isEnabled = enabled
        nextButton.alpha = enabled ? 1.0 : 0.5
    }

 
    @IBAction func nextPressed(_ sender: UIButton) {
        guard let selectedUser else { return }

        let segueID: String
        switch selectedUser {
        case "Donor": segueID = "donorSignupSegue"
        case "NGO":   segueID = "ngoSignupSegue"
        case "Admin": segueID = "adminLoginSegue"
        default: return
        }

        performSegue(withIdentifier: segueID, sender: self)
        }


    
    
    func resetCardBorders() {
        let cards = [donorView, ngoView, adminView]
        for card in cards {
            card?.layer.borderWidth = 1
            card?.layer.borderColor = UIColor.systemGray4.cgColor
            card?.backgroundColor = .white
        }
    }

    func highlight(card: UIView) {
        card.layer.borderWidth = 2
        card.layer.borderColor = atayaYellow.cgColor
        card.backgroundColor = atayaYellow.withAlphaComponent(0.25)
    }


    
    @objc func donorTapped() {
        selectedUser = "Donor"
        resetCardBorders()
        highlight(card: donorView)
        updateNextButton()
    }

    @objc func ngoTapped() {
        selectedUser = "NGO"
        resetCardBorders()
        highlight(card: ngoView)
        updateNextButton()
    }

    @objc func adminTapped() {
        selectedUser = "Admin"
        resetCardBorders()
        highlight(card: adminView)
        updateNextButton()
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
