//
//  ForgotPasswordViewController.swift
//  AtayaTest
//
//  Created by Ruqaya Habib on 21/12/2025.
//

import UIKit
import FirebaseAuth


final class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var sendLinkButton: UIButton!
    
    
    
    @IBOutlet weak var resendLabel: UILabel!
    
    
    
    @IBOutlet weak var backToLoginLabel: UILabel!
    
    
    
    
    private let atayaYellow = UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 1)
    private let baseGray    = UIColor(red: 0x5A/255, green: 0x5A/255, blue: 0x5A/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupButton()
        setupEmailField()
        setupResendLabel()
        setupBackToLoginLabel()
        updateButtonState()
    }

    // MARK: - UI

    private func setupButton() {
        sendLinkButton.layer.cornerRadius = 8
        sendLinkButton.layer.masksToBounds = true
        sendLinkButton.isEnabled = false
        sendLinkButton.alpha = 0.5
    }

    private func setupEmailField() {
        emailTextField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
    }

    private func setupResendLabel() {
        let fullText = "Don’t receive link? Resend again"
        let attr = NSMutableAttributedString(string: fullText)

        // كله رمادي
        attr.addAttribute(.foregroundColor, value: baseGray,
                          range: NSRange(location: 0, length: fullText.count))

        // Resend again أصفر
        let resendRange = (fullText as NSString).range(of: "Resend again")
        if resendRange.location != NSNotFound {
            attr.addAttribute(.foregroundColor, value: atayaYellow, range: resendRange)
        }

        resendLabel.attributedText = attr
        resendLabel.isUserInteractionEnabled = true
        resendLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resendTapped)))
    }

    private func setupBackToLoginLabel() {
        backToLoginLabel.text = "Back to Login"
        backToLoginLabel.textColor = .systemBlue  
        backToLoginLabel.isUserInteractionEnabled = true
        backToLoginLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backToLoginTapped)))
    }

    // MARK: - Helpers

    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    @objc private func emailChanged() { updateButtonState() }

    private func updateButtonState() {
        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let ok = isValidEmail(email)
        sendLinkButton.isEnabled = ok
        sendLinkButton.alpha = ok ? 1.0 : 0.5
    }

    private func isValidEmail(_ email: String) -> Bool {
        email.contains("@") && email.contains(".") && email.count >= 5
    }

    // MARK: - Actions

    @IBAction func sendLinkPressed(_ sender: UIButton) {
        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
           guard isValidEmail(email) else {
               showAlert(title: "Invalid Email", message: "Please enter a valid email.")
               return
           }

           UserDefaults.standard.set(email, forKey: "reset_email")

           sendLinkButton.isEnabled = false
           sendLinkButton.alpha = 0.5

           Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
               guard let self else { return }

               if let error = error {
                   self.showAlert(title: "Error", message: error.localizedDescription)
                   // خليه يرجع يتفعل عادي إذا فشل
                   self.updateButtonState()
                   return
               }

               self.showAlert(title: "Email Sent", message: "Check your email to reset your password.")

               DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                   self?.updateButtonState()
               }
           }
    }

    @objc private func resendTapped() {
        let email = UserDefaults.standard.string(forKey: "reset_email") ?? ""
        guard !email.isEmpty else {
            showAlert(title: "Missing Email", message: "Enter your email first, then send the reset link.")
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self else { return }

            if let error = error {
                self.showAlert(title: "Resend Failed", message: error.localizedDescription)
                return
            }

            self.showAlert(title: "Email Resent", message: "We sent the reset link again. Check your email.")
        }
    }
    
    @objc private func backToLoginTapped() {
        navigationController?.popViewController(animated: true)
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
