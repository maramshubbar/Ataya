//
//  OTPVerificationViewController.swift
//  AtayaTest
//
//  Created by Ruqaya Habib on 19/12/2025.
//

import UIKit
import FirebaseAuth


class OTPVerificationViewController: UIViewController, UITextFieldDelegate {

    
    
    @IBOutlet weak var otp1: UITextField!
    
    @IBOutlet weak var otp2: UITextField!
    
    @IBOutlet weak var otp3: UITextField!
    
    
    @IBOutlet weak var otp4: UITextField!
    
    @IBOutlet weak var opt5: UITextField!
    
    @IBOutlet weak var verifyButton: UIButton!
    
        
    @IBOutlet weak var resendLabel: UILabel!
    
    private let atayaYellow = UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 1)
    private let otpBorder   = UIColor.systemGreen.withAlphaComponent(0.55)

    private var fields: [UITextField] { [otp1, otp2, otp3, otp4, opt5] }


    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        setupOTPFields()
        styleVerifyButton()
        styleResendLabel()
        otp1.becomeFirstResponder()
        updateVerifyState()


    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

   
    private func setupOTPFields() {
        for (index, tf) in fields.enumerated() {
            tf.text = ""                       // فاضي
            tf.delegate = self
            tf.tag = index

            // keyboard + behavior
            tf.keyboardType = .numberPad
            tf.textAlignment = .center
            tf.autocorrectionType = .no
            tf.spellCheckingType = .no
            tf.smartDashesType = .no
            tf.smartQuotesType = .no
            tf.smartInsertDeleteType = .no

            // style: yellow fill + green border
            tf.backgroundColor = atayaYellow.withAlphaComponent(0.22)
            tf.layer.cornerRadius = 10
            tf.layer.borderWidth = 1.5
            tf.layer.borderColor = otpBorder.cgColor
            tf.clipsToBounds = true

            // clear button off
            tf.clearButtonMode = .never

            // مهم: علشان نتحكم بالـ backspace
            tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        }
    }

    private func styleVerifyButton() {
        verifyButton.layer.cornerRadius = 8
        verifyButton.clipsToBounds = true
        verifyButton.isEnabled = false
        verifyButton.alpha = 0.5
    }

    private func styleResendLabel() {
        let fullText = "Don’t receive code? Resend again"
        let attributed = NSMutableAttributedString(string: fullText)


        let resendRange = (fullText as NSString).range(of: "Resend again")
        attributed.addAttribute(.foregroundColor, value: atayaYellow, range: resendRange)


        resendLabel.attributedText = attributed
        resendLabel.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(resendTapped))
        resendLabel.addGestureRecognizer(tap)
    }

    // MARK: - OTP Logic

    @objc private func textDidChange(_ tf: UITextField) {

        if let text = tf.text, text.count > 1 {
            tf.text = String(text.suffix(1))
        }


        if let text = tf.text, text.count == 1 {
            let nextIndex = tf.tag + 1
            if nextIndex < fields.count {
                fields[nextIndex].becomeFirstResponder()
            } else {
                tf.resignFirstResponder()
            }
        }
        updateVerifyState()
    }


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        // backspace
        if string.isEmpty {
            
            if (textField.text ?? "").isEmpty {
                let prevIndex = textField.tag - 1
                if prevIndex >= 0 {
                    let prev = fields[prevIndex]
                    prev.becomeFirstResponder()
                    prev.text = ""
                }
                return false
            }
            return true
        }


        let allowed = CharacterSet.decimalDigits
        if string.rangeOfCharacter(from: allowed.inverted) != nil { return false }


        let current = textField.text ?? ""
        let newLength = current.count - range.length + string.count
        return newLength <= 1
    }
    
    
    @IBAction func verifyTapped(_ sender: UIButton) {
        showAlert(title: "Check Email", message: "We sent you a reset link. Open your email and reset your password, then log in.")

        
        
    }
    
    @objc private func resendTapped() {
        let email = UserDefaults.standard.string(forKey: "reset_email") ?? ""

        guard !email.isEmpty else {
            showAlert(title: "Missing Email", message: "Go back and enter your email again.")
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Resend Failed", message: error.localizedDescription)
                return
            }
            self?.showAlert(title: "Email Resent", message: "Check your email again.")
        }

    }
    
    private func updateVerifyState() {
        let allFilled = fields.allSatisfy { !($0.text ?? "").isEmpty }

        verifyButton.isEnabled = allFilled
        verifyButton.alpha = allFilled ? 1.0 : 0.5
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
