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
 
    private var isConfirmed = false {
            didSet { updateUI() }
        }

        private let disabledGray  = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1) // #E8E8E8
        private let enabledYellow = UIColor(red: 255/255, green: 216/255, blue:  63/255, alpha: 1) // #FFD83F

        override func viewDidLoad() {
            super.viewDidLoad()
            configureUI()
            isConfirmed = false
        }

        private func configureUI() {
            // ✅ prevent iOS 15+ configuration overlays
            if #available(iOS 15.0, *) {
                checkboxButton.configuration = nil
                nextButton.configuration = nil
            }

            // ✅ Checkbox (state-based)
            checkboxButton.setImage(UIImage(systemName: "square"), for: .normal)
            checkboxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
            checkboxButton.tintColor = .lightGray

            // ✅ Next button (no image inside)
            nextButton.setImage(nil, for: .normal)
            nextButton.setImage(nil, for: .disabled)
            nextButton.setImage(nil, for: .selected)

            nextButton.setTitle("Next", for: .normal)
            nextButton.setTitleColor(.white, for: .normal)
            nextButton.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .disabled) // optional polish
            nextButton.titleLabel?.backgroundColor = .clear
            nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)

            nextButton.layer.cornerRadius = 14
            nextButton.clipsToBounds = true

            // Apply initial state
            updateUI()
        }

        private func updateUI() {
            checkboxButton.isSelected = isConfirmed
            checkboxButton.tintColor  = isConfirmed ? enabledYellow : .lightGray

            nextButton.isEnabled = isConfirmed
            nextButton.backgroundColor = isConfirmed ? enabledYellow : disabledGray
        }


        // MARK: - Actions



        @IBAction func checkboxTapped(_ sender: UIButton) {
            isConfirmed.toggle()
        }

        @IBAction func nextTapped(_ sender: UIButton) {
            guard isConfirmed else { return }
            
        }
    }

