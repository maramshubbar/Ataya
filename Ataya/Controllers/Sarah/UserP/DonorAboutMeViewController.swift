//
//  DonorAboutMeViewController.swift
//  Ataya
//
//  Created by BP-19-130-11 on 15/12/2025.
//

import UIKit

class DonorAboutMeViewController: UIViewController {

    @IBOutlet weak var fullnameTextBox: UITextField!
    
    @IBOutlet weak var emailTextBox: UITextField!
    
    @IBOutlet weak var phoneTextBox: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Dummy donor info
        fullnameTextBox.text = "Ameena"
        emailTextBox.text = "amoonz4905@gmail.com"
        phoneTextBox.text = "32179321"
    }
    


}
