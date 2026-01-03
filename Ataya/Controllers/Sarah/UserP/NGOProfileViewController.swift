//
//  NGOProfileViewController.swift
//  Ataya
//
//  Created by BP-19-130-11 on 15/12/2025.
//

import UIKit
import FirebaseAuth

class NGOProfileViewController: UIViewController, NGOAboutMeDelegate {

    @IBOutlet weak var profileView: UIImageView!
    
    @IBOutlet weak var ngoName: UILabel!
    
    @IBOutlet weak var ngoType: UILabel!
    
    @IBOutlet weak var ratingValue: UILabel!
    
    @IBOutlet weak var ratingView: UIView!
    
    @IBOutlet weak var aboutMeButton: UIButton!
    
    @IBOutlet weak var notificationButton: UIButton!
    
    @IBOutlet weak var modeLabel: UILabel!
    
    @IBOutlet weak var themeToggleImage: UIImageView!
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    @IBOutlet weak var helpSupportButton: UIButton!
    
    @IBOutlet weak var savePhotoButton: UIBarButtonItem!
    
    @IBOutlet weak var changePhotoButton: UIButton!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    
    var ngo = Ngo(
        name: "Hoppal",
        type: "Ngo",
        rating: "5.0",
        email: "hoppal@gmail.com",
        phone: "+973 9876 5432",
        mission: "Our mission is to uplift vulnerable families by providing access to food, shelter, and education. We believe that every individual deserves dignity and opportunity, and we work hand in hand with local communities to create sustainable solutions that address immediate needs while building long‑term resilience." )
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ngoName.text = ngo.name
        ngoType.text = ngo.type
        ratingValue.text = ngo.rating
        
        // Show dummy image or saved profile image
        if let image = ngo.profileImage {
            profileView.image = image
        } else {
            profileView.image = UIImage(named: "Image6")
        }
        profileView.layer.cornerRadius = profileView.frame.width / 2
        profileView.clipsToBounds = true
        ratingView.layer.cornerRadius = 8
        changePhotoButton.isHidden = true
        savePhotoButton.isHidden = true
    }

    func didUpdateNGOInfo(name: String, email: String, phone: String, mission: String) {
        // Update model and UI
        ngo.name = name
        ngo.email = email
        ngo.phone = phone
        ngo.mission = mission
        ngoName.text = ngo.name
    }
    
    @IBAction func ratingTapped(_ sender: UIButton) {
       
        // Use the correct storyboard name
           let storyboard = UIStoryboard(name: "MyReviews", bundle: nil) // ← your storyboard
           guard let reviewsVC = storyboard.instantiateViewController(
               withIdentifier: "DonorReview" 
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
    
    //prepare segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? NGOAboutMeViewController {
            destination.delegate = self
            destination.ngo = ngo
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ratingValue.text = ngo.rating
    }

 
    
        
    @IBAction func editProfileTapped(_ sender: UIBarButtonItem) {
        changePhotoButton.isHidden = false
        savePhotoButton.isHidden = false
    }
    
    @IBAction func changePhotoTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func savePhotoTapped(_ sender: UIBarButtonItem) {
        // Hide buttons again
        changePhotoButton.isHidden = true
        savePhotoButton.isHidden = true
        
        // Persist the image in your NGO model
        ngo.profileImage = profileView.image
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
                let alert = UIAlertController(
                    title: "Error",
                    message: "Couldn't logout. Try again.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }

            goToUserSelectionRoot()
        }

        private func goToUserSelectionRoot() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "UserSelectionViewController")

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
extension NGOProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            profileView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
}


