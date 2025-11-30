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
    
    var selectedUser: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let cards = [donorView, ngoView, adminView]
        for card in cards {
            card?.layer.cornerRadius = 16
            card?.layer.borderWidth = 1
            card?.layer.borderColor = UIColor.lightGray.cgColor
            card?.layer.masksToBounds = true
        }
        let donorTap = UITapGestureRecognizer(target: self, action: #selector(donorTapped))
        donorView.addGestureRecognizer(donorTap)

        let ngoTap = UITapGestureRecognizer(target: self, action: #selector(ngoTapped))
        ngoView.addGestureRecognizer(ngoTap)

        let adminTap = UITapGestureRecognizer(target: self, action: #selector(adminTapped))
        adminView.addGestureRecognizer(adminTap)

    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        guard let selectedUser = selectedUser else {

            let alert = UIAlertController(
                title: "Select a User",
                message: "Please choose Donor, NGO, or Admin",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        print("Selected user: \(selectedUser)")
    }
    
    
    func resetCardBorders() {
        let cards = [donorView, ngoView, adminView]
        for card in cards {
            card?.layer.borderColor = UIColor.lightGray.cgColor
            card?.backgroundColor = .white
        }
    }

    func highlight(card: UIView) {
        card.layer.borderColor = UIColor(red: 1.0, green: 0.984, blue: 0.906, alpha: 1.0).cgColor
        card.backgroundColor = UIColor(red: 1.0, green: 0.984, blue: 0.906, alpha: 1.0)
    }

    
    @objc func donorTapped() {
        selectedUser = "Donor"
        resetCardBorders()
        highlight(card: donorView)
    }
    
    @objc func ngoTapped() {
        selectedUser = "NGO"
        resetCardBorders()
        highlight(card: ngoView)
    }

    @objc func adminTapped() {
        selectedUser = "Admin"
        resetCardBorders()
        highlight(card: adminView)
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
