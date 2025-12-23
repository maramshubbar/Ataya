//
//  AdminLoginViewController.swift
//  AtayaTest
//
//  Created by Ruqaya Habib on 18/12/2025.
//

import UIKit
import FirebaseAuth

class AdminLoginViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    
    
    
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    
    @IBOutlet weak var rememberCheckButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    

    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var uploadProfileLabel: UILabel!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    private let baseGray   = UIColor(red: 0x5A/255, green: 0x5A/255, blue: 0x5A/255, alpha: 1)
    private let eyeGray  = UIColor(red: 0xB8/255.0, green: 0xB8/255.0, blue: 0xB8/255.0, alpha: 1.0)
    
    private var isPasswordVisible = false
    private var isConfirmPasswordVisible = false
    private var isRememberChecked = false

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupLoginButton()
        setupTextFields()

        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true

        setupPasswordEyes()
        setupProfileUI()
        updatePasswordMatchUI()
        
        setupLoginEnabledRule()
        updateLoginButtonState()

        
        setupRememberCheckbox()
        updateRememberUI()

        
        
        forgotPasswordLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(forgotPasswordTapped))
        forgotPasswordLabel.addGestureRecognizer(tap)


    }
    
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    
    
    @objc private func forgotPasswordTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ForgotPasswordViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    
    
    private func setupRememberCheckbox() {
        rememberCheckButton.layer.cornerRadius = 4
        rememberCheckButton.layer.borderWidth = 1
        rememberCheckButton.layer.borderColor = UIColor.systemGray4.cgColor
        rememberCheckButton.backgroundColor = .white
        rememberCheckButton.setImage(nil, for: .normal)
        rememberCheckButton.tintColor = .white

        rememberCheckButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        rememberCheckButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }

    private func updateRememberUI() {
        if isRememberChecked {
            rememberCheckButton.backgroundColor = UIColor(red: 0x4C/255.0, green: 0xAF/255.0, blue: 0x50/255.0, alpha: 1.0)
            rememberCheckButton.setImage(
                UIImage(systemName: "checkmark")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)),
                for: .normal
            )
            rememberCheckButton.layer.borderColor = UIColor.clear.cgColor
        } else {
            rememberCheckButton.backgroundColor = .white
            rememberCheckButton.setImage(nil, for: .normal)
            rememberCheckButton.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }

    
    private func setupLoginEnabledRule() {
        loginButton.isEnabled = false
        loginButton.alpha = 0.5

        [emailTextField, passwordTextField, confirmPasswordTextField].forEach { tf in
            tf?.addTarget(self, action: #selector(fieldsDidChange), for: .editingChanged)
        }
    }

    @objc private func fieldsDidChange() {
        updatePasswordMatchUI()      // اللي عندك
        updateLoginButtonState()
    }

    private func updateLoginButtonState() {
        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let p1 = passwordTextField.text ?? ""
        let p2 = confirmPasswordTextField.text ?? ""

        let isValid = !email.isEmpty && !p1.isEmpty && !p2.isEmpty && (p1 == p2)

        loginButton.isEnabled = isValid
        loginButton.alpha = isValid ? 1.0 : 0.5
    }

    
    // MARK: - Button
        private func setupLoginButton() {
            loginButton.layer.cornerRadius = 8
            loginButton.layer.masksToBounds = true
        }

        // MARK: - TextFields
        private func setupTextFields() {
            let fields: [UITextField] = [emailTextField, passwordTextField, confirmPasswordTextField]

            fields.forEach { tf in
                tf.layer.cornerRadius = 8
                tf.layer.borderWidth = 1
                tf.layer.borderColor = UIColor.systemGray4.cgColor
                tf.backgroundColor = .white
                tf.clipsToBounds = true

                let padding = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
                tf.leftView = padding
                tf.leftViewMode = .always

                tf.clearButtonMode = .never

                tf.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
            }
        }

        @objc private func textChanged(_ sender: UITextField) {
            updatePasswordMatchUI()
        }

        // MARK: - Password Eyes (SAME AS DONOR)
        private func setupPasswordEyes() {
            addEyeButton(to: passwordTextField, selector: #selector(togglePassword))
            addEyeButton(to: confirmPasswordTextField, selector: #selector(toggleConfirmPassword))
        }

        private func addEyeButton(to textField: UITextField, selector: Selector) {

            textField.rightView = nil
            textField.rightViewMode = .never

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
            updateEyeIcon(in: passwordTextField, isVisible: isPasswordVisible)
        }

        @objc private func toggleConfirmPassword() {
            isConfirmPasswordVisible.toggle()
            toggleSecure(for: confirmPasswordTextField, isVisible: isConfirmPasswordVisible)
            updateEyeIcon(in: confirmPasswordTextField, isVisible: isConfirmPasswordVisible)
        }

        private func toggleSecure(for textField: UITextField, isVisible: Bool) {
            let text = textField.text
            textField.isSecureTextEntry = !isVisible
            textField.text = text
        }

        private func updateEyeIcon(in textField: UITextField, isVisible: Bool) {
            let imageName = isVisible ? "eye" : "eye.slash"
            if let container = textField.rightView,
               let button = container.subviews.first as? UIButton {
                var cfg = button.configuration
                cfg?.image = UIImage(systemName: imageName)
                button.configuration = cfg
            }
        }

        // MARK: - Match UI
        private func passwordsMatch() -> Bool {
            let p1 = passwordTextField.text ?? ""
            let p2 = confirmPasswordTextField.text ?? ""
            return !p1.isEmpty && p1 == p2
        }

        private func updatePasswordMatchUI() {
            let confirmText = confirmPasswordTextField.text ?? ""

            if confirmText.isEmpty {
                confirmPasswordTextField.layer.borderColor = UIColor.systemGray4.cgColor
                return
            }

            confirmPasswordTextField.layer.borderColor = passwordsMatch()
            ? UIColor.systemGreen.cgColor
            : UIColor.systemRed.cgColor
        }

        // MARK: - Profile UI
        private func setupProfileUI() {
            profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
            profileImageView.tintColor = .systemGray3
            profileImageView.contentMode = .scaleAspectFit

            uploadProfileLabel.text = "Upload Profile Pic"
            uploadProfileLabel.textColor = .systemBlue

            profileImageView.isUserInteractionEnabled = true
            uploadProfileLabel.isUserInteractionEnabled = true

            profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTapped)))
            uploadProfileLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTapped)))
        }

        @objc private func profileTapped() {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            present(picker, animated: true)
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let img = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
            if let img {
                profileImageView.image = img
                profileImageView.contentMode = .scaleAspectFill
                profileImageView.clipsToBounds = true
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }

        // MARK: - Login Action
        @IBAction func loginPressed(_ sender: UIButton) {
                let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let password = passwordTextField.text ?? ""
                let confirm = confirmPasswordTextField.text ?? ""

                // 1) Validation
                guard !email.isEmpty else {
                    showAlert(title: "Missing Email", message: "Please enter your email.")
                    return
                }

                guard !password.isEmpty else {
                    showAlert(title: "Missing Password", message: "Please enter your password.")
                    return
                }

                guard !confirm.isEmpty else {
                    showAlert(title: "Missing Confirm Password", message: "Please confirm your password.")
                    return
                }

                guard password == confirm else {
                    showAlert(title: "Password Mismatch", message: "Passwords do not match.")
                    return
                }

                // 2) Firebase Login
                Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                    if let error = error {
                        self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                        return
                    }

                    // 3) Remember Me (اختياري)
                    if self?.isRememberChecked == true, let uid = result?.user.uid {
                        UserDefaults.standard.set(uid, forKey: "admin_uid")
                    } else {
                        UserDefaults.standard.removeObject(forKey: "admin_uid")
                    }

                    // 4) Navigation
                    self?.performSegue(withIdentifier: "toAdminHome", sender: nil)
                }
            }

    
  
    
    @IBAction func rememberCheckTapped(_ sender: UIButton) {
        isRememberChecked.toggle()
        updateRememberUI()
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
