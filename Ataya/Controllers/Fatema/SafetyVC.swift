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

        private let disabledGray  = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1) // #E8E8E8
        private let enabledYellow = UIColor(red: 255/255, green: 216/255, blue:  63/255, alpha: 1) // #FFD83F

        override func viewDidLoad() {
            super.viewDidLoad()

            setupCheckbox()
            setupNextButton()

            // start unchecked
            isConfirmed = false
            updateUI()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            // whenever you come back, reset
            isConfirmed = false
            updateUI()
        }

    private func setupCheckbox() {
            // remove any storyboard title
            checkboxButton.setTitle("", for: .normal)

            // images controlled by code
            checkboxButton.setImage(UIImage(systemName: "square"), for: .normal)
            checkboxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)

            checkboxButton.tintColor = UIColor(white: 0.75, alpha: 1.0)
            checkboxButton.isSelected = false
        }

        private func setupNextButton() {
            // IMPORTANT: prevent iOS 15+ config styling from changing disabled look
            if #available(iOS 15.0, *) {
                nextButton.configuration = nil
            }

            // ensure no image inside Next button
            nextButton.setImage(nil, for: .normal)
            nextButton.setImage(nil, for: .disabled)
            nextButton.setImage(nil, for: .highlighted)
            nextButton.setImage(nil, for: .selected)

            nextButton.layer.cornerRadius = 12
            nextButton.clipsToBounds = true

            nextButton.setTitle("Next", for: .normal)
            nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        }

        // MARK: - UI

        private func updateUI() {
            checkboxButton.isSelected = isConfirmed
            nextButton.isEnabled = isConfirmed

            if isConfirmed {
                // ✅ ENABLED
                nextButton.backgroundColor = enabledYellow
                nextButton.setTitleColor(.black, for: .normal)
                nextButton.setTitleColor(.black, for: .disabled) // extra safety
                nextButton.alpha = 1.0
            } else {
                // ❌ DISABLED (your exact look)
                nextButton.backgroundColor = disabledGray
                nextButton.setTitleColor(.white, for: .disabled)
                nextButton.setTitleColor(.white, for: .normal)
                nextButton.alpha = 1.0
            }
        }

        // MARK: - Actions



        @IBAction func checkboxTapped(_ sender: UIButton) {
            isConfirmed.toggle()
            updateUI()
        }

        @IBAction func nextTapped(_ sender: UIButton) {
            guard isConfirmed else { return }
            let vc = storyboard?.instantiateViewController(withIdentifier: "EnterDetailsViewController") as! SubmitVC
            navigationController?.pushViewController(vc, animated: true)
        }
    }

