//
//  AdminLoginViewController.swift
//  Ataya
//
//  Created by Ruqaya Habib on 18/12/2025.
//
//
//  AdminLoginViewController.swift
//  Ataya
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

final class AdminLoginViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var rememberCheckButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var uploadProfileLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    private let eyeGray  = UIColor(red: 0xB8/255.0, green: 0xB8/255.0, blue: 0xB8/255.0, alpha: 1.0)

    private var isPasswordVisible = false
    private var isConfirmPasswordVisible = false
    private var isRememberChecked = false

    private let db = Firestore.firestore()

    // ✅ مهم: يمنع أي segue يشتغل تلقائياً إلا إذا سمحنا له بعد نجاح الأدمن
    private var allowAdminDashSegue = false

    override func viewDidLoad() {
        super.viewDidLoad()

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

    // ✅ يمنع التحويل التلقائي (لو عندك segue متصل بالزر)
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "toAdminDash" {
            return allowAdminDashSegue
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAdminDash" {
            segue.destination.modalPresentationStyle = .fullScreen
        }
    }

    // MARK: - Helpers
    private func setLoading(_ loading: Bool) {
        loginButton.isEnabled = !loading
        loginButton.alpha = loading ? 0.5 : 1.0
        view.isUserInteractionEnabled = !loading
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func forgotPasswordTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ForgotPasswordViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Remember checkbox
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

    private func setupLoginEnabledRule() {
        loginButton.isEnabled = false
        loginButton.alpha = 0.5

        [emailTextField, passwordTextField, confirmPasswordTextField].forEach { tf in
            tf?.addTarget(self, action: #selector(fieldsDidChange), for: .editingChanged)
        }
    }

    @objc private func fieldsDidChange() {
        updatePasswordMatchUI()
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

    // MARK: - UI setup
    private func setupLoginButton() {
        loginButton.layer.cornerRadius = 8
        loginButton.layer.masksToBounds = true
    }

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
        }
    }

    // MARK: - Password eyes
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

    // MARK: - Actions
    @IBAction func rememberCheckTapped(_ sender: UIButton) {
        isRememberChecked.toggle()
        updateRememberUI()
    }

    @IBAction func loginPressed(_ sender: UIButton) {

        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text ?? ""
        let confirm  = confirmPasswordTextField.text ?? ""

        guard !email.isEmpty else { showAlert(title: "Missing Email", message: "Please enter your email."); return }
        guard !password.isEmpty else { showAlert(title: "Missing Password", message: "Please enter your password."); return }
        guard !confirm.isEmpty else { showAlert(title: "Missing Confirm Password", message: "Please confirm your password."); return }
        guard password == confirm else { showAlert(title: "Password Mismatch", message: "Passwords do not match."); return }

        setLoading(true)

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }

            if let error = error as NSError? {
                let code = AuthErrorCode(rawValue: error.code)
                switch code {
                case .userNotFound:
                    self.showAlert(title: "No Admin Account", message: "You don't have an admin account.")
                case .wrongPassword:
                    self.showAlert(title: "Login Failed", message: "Wrong password.")
                case .invalidEmail:
                    self.showAlert(title: "Login Failed", message: "Invalid email format.")
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

            if self.isRememberChecked {
                UserDefaults.standard.set(uid, forKey: "admin_uid")
            } else {
                UserDefaults.standard.removeObject(forKey: "admin_uid")
            }

            self.db.collection("users").document(uid).getDocument { [weak self] snap, err in
                guard let self else { return }

                if let err = err {
                    self.showAlert(title: "Firestore Error", message: err.localizedDescription)
                    try? Auth.auth().signOut()
                    self.setLoading(false)
                    return
                }

                guard let data = snap?.data() else {
                    self.showAlert(title: "No Profile", message: "Admin profile is not found in Firestore.")
                    try? Auth.auth().signOut()
                    self.setLoading(false)
                    return
                }

                let role = (data["role"] as? String ?? "").lowercased()
                if role != "admin" {
                    self.showAlert(title: "Wrong Account", message: "This account is not an Admin account.")
                    try? Auth.auth().signOut()
                    self.setLoading(false)
                    return
                }

                // ✅ فقط هنا نسمح بالانتقال
                self.allowAdminDashSegue = true
                self.setLoading(false)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toAdminDash", sender: nil)
                    self.allowAdminDashSegue = false
                }
            }
        }
    }
}
