//
//  UserSelectionControllers.swift
//  Ataya
//
//  Created by Ruqaya Habib on 27/11/2025.
//

import Foundation
import UIKit

class UserSelectionViewController: UIViewController {

    @IBOutlet weak var donorButton: UIButton!
    @IBOutlet weak var ngoButton: UIButton!
    @IBOutlet weak var adminButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    enum UserRole {
        case donor, ngo, admin
    }

    var selectedRole: UserRole? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        styleButtons()
    }

    private func styleButtons() {
        let buttons = [donorButton, ngoButton, adminButton]

        for b in buttons {
            b?.layer.cornerRadius = 16
            b?.layer.borderWidth = 1
            b?.layer.borderColor = UIColor.black.cgColor
            b?.backgroundColor = .white
        }

        nextButton.layer.cornerRadius = 16
        nextButton.backgroundColor = UIColor(red: 0.97, green: 0.84, blue: 0.30, alpha: 1.0)
        updateSelectionUI()
    }

    private func updateSelectionUI() {
        let selectedYellow = UIColor(red: 0.99, green: 0.95, blue: 0.78, alpha: 1.0)
        let normalWhite = UIColor.white

        donorButton.backgroundColor = (selectedRole == .donor) ? selectedYellow : normalWhite
        ngoButton.backgroundColor   = (selectedRole == .ngo)   ? selectedYellow : normalWhite
        adminButton.backgroundColor = (selectedRole == .admin) ? selectedYellow : normalWhite
    }

    @IBAction func donorTapped(_ sender: UIButton) {
        selectedRole = .donor
        updateSelectionUI()
    }

    @IBAction func ngoTapped(_ sender: UIButton) {
        selectedRole = .ngo
        updateSelectionUI()
    }

    @IBAction func adminTapped(_ sender: UIButton) {
        selectedRole = .admin
        updateSelectionUI()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        guard let selectedRole = selectedRole else {
            let alert = UIAlertController(title: "Select User",
                                          message: "Please choose Donor, NGO, or Admin first.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        switch selectedRole {
        case .donor:
            performSegue(withIdentifier: "DonorSignupSegue", sender: self)
        case .ngo:
            performSegue(withIdentifier: "NGOSignupSegue", sender: self)
        case .admin:
            performSegue(withIdentifier: "AdminSignupSegue", sender: self)
        }
    }
}
