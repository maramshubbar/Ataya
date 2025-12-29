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
    @IBOutlet weak var activitesValues: UITextView!
    @IBOutlet weak var missionValue: UITextView!
    //Data Model
    var ngo: NGO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let ngo = ngo {
            ngoName.text = ngo.name
            categoryValue.text = ngo.category
            emailValue.text = ngo.email
            locationValue.text = ngo.location
            ratingValue.text = "\(ngo.rating)"
            missionValue.text = ngo.mission
            ngoProfile.image = UIImage(named: ngo.imageName)
            activitesValues.text = ngo.activities.map { "• " + $0 }.joined(separator: "\n\n")
            impactLabel.text = "\(ngo.impact) "

        }

        //styling + element changes
        ngoProfile.layer.cornerRadius = ngoProfile.frame.size.width / 2
        ngoProfile.clipsToBounds = true
        ngoProfile.layer.borderWidth = 1
        ngoProfile.layer.borderColor = UIColor.systemGray4.cgColor

        ngoCard.layer.cornerRadius = 12
        ngoCard.layer.borderWidth = 1
        ngoCard.layer.borderColor = UIColor.systemGray4.cgColor
        ngoCard.layer.masksToBounds = true

        missionValue.isEditable = false
        missionValue.isScrollEnabled = true
        missionValue.font = UIFont.systemFont(ofSize: 16)

    
        activitesValues.isEditable = false
        activitesValues.isScrollEnabled = false
        
        //to make the name expand and the badge to stay next to the name
        ngoName.setContentHuggingPriority(.defaultLow, for: .horizontal)
        ngoName.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        verifyIcon.setContentHuggingPriority(.required, for: .horizontal)
        verifyIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
        

    }
    
}
