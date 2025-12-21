//
//  ForgotPasswordViewController.swift
//  AtayaTest
//
//  Created by Ruqaya Habib on 21/12/2025.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var sendCodeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupButton()
        setupEmailField()
        updateButtonState()
        
        
    }
    

    
    private func setupButton() {
            sendCodeButton.layer.cornerRadius = 8
            sendCodeButton.layer.masksToBounds = true

            sendCodeButton.isEnabled = false
            sendCodeButton.alpha = 0.5
        }

        private func setupEmailField() {

            emailTextField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
            emailTextField.keyboardType = .emailAddress
            emailTextField.autocapitalizationType = .none
            emailTextField.autocorrectionType = .no
        }

        @objc private func emailChanged() {
            updateButtonState()
        }

        private func updateButtonState() {
            let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let ok = isValidEmail(email)

            sendCodeButton.isEnabled = ok
            sendCodeButton.alpha = ok ? 1.0 : 0.5
        }

        private func isValidEmail(_ email: String) -> Bool {

            return email.contains("@") && email.contains(".") && email.count >= 5
        }

        @IBAction func sendCodePressed(_ sender: UIButton) {
            guard sendCodeButton.isEnabled else { return }

            let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            print("Send code to: \(email)")
            // لاحقاً: Firebase reset password / send code
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
