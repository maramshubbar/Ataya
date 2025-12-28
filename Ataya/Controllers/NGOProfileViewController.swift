//
//  NGOProfileViewController.swift
//  Ataya
//
//  Created by BP-36-224-14 on 28/12/2025.
//

import UIKit

class NGOProfileViewController: UIViewController {
    
    
    @IBOutlet weak var ngoCard: UIView!
    @IBOutlet weak var ngoProfile: UIImageView!
    @IBOutlet weak var ngoName: UILabel!
    @IBOutlet weak var ratingValue: UILabel!
    @IBOutlet weak var verifyIcon: UIImageView!
    @IBOutlet weak var categoryValue: UILabel!
    @IBOutlet weak var locationValue: UILabel!
    @IBOutlet weak var emailValue: UILabel!
    @IBOutlet weak var impactLabel: UILabel!
    @IBOutlet weak var missionValue: UITextView!
    @IBOutlet weak var activitesValue: UITextView!
    
    //Data Model
    var ngo: NGO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
          
    }
    
    private func configureUI() {
        guard let ngo = ngo else { return }
        
        ngoName.text = ngo.name
        categoryValue.text = ngo.category
        locationValue.text = ngo.location
        emailValue.text = ngo.email
        ratingValue.text = "⭐️ \(ngo.rating)"
        impactLabel.text = "Impact: \(ngo.impact)"
        missionValue.text = ngo.mission
        activitesValue.text = ngo.activities.joined(separator: "\n• ")
    }

}
