//
//  SafetyVC.swift
//  Ataya
//
//  Created by Fatema Maitham on 29/11/2025.
//

import UIKit

final class SafetyVC: UIViewController {
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    private var isConfirmed = false

        private let disabledGray = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1) // #E8E8E8
        private let enabledYellow = UIColor(red: 255/255, green: 216/255, blue: 63/255, alpha: 1) // #FFD83F

        override func viewDidLoad() {
            super.viewDidLoad()
            configureNextButton(isEnabled: false)
            setupCheckbox()
            setupNextButton()
            updateUI()
        }

        private func setupCheckbox() {
            // iOS-style checkbox (gray)
            checkboxButton.setImage(UIImage(systemName: "square"), for: .normal)
            checkboxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
            checkboxButton.tintColor = UIColor(white: 0.70, alpha: 1.0) // gray like your last pic

            // IMPORTANT: start unchecked
            checkboxButton.isSelected = false
            isConfirmed = false
        }

        private func setupNextButton() {
            // Remove any image that causes the weird square inside the button
            nextButton.setImage(nil, for: .normal)
            nextButton.setImage(nil, for: .disabled)
            nextButton.setImage(nil, for: .highlighted)
            nextButton.setImage(nil, for: .selected)

            nextButton.layer.cornerRadius = 12
            nextButton.clipsToBounds = true
            nextButton.setTitle("Next", for: .normal)

            // Ensure title color stays what we want
            nextButton.setTitleColor(.black, for: .normal)
            nextButton.setTitleColor(.white, for: .disabled)
        }

    private func updateUI() {
        checkboxButton.isSelected = isConfirmed
        nextButton.isEnabled = isConfirmed

        if isConfirmed {
            // ✅ CHECKED → Yellow, enabled
            nextButton.backgroundColor = UIColor(hex: "#FFD83F")
            nextButton.setTitleColor(.white, for: .normal)
            nextButton.alpha = 1.0
        } else {
            // ❌ UNCHECKED → EXACT gray #E8E8E8
            nextButton.backgroundColor = UIColor(hex: "#E8E8E8")
            nextButton.setTitleColor(.white, for: .normal)
            nextButton.setTitleColor(.white, for: .disabled)
            nextButton.alpha = 1.0   // ❗ keep 1 so color stays true
        }
    }

    private func configureNextButton(isEnabled: Bool) {
        nextButton.isEnabled = isEnabled

        if isEnabled {
            // ✅ checked
            nextButton.backgroundColor = UIColor(hex: "#FFD83F")
            nextButton.setTitleColor(.white, for: .normal)
        } else {
            // ❌ unchecked  ← HERE IS WHERE YOU PUT IT
            nextButton.backgroundColor = UIColor(hex: "#E8E8E8")
            nextButton.setTitleColor(.white, for: .disabled)
            nextButton.setTitleColor(.white, for: .normal) // extra safety
        }
    }

    

        @IBAction func checkboxTapped(_ sender: UIButton) {
            isConfirmed.toggle()
            updateUI()
        }

        @IBAction func nextTapped(_ sender: UIButton) {
            guard isConfirmed else { return }

        }
    }

