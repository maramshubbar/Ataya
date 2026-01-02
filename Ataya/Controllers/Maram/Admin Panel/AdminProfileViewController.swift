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

    // ✅ قفل يمنع تكرار فتح AboutMe
    private var isNavigating = false

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Admin Profile"

        nameLabel.text = "—"
        roleLabel.text = "Admin"   // ✅ ثابت

        loadAdminProfile()
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

    // ✅ يمنع أي Segue بالغلط من زر About me
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let btn = sender as? UIButton, btn === aboutMeButton {
            return false
        }
        return true
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

    // MARK: - Load Profile (admins -> fallback users)
    private func loadAdminProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No logged-in user")
            return
        }

        // شيل أي listener قديم
        listener?.remove()
        listener = nil

        // ✅ جرّبي أولًا admins/{uid}
        db.collection("admins").document(uid).getDocument { [weak self] doc, _ in
            guard let self else { return }

            if let doc, doc.exists {
                self.listenProfile(from: "admins", uid: uid)
            } else {
                // ✅ إذا ما موجود، روحي users/{uid}
                self.listenProfile(from: "users", uid: uid)
            }
        }
    }

    private func listenProfile(from collection: String, uid: String) {
        listener?.remove()
        listener = db.collection(collection).document(uid).addSnapshotListener { [weak self] snap, error in
            guard let self else { return }

            if let error = error {
                print("❌ Profile load error:", error.localizedDescription)
                return
            }

            guard let data = snap?.data() else {
                print("⚠️ No user doc at /\(collection)/\(uid)")
                return
            }

            let fetchedName =
                (data["fullName"] as? String)
                ?? (data["fullname"] as? String)
                ?? (data["displayName"] as? String)
                ?? (data["username"] as? String)
                ?? (data["name"] as? String)
                ?? Auth.auth().currentUser?.displayName
                ?? "—"

            let finalName: String = {
                let trimmed = fetchedName.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.lowercased() == "admin" {
                    let alt =
                        (data["realName"] as? String)
                        ?? (data["full_name"] as? String)
                        ?? trimmed
                    return alt
                }
                return trimmed.isEmpty ? "—" : trimmed
            }()

            let photoUrl =
                (data["photoUrl"] as? String)
                ?? (data["profileImageUrl"] as? String)
                ?? ""

            DispatchQueue.main.async {
                self.nameLabel.text = finalName
                self.roleLabel.text = "Admin"

                // لو عندج ImageLoader (اختياري)
                // ImageLoader.shared.setImage(
                //     on: self.profileImageView,
                //     from: photoUrl,
                //     placeholder: UIImage(named: "avatarPlaceholder")
                // )
            }
        }
    }

    // MARK: - Actions

    @IBAction func aboutMeButtonTapped(_ sender: UIButton) {
        guard !isNavigating else { return }
        isNavigating = true
        sender.isEnabled = false

        if navigationController?.topViewController is AboutMeViewController {
            unlockNav(sender)
            return
        }

        let sb = UIStoryboard(name: "Admin", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AboutMeViewController")
        navigationController?.pushViewController(vc, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.unlockNav(sender)
        }
    }

    private func unlockNav(_ sender: UIButton) {
        isNavigating = false
        sender.isEnabled = true
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

        // ✅✅✅ هنا التعديل: بعد logout يروح UserSelection
        goToUserSelectionRoot()
    }

    // ✅✅✅ NEW: UserSelection root
    private func goToUserSelectionRoot() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "UserSelectionViewController")

        let nav = UINavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false) // تقدرين تخليها false إذا تبين nav

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        } else {
            present(nav, animated: true)
        }
    }
}
