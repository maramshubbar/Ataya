//
//  DonorProfileViewController.swift
//  Ataya
//
//  Created by BP-19-130-11 on 15/12/2025.
//

import UIKit

class DonorProfileViewController: UIViewController {
    
    @IBOutlet weak var Aboutme: UIView!
    
    @IBOutlet weak var Notification: UIButton!
    
    @IBOutlet weak var RecurringHistory: UIButton!
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    @IBOutlet weak var HelpSupport: UIButton!
    
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var Logout: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        darkModeSwitch.isOn = isDarkMode
        overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        modeLabel.text = isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode"
    }
    
    
    
    
    @IBAction func darkModeToggled(_ sender: UISwitch) {
        let isDarkMode = sender.isOn
        overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkModeEnabled")

        // Update label to show the *next* mode
        modeLabel.text = isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode"
    }

    
    
    
    
}


