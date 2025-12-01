//
//  DonorSignupViewController.swift
//  Ataya
//
//  Created by Ruqaya Habib on 30/11/2025.
//

import UIKit

class DonorSignupViewController: UIViewController {

    @IBOutlet weak var fullNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var eyeButton: UIButton!
    
    @IBOutlet weak var termsCheckButton: UIButton!
    
    @IBOutlet weak var termsLabel: UILabel!
    
    
    func styleTextField(_ textField: UITextField) {
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.masksToBounds = true
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        styleTextField(fullNameTextField)
        styleTextField(emailTextField)
        styleTextField(phoneTextField)
        styleTextField(passwordTextField)
        
        passwordTextField.isSecureTextEntry = true
        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        
        
        let fullText = "By signing up, you agree to the Terms of Service and Privacy Policy."

        let attributedString = NSMutableAttributedString(string: fullText)

        let grayColor = UIColor(hex: "#5A5A5A")
        let goldColor = UIColor(hex: "#F7D44C")


        attributedString.addAttribute(.foregroundColor, value: grayColor, range: NSRange(location: 0, length: fullText.count))


        if let termsRange = fullText.range(of: "Terms of Service") {
            let nsRange = NSRange(termsRange, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: goldColor, range: nsRange)
        }


        if let privacyRange = fullText.range(of: "Privacy Policy") {
            let nsRange = NSRange(privacyRange, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: goldColor, range: nsRange)
        }

        // نحط النص الملوّن داخل اللابل
        termsLabel.attributedText = attributedString


        
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        
        guard termsCheckButton.isSelected else {
                let alert = UIAlertController(
                    title: "Terms & Conditions",
                    message: "Please agree to the terms and conditions before signing up.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
            
            // هني لاحقًا بنضيف: فحص الحقول + إرسال البيانات + Firebase
            print("User accepted terms. Continue with signup...")
    }
    
    
    @IBAction func togglePassword(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        if passwordTextField.isSecureTextEntry {
            eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }
    }
    
    
    @IBAction func termsCheckTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
                sender.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            } else {
                sender.setImage(UIImage(systemName: "square"), for: .normal)
            }
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

extension UIColor {
    convenience init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
