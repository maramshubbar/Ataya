//
//  AdminProfileViewController.swift
//  Ataya
//
//  Created by Maram on 24/11/2025.
//

//
//  AdminProfileViewController.swift
//  Ataya
//
//  Created by Maram on 24/11/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class AdminProfileViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var roleLabel: UILabel!

    @IBOutlet weak var aboutMeButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!

    // MARK: - Firestore
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        // ✅ title فوق
        self.title = "Admin Profile"

        // placeholders
        nameLabel.text = "—"
        roleLabel.text = "—"

        loadProfileFromFirestore()
    }

    deinit {
        listener?.remove()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        styleBoxButton(aboutMeButton)
        styleBoxButton(notificationButton)
        styleBoxButton(logoutButton)

        makeProfileImageCircular()
    }

    // MARK: - UI Styling
    private func styleBoxButton(_ button: UIButton) {
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.layer.masksToBounds = false
    }

    private func makeProfileImageCircular() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }

    // MARK: - Firestore Load
    private func loadProfileFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No logged-in user")
            return
        }

        listener?.remove()
        listener = db.collection("users").document(uid).addSnapshotListener { [weak self] snap, error in
            guard let self else { return }

            if let error = error {
                print("❌ Profile load error:", error.localizedDescription)
                return
            }

            guard let data = snap?.data() else {
                print("⚠️ No user document in /users/\(uid)")
                return
            }

            let fullName = (data["fullName"] as? String)
                ?? (data["name"] as? String)
                ?? "—"

            let role = (data["role"] as? String) ?? "admin"

            let photoUrl = (data["photoUrl"] as? String)
                ?? (data["profileImageUrl"] as? String)
                ?? ""

            DispatchQueue.main.async {
                // ✅ هذا اللي تبينه: الاسم اللي bold
                self.nameLabel.text = fullName
                self.roleLabel.text = role.capitalized

                // ✅ إذا عندج ImageLoader.swift فكّي التعليق
                // ImageLoader.shared.setImage(
                //     on: self.profileImageView,
                //     from: photoUrl,
                //     placeholder: UIImage(named: "avatarPlaceholder")
                // )
            }
        }
    }

    // MARK: - Actions

    @IBAction func aboutMeButtonTapped(_ sender: Any) {
        // ✅ افتح AboutMe
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AboutMeViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func logoutButtonTapped(_ sender: Any) {

        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })

        present(alert, animated: true)
    }

    private func performLogout() {
        listener?.remove()
        listener = nil

        do {
            try Auth.auth().signOut()
        } catch {
            let a = UIAlertController(
                title: "Error",
                message: "Couldn't logout. Try again.",
                preferredStyle: .alert
            )
            a.addAction(UIAlertAction(title: "OK", style: .default))
            present(a, animated: true)
            return
        }

        goToAdminLoginRoot()
    }

    private func goToAdminLoginRoot() {
        let sb = UIStoryboard(name: "Main", bundle: nil)

        // ✅ Storyboard ID حق صفحة اللوجن
        let loginVC = sb.instantiateViewController(withIdentifier: "AdminLoginViewController")

        // ✅ يخليه Root عشان ما يرجع Back
        let nav = UINavigationController(rootViewController: loginVC)
        nav.navigationBar.isHidden = false

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        } else {
            // fallback
            UIApplication.shared.windows.first?.rootViewController = nav
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
}
