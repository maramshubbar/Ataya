//
//  ReviewPredictionViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 20/12/2025.
//

import UIKit

class ReviewPredictionViewController: UIViewController {
    @IBOutlet weak var editManuallyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleButton()
    }
    
    private func styleButton() {
        let borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        
        if #available(iOS 15.0, *) {
            var config = editManuallyButton.configuration ?? .filled()
            
            if let currentBG = editManuallyButton.backgroundColor {
                config.baseBackgroundColor = currentBG
            }
            config.baseForegroundColor = editManuallyButton.titleColor(for: .normal) ?? .black
            
            config.background.cornerRadius = 14
            config.background.strokeWidth = 1
            config.background.strokeColor = borderColor
            
            editManuallyButton.configuration = config
            
        } else {
            editManuallyButton.layer.cornerRadius = 14
            editManuallyButton.layer.borderWidth = 1
            editManuallyButton.layer.borderColor = borderColor.cgColor
            editManuallyButton.clipsToBounds = true
        }
    }
}
