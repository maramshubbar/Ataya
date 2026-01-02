//
//  AboutMeViewController.swift
//  Ataya
//
//  Created by Maram on 26/11/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class AboutMeViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!

    // MARK: - Firestore
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // MARK: - UI
    private let borderGray = UIColor(red: 134/255, green: 136/255, blue: 137/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()

        // ✅ نفس شكل الصورة (Read-only)
        fullNameTextField.isUserInteractionEnabled = false
        emailTextField.isUserInteractionEnabled = false
        phoneTextField.isUserInteractionEnabled = false

        // ✅ لو تبين لون أخف للقراءة
        fullNameTextField.textColor = .darkGray
        emailTextField.textColor = .darkGray
        phoneTextField.textColor = .darkGray

        // ✅ ابدأ تحميل البيانات من Firestore
        startListeningProfile()
    }

    deinit {
        listener?.remove()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        styleTextField(fullNameTextField)
        styleTextField(emailTextField)
        styleTextField(phoneTextField)
    }

    private func styleTextField(_ textField: UITextField) {
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = borderGray.cgColor
        textField.clipsToBounds = true

        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        textField.leftView = padding
        textField.leftViewMode = .always
    }

    // MARK: - Firestore Load
    private func startListeningProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ AboutMe: No logged-in user")
            return
        }

        listener?.remove()
        listener = db.collection("users").document(uid).addSnapshotListener { [weak self] snap, error in
            guard let self else { return }

            if let error = error {
                print("❌ AboutMe profile error:", error.localizedDescription)
                return
            }

            guard let data = snap?.data() else {
                print("⚠️ AboutMe: No user doc at /users/\(uid)")
                return
            }

            let fullName =
                (data["fullName"] as? String)
                ?? (data["name"] as? String)
                ?? "—"

            let email =
                (data["email"] as? String)
                ?? Auth.auth().currentUser?.email
                ?? "—"

            let phone =
                (data["phone"] as? String)
                ?? (data["phoneNumber"] as? String)
                ?? "—"

            DispatchQueue.main.async {
                self.fullNameTextField.text = fullName
                self.emailTextField.text = email
                self.phoneTextField.text = phone
            }
        }
    }
}
