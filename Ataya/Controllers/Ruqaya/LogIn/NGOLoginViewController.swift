//
//  NGOLoginViewController.swift
//  Ataya
//
//  Created by Ruqaya Habib on 17/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class NGOLoginViewController: UIViewController {

    
    @IBOutlet weak var forgetPasswordLabel: UILabel!
    
    @IBOutlet weak var rememberCheckButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBOutlet weak var signUpLabel: UILabel!

    private let atayaYellow = UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 1)
    private let baseGray   = UIColor(red: 0x5A/255, green: 0x5A/255, blue: 0x5A/255, alpha: 1)
    private let eyeGray  = UIColor(red: 0xB8/255.0, green: 0xB8/255.0, blue: 0xB8/255.0, alpha: 1.0)


    private var isPasswordVisible = false
    
    
    private var isRememberChecked = false


    private let db = Firestore.firestore()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupForgetPasswordTap()
        
        setupPasswordEye()
        setupSignUpLabel()
        setuploginButton()
        
        setupRememberCheckbox()
        updateRememberUI()

        emailTextField.addTarget(self, action: #selector(textFieldsChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldsChanged), for: .editingChanged)

        loginButton.isEnabled = false
        loginButton.alpha = 0.5
        

        signUpLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(signUpTapped))
        signUpLabel.addGestureRecognizer(tap)
        


    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    

    @objc private func signUpTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "NGOSignUpViewController"
        )
        navigationController?.pushViewController(vc, animated: true)
    }


    
    
    
    private func setupForgetPasswordTap() {
        forgetPasswordLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(forgetPasswordTapped))
        forgetPasswordLabel.addGestureRecognizer(tap)
    }

    @objc private func forgetPasswordTapped() {
        performSegue(withIdentifier: "ngoForgotSegue", sender: self)
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
                UIImage(systemName: "checkmark")?
                    .withConfiguration(UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)),
                for: .normal
            )
            rememberCheckButton.layer.borderColor = UIColor.clear.cgColor
        } else {
            rememberCheckButton.backgroundColor = .white
            rememberCheckButton.setImage(nil, for: .normal)
            rememberCheckButton.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }

    
    
    
    private func setuploginButton() {
        loginButton.layer.cornerRadius = 8
        }

    private func setupPasswordEye() {
        var config = UIButton.Configuration.plain()
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        config.baseForegroundColor = eyeGray
        config.image = UIImage(systemName: "eye.slash")
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 14)

        let eyeButton = UIButton(configuration: config)
        eyeButton.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        eyeButton.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
        container.addSubview(eyeButton)

        passwordTextField.rightView = container
        passwordTextField.rightViewMode = .always
    }

    @objc private func togglePassword() {
        isPasswordVisible.toggle()

        let text = passwordTextField.text
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        passwordTextField.text = text

        let imageName = isPasswordVisible ? "eye" : "eye.slash"
        if let container = passwordTextField.rightView,
           let button = container.subviews.first as? UIButton {
            var config = button.configuration
            config?.image = UIImage(systemName: imageName)
            button.configuration = config
        }
    }
    
    
    private func setupSignUpLabel() {
        let text = "Don’t have an account? Sign Up"
        let attr = NSMutableAttributedString(string: text)

        attr.addAttribute(.foregroundColor, value: baseGray, range: NSRange(location: 0, length: text.count))

        let SignUpRange = (text as NSString).range(of: "Sign Up")
        if SignUpRange.location != NSNotFound {
            attr.addAttribute(.foregroundColor, value: atayaYellow, range: SignUpRange)
        }

        signUpLabel.attributedText = attr
        signUpLabel.numberOfLines = 1
    }
    
    @objc private func textFieldsChanged() {
        let emailFilled = !(emailTextField.text ?? "").isEmpty
        let passwordFilled = !(passwordTextField.text ?? "").isEmpty

        let shouldEnable = emailFilled && passwordFilled

        loginButton.isEnabled = shouldEnable
        loginButton.alpha = shouldEnable ? 1.0 : 0.5
    }

    
    @IBAction func rememberCheckTapped(_ sender: UIButton) {
        isRememberChecked.toggle()
        updateRememberUI()
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let password = (passwordTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

            guard !email.isEmpty else {
                showAlert(title: "Missing Email", message: "Please enter your email.")
                return
            }

            guard !password.isEmpty else {
                showAlert(title: "Missing Password", message: "Please enter your password.")
                return
            }

            guard loginButton.isEnabled else { return }

            Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                if let error = error {
                    self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                    return
                }


                guard let uid = result?.user.uid else {
                    self?.showAlert(title: "Error", message: "Missing user id.")
                    return
                }
                
                if self?.isRememberChecked == true, let uid = result?.user.uid {
                    UserDefaults.standard.set(uid, forKey: "ngo_uid")
                } else {
                    UserDefaults.standard.removeObject(forKey: "ngo_uid")
                }

            

                self?.db.collection("users").document(uid).getDocument { snap, err in
                    if let err = err {
                        self?.showAlert(title: "Firestore Error", message: err.localizedDescription)
                        return
                    }

                    guard let data = snap?.data() else {
                        self?.showAlert(title: "No Profile", message: "Your profile is not found in Firestore.")
                        return
                    }

                    let role = (data["role"] as? String) ?? ""
                    if role != "ngo" {
                        self?.showAlert(title: "Wrong Account", message: "This account is not an NGO account.")
                        try? Auth.auth().signOut()
                        return
                    }

                    // ✅ هني بس توديه للـ NGO Home
                    self?.performSegue(withIdentifier: "toNGOHome", sender: nil)
                }

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
