//
//  DonorProfileViewController.swift
//  Ataya
//
//  Created by BP-19-130-11 on 15/12/2025.
//

import UIKit

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
        donorName.text = "Zahra Ahmed"
        ratingValue.text = "4.7"
        imageProfile.image = UIImage(named: "donor_Image") // Add this image to Assets
        
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

   
 
    @IBAction func testingPopupTapped(_ sender: UIButton) {
        let vc = FeedbackPopupViewController()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true)
    }
    
}


