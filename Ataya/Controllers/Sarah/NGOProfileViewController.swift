//
//  NGOProfileViewController.swift
//  Ataya
//
//  Created by BP-19-130-11 on 15/12/2025.
//

import UIKit

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
    
    var ngo = NGO(
        name: "Hope Foundation",
        type: "Ngo",
        rating: "5.0",
        email: "contact@hopefoundation.org",
        phone: "+973 9876 5432",
        mission: "Our mission is to empower communities through education and healthcare. I see exactly what’s happening, Sarah. Right now your About Me screen always resets to the dummy data inI see exactly what’s happening, Sarah. Right now your About Me screen always resets to the dummy data inI see exactly what’s happening, Sarah. Right now your About Me screen always resets to the dummy data inI see exactly what’s happening, Sarah. Right now your About Me screen always resets to the dummy data in" )
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load saved preference
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        darkModeSwitch.isOn = isDarkMode
        
        // Show summary data
        ngoName.text = ngo.name
        ngoType.text = ngo.type
        ratingValue.text = ngo.rating
        profileView.image = UIImage(named: "donor_Image")
        
        profileView.layer.cornerRadius = profileView.frame.width / 2
        profileView.clipsToBounds = true
        ratingView.layer.cornerRadius = 8
    }

    func didUpdateNGOInfo(name: String, email: String, phone: String, mission: String) {
        // Update model and UI
        ngo.name = name
        ngo.email = email
        ngo.phone = phone
        ngo.mission = mission
        ngoName.text = ngo.name
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

        
    }

