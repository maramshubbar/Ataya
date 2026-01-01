//
//  AdminProfileViewController.swift
//  Ataya
//
//  Created by Maram on 24/11/2025.
//

import UIKit

class AdminProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        nameLabel.text = "Abdulla Yusuf"
            super.viewDidLoad()
            //navigationItem.backButtonDisplayMode = .minimal
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        aboutMeButton.layer.cornerRadius = 8
        aboutMeButton.layer.borderWidth = 1
        aboutMeButton.layer.borderColor = UIColor.systemGray4.cgColor
        aboutMeButton.layer.masksToBounds = false
        
        notificationButton.layer.cornerRadius = 8
        notificationButton.layer.borderWidth = 1
        notificationButton.layer.borderColor = UIColor.systemGray4.cgColor
        notificationButton.layer.masksToBounds = false
        
        
        logoutButton.layer.cornerRadius = 8
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.borderColor = UIColor.systemGray4.cgColor
        logoutButton.layer.masksToBounds = false
        
        makeProfileImageCircular()
    }
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    @IBOutlet weak var roleLabel: UILabel!
    
    @IBOutlet weak var aboutMeButton: UIButton!
    
    @IBOutlet weak var notificationButton: UIButton!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    
    
    func makeProfileImageCircular() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }
    
    
    
    @IBAction func aboutMeButton(_ sender: UIButton) {
    }
    
    
   
    @IBAction func aboutMeButtonTapped(_ sender: Any) {
        /*if let aboutVC = storyboard?.instantiateViewController(withIdentifier: "AboutMeViewController") as? AboutMeViewController {
            aboutVC.modalPresentationStyle = .fullScreen
            present(aboutVC, animated: true)
        }*/
        
        
    }

        
    
}



