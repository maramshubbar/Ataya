//
//  DonorProfileViewController.swift
//  Ataya
//
//  Created by BP-19-130-11 on 15/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DonorProfileViewController: UIViewController {
    
    @IBOutlet weak var imageProfile: UIImageView!
    
    @IBOutlet weak var donorName: UILabel!
    
    @IBOutlet weak var donorType: UILabel!
    
    @IBOutlet weak var ratingValue: UILabel!
    
    @IBOutlet weak var raitngView: UIView!
    
    @IBOutlet weak var Aboutme: UIButton!
    
    @IBOutlet weak var Notification: UIButton!
    
    @IBOutlet weak var RecurringHistory: UIButton!
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    @IBOutlet weak var HelpSupport: UIButton!
    
    @IBOutlet weak var modeLabel: UILabel!
    
    @IBOutlet weak var themeToggleImage: UIImageView!
    
    @IBOutlet weak var Logout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load saved preference
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        darkModeSwitch.isOn = isDarkMode
        
        // Dummy profile data
        donorName.text = "Ameena"
        ratingValue.text = "4"
        imageProfile.image = UIImage(named: "dononrProfile") // Add this image to Assets
        
        //styling
        imageProfile.layer.cornerRadius = imageProfile.frame.width / 2
        imageProfile.clipsToBounds = true
        raitngView.layer.cornerRadius = 8
    }
    
    @IBAction func darkModeToggled(_ sender: UISwitch) {
        let isDarkMode = sender.isOn
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkModeEnabled")

            //appplies to the entire app
            if let window = view.window {
                window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            }

            modeLabel.text = isDarkMode ? "Light Mode" : "Dark Mode"
            themeToggleImage.image = UIImage(
                systemName: isDarkMode ? "sun.max.fill" : "moon.fill"
            )
    }
    
    @IBAction func ratingTapped(_ sender: Any) {
        openMyReviews()
    }
    
    private func openMyReviews() {
        // Use the correct storyboard name
           let storyboard = UIStoryboard(name: "MyReviews", bundle: nil) // ← your storyboard
           guard let reviewsVC = storyboard.instantiateViewController(
               withIdentifier: "DonorReview" // ← Storyboard ID
           ) as? MyReviewsViewController else {
           
               return
           }
        
        let nav = UINavigationController(rootViewController: reviewsVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        self.navigationController?.pushViewController(reviewsVC, animated: true)
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

        goToUserSelectionRoot()
    }

    private func goToUserSelectionRoot() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "UserSelectionViewController")

        let nav = UINavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false)

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        } else {
            present(nav, animated: true)
        }
    }
    
}


