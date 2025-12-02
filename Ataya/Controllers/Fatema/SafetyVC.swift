//
//  SafetyVC.swift
//  Ataya
//
//  Created by Fatema Maitham on 29/11/2025.
//

import UIKit

class SafetyVC: UIViewController {
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start with unchecked state
        checkboxButton.isSelected = false
        checkboxButton.setImage(UIImage(named: "checkbox_unchecked"), for: .normal)
        checkboxButton.setImage(UIImage(named: "checkbox_checked"), for: .selected)
        
        // Configure button disabled at start
        configureNextButton(isEnabled: false)
    }
    
    @IBAction func checkboxTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        // Update Next button based on checkbox state
        configureNextButton(isEnabled: sender.isSelected)
    }
    
    private func configureNextButton(isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
        
        if isEnabled {
            // Checked → Yellow button
            nextButton.backgroundColor = UIColor(hex: "#FFD83F")
            nextButton.setTitleColor(.white, for: .normal)
        } else {
            // Unchecked → Light grey button
            nextButton.backgroundColor = UIColor(hex: "#E8E8E8")
            nextButton.setTitleColor(.white, for: .disabled) // ALWAYS white text
        }
    }
    
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

