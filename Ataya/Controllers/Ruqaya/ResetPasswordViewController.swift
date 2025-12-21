//
//  ResetPasswordViewController.swift
//  AtayaTest
//
//  Created by Ruqaya Habib on 19/12/2025.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    
    @IBOutlet weak var newpasswordTextField: UITextField!
    
    
    @IBOutlet weak var verifyTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    private let baseGray   = UIColor(red: 0x5A/255, green: 0x5A/255, blue: 0x5A/255, alpha: 1)
    private let eyeGray  = UIColor(red: 0xB8/255.0, green: 0xB8/255.0, blue: 0xB8/255.0, alpha: 1.0)
    

    
    private var isNewPasswordVisible = false
    private var isVerifyPasswordVisible = false


    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        setupSaveButton()

        newpasswordTextField.isSecureTextEntry = true
        verifyTextField.isSecureTextEntry = true

        setupPasswordEye(for: newpasswordTextField, selector: #selector(toggleNewPassword))
        setupPasswordEye(for: verifyTextField, selector: #selector(toggleVerifyPassword))
        
        
        newpasswordTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        verifyTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        updateSaveButtonState()

        
        definesPresentationContext = true
    }
    
    @objc private func textChanged() {
            updateSaveButtonState()
        }

        private func updateSaveButtonState() {
            let pass = newpasswordTextField.text ?? ""
            let verify = verifyTextField.text ?? ""

            let isValid = isValidPassword(pass) && pass == verify

            // ✅ لا تخفينه، بس Disable
            saveButton.isEnabled = isValid
            saveButton.alpha = isValid ? 1.0 : 0.5
        }

        private func isValidPassword(_ password: String) -> Bool {
            guard password.count >= 8 else { return false }
            let specialChar = CharacterSet.alphanumerics.inverted
            return password.rangeOfCharacter(from: specialChar) != nil
        }

        private func setupSaveButton() {
            saveButton.layer.cornerRadius = 8
            saveButton.clipsToBounds = true

            // ✅ شكل disabled من البداية
            saveButton.isEnabled = false
            saveButton.alpha = 0.5
        }

        private func setupPasswordEye(for textField: UITextField, selector: Selector) {
            var config = UIButton.Configuration.plain()
            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
            config.baseForegroundColor = eyeGray
            config.image = UIImage(systemName: "eye.slash")
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 14)

            let eyeButton = UIButton(configuration: config)
            eyeButton.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
            eyeButton.addTarget(self, action: selector, for: .touchUpInside)

            let container = UIView(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
            container.addSubview(eyeButton)

            textField.rightView = container
            textField.rightViewMode = .always
        }

        @objc private func toggleNewPassword() {
            isNewPasswordVisible.toggle()
            toggle(textField: newpasswordTextField, isVisible: isNewPasswordVisible)
        }

        @objc private func toggleVerifyPassword() {
            isVerifyPasswordVisible.toggle()
            toggle(textField: verifyTextField, isVisible: isVerifyPasswordVisible)
        }

        private func toggle(textField: UITextField, isVisible: Bool) {
            let text = textField.text
            textField.isSecureTextEntry = !isVisible
            textField.text = text

            let imageName = isVisible ? "eye" : "eye.slash"
            if let container = textField.rightView,
               let button = container.subviews.first as? UIButton {
                var config = button.configuration
                config?.image = UIImage(systemName: imageName)
                button.configuration = config
            }
        }

        @IBAction func saveTapped(_ sender: UIButton) {
            print("save tapped")
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "PasswordChangedViewController")
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true)
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
