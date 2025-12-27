//
//  ActionPopupViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 27/12/2025.
//

import UIKit

class ActionPopupViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var viewReportsButton: UIButton!
    
    var popupTitle: String?
    var popupDescription: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = popupTitle
        descriptionLabel.text = popupDescription
        
        
    }
    
    
    @IBAction func viewReportsTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
