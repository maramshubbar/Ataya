//
//  DonorSignUpViewController.swift
//  AtayaTest
//
//  Created by Ruqaya Habib on 16/12/2025.
//

import UIKit

class NGOSignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    

    @IBOutlet weak var termsCheckButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    

    @IBOutlet weak var termsLabel: UILabel!
    
    @IBOutlet weak var loginLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    

    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
    
    
    
    
    
    private let atayaYellow = UIColor(red: 0xF7/255.0, green: 0xD4/255.0, blue: 0x4C/255.0, alpha: 1.0)
    private let baseGray    = UIColor(red: 0x5A/255.0, green: 0x5A/255.0, blue: 0x5A/255.0, alpha: 1.0)
    private let eyeGray     = UIColor(red: 0xB8/255.0, green: 0xB8/255.0, blue: 0xB8/255.0, alpha: 1.0)

    private var isPasswordVisible = false
    private var isConfirmPasswordVisible = false
    private var isTermsChecked = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        setupSignUpButton()
        setupTextFields()
        setupPasswordEyes()
        setupTermsCheckbox()
        setupTermsLabel()
        setupLoginLabel()
        updateTermsUI()
        


    }
    

    
    
    
    
    // MARK: - Button
       private func setupSignUpButton() {
           signUpButton.layer.cornerRadius = 8
           signUpButton.layer.masksToBounds = true
           signUpButton.isEnabled = false
           signUpButton.alpha = 0.5
       }

       // MARK: - TextFields
       private func setupTextFields() {
           let fields: [UITextField?] = [
               nameTextField,
               emailTextField,
               phoneTextField,
               passwordTextField,
               confirmPasswordTextField
           ]

           fields.forEach { tf in
               guard let tf else { return }
               styleTextField(tf)
               tf.addTarget(self, action: #selector(textFieldFocused(_:)), for: .editingDidBegin)
               tf.addTarget(self, action: #selector(textFieldUnfocused(_:)), for: .editingDidEnd)
           }

           passwordTextField.isSecureTextEntry = true
           confirmPasswordTextField.isSecureTextEntry = true
       }

       private func styleTextField(_ tf: UITextField) {
           tf.layer.cornerRadius = 8
           tf.layer.borderWidth = 1
           tf.layer.borderColor = UIColor.systemGray4.cgColor
           tf.backgroundColor = .white
           tf.clipsToBounds = true

           let padding = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
           tf.leftView = padding
           tf.leftViewMode = .always
       }

       @objc private func textFieldFocused(_ textField: UITextField) {
           textField.layer.borderColor = eyeGray.cgColor
       }

       @objc private func textFieldUnfocused(_ textField: UITextField) {
           textField.layer.borderColor = UIColor.systemGray4.cgColor
       }

       // MARK: - Password Eyes (Password + Confirm)
       private func setupPasswordEyes() {
           addEyeButton(to: passwordTextField, selector: #selector(togglePassword))
           addEyeButton(to: confirmPasswordTextField, selector: #selector(toggleConfirmPassword))
       }

       private func addEyeButton(to textField: UITextField, selector: Selector) {
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

       @objc private func togglePassword() {
           isPasswordVisible.toggle()
           toggleSecure(for: passwordTextField, isVisible: isPasswordVisible)
       }

       @objc private func toggleConfirmPassword() {
           isConfirmPasswordVisible.toggle()
           toggleSecure(for: confirmPasswordTextField, isVisible: isConfirmPasswordVisible)
       }

       private func toggleSecure(for textField: UITextField, isVisible: Bool) {
           let text = textField.text
           textField.isSecureTextEntry = !isVisible
           textField.text = text

           let imageName = isVisible ? "eye" : "eye.slash"
           if let container = textField.rightView,
              let button = container.subviews.first as? UIButton {
               var cfg = button.configuration
               cfg?.image = UIImage(systemName: imageName)
               button.configuration = cfg
           }
       }

       // MARK: - Terms
       private func setupTermsCheckbox() {
           termsCheckButton.layer.cornerRadius = 4
           termsCheckButton.layer.borderWidth = 1
           termsCheckButton.layer.borderColor = UIColor.systemGray4.cgColor
           termsCheckButton.backgroundColor = .white

           termsCheckButton.setImage(nil, for: .normal)
           termsCheckButton.tintColor = .white

           termsCheckButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
           termsCheckButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
       }

       private func setupTermsLabel() {
           let text = "By signing up, you agree to the Terms of service and Privacy policy."
           let attr = NSMutableAttributedString(string: text)
           attr.addAttribute(.foregroundColor, value: baseGray, range: NSRange(location: 0, length: text.count))

           let termsRange = (text as NSString).range(of: "Terms of service")
           let privacyRange = (text as NSString).range(of: "Privacy policy")

           if termsRange.location != NSNotFound { attr.addAttribute(.foregroundColor, value: atayaYellow, range: termsRange) }
           if privacyRange.location != NSNotFound { attr.addAttribute(.foregroundColor, value: atayaYellow, range: privacyRange) }

           termsLabel.attributedText = attr
           termsLabel.numberOfLines = 0
       }

       private func setupLoginLabel() {
           let text = "Already have an account? Log in"
           let attr = NSMutableAttributedString(string: text)
           attr.addAttribute(.foregroundColor, value: baseGray, range: NSRange(location: 0, length: text.count))

           let loginRange = (text as NSString).range(of: "Log in")
           if loginRange.location != NSNotFound {
               attr.addAttribute(.foregroundColor, value: atayaYellow, range: loginRange)
           }

           loginLabel.attributedText = attr
           loginLabel.numberOfLines = 1
       }

       private func updateTermsUI() {
           if isTermsChecked {
               termsCheckButton.backgroundColor = UIColor(red: 0x4C/255.0, green: 0xAF/255.0, blue: 0x50/255.0, alpha: 1.0)
               termsCheckButton.setImage(
                   UIImage(systemName: "checkmark")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)),
                   for: .normal
               )
               termsCheckButton.layer.borderColor = UIColor.clear.cgColor
           } else {
               termsCheckButton.backgroundColor = .white
               termsCheckButton.setImage(nil, for: .normal)
               termsCheckButton.layer.borderColor = UIColor.systemGray4.cgColor
           }

           signUpButton.isEnabled = isTermsChecked
           signUpButton.alpha = isTermsChecked ? 1.0 : 0.5
       }

       // MARK: - Actions
       @IBAction func termsCheckTapped(_ sender: UIButton) {
           isTermsChecked.toggle()
           updateTermsUI()
       }

       @IBAction func signUpPressed(_ sender: UIButton) {
           print("NGO Sign Up tapped")
       }
    
    
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        
        performSegue(withIdentifier: "ngoToOrgDetailsSegue", sender: self)


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
