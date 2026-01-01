//
//  DonorLoginViewController.swift
//  AtayaTest
//
//  Created by Ruqaya Habib on 17/12/2025.
//
//
//  DonorLoginViewController.swift
//  AtayaTest
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class DonorLoginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var rememberCheckButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgetPasswordLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!

    // MARK: - Theme
    private let atayaYellow = UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 1)
    private let baseGray   = UIColor(red: 0x5A/255, green: 0x5A/255, blue: 0x5A/255, alpha: 1)
    private let eyeGray    = UIColor(red: 0xB8/255.0, green: 0xB8/255.0, blue: 0xB8/255.0, alpha: 1.0)

    // MARK: - State
    private var isPasswordVisible = false
    private var isRememberChecked = false
    private let db = Firestore.firestore()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupForgetPasswordTap()
        setupPasswordEye()
        setupSignUpLabel()
        setuploginButton()

        setupRememberCheckbox()
        updateRememberUI()

        loginButton.isEnabled = false
        loginButton.alpha = 0.5

        emailTextField.addTarget(self, action: #selector(textFieldsChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldsChanged), for: .editingChanged)

        signUpLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(openSignUp))
        signUpLabel.addGestureRecognizer(tap)
    }

    // MARK: - Alerts
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UI helpers
    private func setLoading(_ loading: Bool) {
        loginButton.isEnabled = !loading
        loginButton.alpha = loading ? 0.5 : 1.0
        view.isUserInteractionEnabled = !loading
    }

    @objc private func textFieldsChanged() {
        let emailFilled = !(emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let passwordFilled = !(passwordTextField.text ?? "").isEmpty
        let shouldEnable = emailFilled && passwordFilled

        loginButton.isEnabled = shouldEnable
        loginButton.alpha = shouldEnable ? 1.0 : 0.5
    }

    // MARK: - Remember checkbox UI
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
                UIImage(systemName: "checkmark")?.withConfiguration(
                    UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
                ),
                for: .normal
            )
            rememberCheckButton.layer.borderColor = UIColor.clear.cgColor
        } else {
            rememberCheckButton.backgroundColor = .white
            rememberCheckButton.setImage(nil, for: .normal)
            rememberCheckButton.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }

    // MARK: - Setup
    private func setuploginButton() {
        loginButton.layer.cornerRadius = 8
    }

    private func setupForgetPasswordTap() {
        forgetPasswordLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(forgetPasswordTapped))
        forgetPasswordLabel.addGestureRecognizer(tap)
    }

    @objc private func forgetPasswordTapped() {
        performSegue(withIdentifier: "donorForgotSegue", sender: self)
    }

    @objc private func openSignUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DonorSignUpViewController")
        navigationController?.pushViewController(vc, animated: true)
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

        let signUpRange = (text as NSString).range(of: "Sign Up")
        if signUpRange.location != NSNotFound {
            attr.addAttribute(.foregroundColor, value: atayaYellow, range: signUpRange)
        }

        signUpLabel.attributedText = attr
        signUpLabel.numberOfLines = 1
    }

    // MARK: - Actions
    @IBAction func rememberCheckTapped(_ sender: UIButton) {
        isRememberChecked.toggle()
        updateRememberUI()
    }

    @IBAction func loginPressed(_ sender: UIButton) {

        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = (passwordTextField.text ?? "") // don’t trim password

        guard !email.isEmpty else {
            showAlert(title: "Missing Email", message: "Please enter your email.")
            return
        }

        guard !password.isEmpty else {
            showAlert(title: "Missing Password", message: "Please enter your password.")
            return
        }

        guard loginButton.isEnabled else { return }

        setLoading(true)

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }

            if let error = error as NSError? {
                let code = AuthErrorCode(rawValue: error.code)

                switch code {

                case .wrongPassword:
                    self.showAlert(title: "Login Failed", message: "Wrong password.")

                case .userNotFound:
                    self.showAlert(title: "Login Failed", message: "No account found for this email. Please sign up.")

                case .invalidEmail:
                    self.showAlert(title: "Login Failed", message: "Please enter a valid email.")

                case .invalidCredential:
                    // ✅ This is your screenshot error: “credential malformed or expired”
                    // We check what method this email uses (password / google / apple)
                    Auth.auth().fetchSignInMethods(forEmail: email) { methods, _ in
                        let m = methods ?? []
                        if m.contains("google.com") {
                            self.showAlert(title: "Login Failed", message: "This email was registered using Google. Please sign in with Google.")
                        } else if m.contains("apple.com") {
                            self.showAlert(title: "Login Failed", message: "This email was registered using Apple. Please sign in with Apple.")
                        } else if m.contains("password") {
                            self.showAlert(title: "Login Failed", message: "Email or password is incorrect.")
                        } else {
                            self.showAlert(title: "Login Failed", message: "Email or password is incorrect.")
                        }
                        self.setLoading(false)
                    }
                    return

                case .tooManyRequests:
                    self.showAlert(title: "Login Failed", message: "Too many attempts. Try again later.")

                default:
                    self.showAlert(title: "Login Failed", message: error.localizedDescription)
                }

                self.setLoading(false)
                return
            }

            guard let uid = result?.user.uid else {
                self.showAlert(title: "Error", message: "Missing user id.")
                self.setLoading(false)
                return
            }

            // Remember Me: store email/uid (no password)
            if self.isRememberChecked {
                UserDefaults.standard.set(uid, forKey: "donor_uid")
                UserDefaults.standard.set(email, forKey: "donor_email")
            } else {
                UserDefaults.standard.removeObject(forKey: "donor_uid")
                UserDefaults.standard.removeObject(forKey: "donor_email")
            }

            UserDefaults.standard.set(email, forKey: "current_email")
            UserDefaults.standard.set(uid, forKey: "current_uid")

            // ✅ Fetch donor profile from Firestore
            // IMPORTANT: Your Firestore rules must allow:
            // allow read: if request.auth != null && request.auth.uid == uid;
            self.db.collection("users").document(uid).getDocument { [weak self] snap, err in
                guard let self else { return }

                if let err = err {
                    self.showAlert(title: "Firestore Error", message: err.localizedDescription)
                    try? Auth.auth().signOut()
                    self.setLoading(false)
                    return
                }

                guard let data = snap?.data() else {
                    self.showAlert(title: "No Profile", message: "Your profile is missing in Firestore. Please sign up again or contact support.")
                    try? Auth.auth().signOut()
                    self.setLoading(false)
                    return
                }

                let role = (data["role"] as? String ?? "").lowercased()
                if role != "donor" {
                    self.showAlert(title: "Wrong Account", message: "This email is not registered as a Donor.")
                    try? Auth.auth().signOut()
                    self.setLoading(false)
                    return
                }

                // Accept different field names
                let name =
                    (data["name"] as? String)
                    ?? (data["fullName"] as? String)
                    ?? (data["full_name"] as? String)
                    ?? ""

                let phone =
                    (data["phone"] as? String)
                    ?? (data["phoneNumber"] as? String)
                    ?? ""

                UserDefaults.standard.set("donor", forKey: "current_role")
                UserDefaults.standard.set(name, forKey: "donor_name")
                UserDefaults.standard.set(phone, forKey: "donor_phone")

                self.setLoading(false)
                self.performSegue(withIdentifier: "toDonorHome", sender: nil)
            }
        }
    }
}
