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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Checkbox icons (system)
        checkboxButton.setImage(UIImage(systemName: "square"), for: .normal)
        checkboxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        checkboxButton.tintColor = UIColor(white: 0.70, alpha: 1.0)

        // Remove any image from Next button (prevents weird box)
        nextButton.setImage(nil, for: .normal)
        nextButton.setImage(nil, for: .disabled)
        nextButton.setImage(nil, for: .highlighted)
        nextButton.setImage(nil, for: .selected)

        nextButton.layer.cornerRadius = 12
        nextButton.clipsToBounds = true

        // Start unchecked
        isConfirmed = false
        applyState()
    }

    private func applyState() {
        // ✅ THIS line is what makes the icon change
        checkboxButton.isSelected = isConfirmed

        nextButton.isEnabled = isConfirmed

        if isConfirmed {
            nextButton.backgroundColor = UIColor(hex: "#FFD83F")
            nextButton.setTitleColor(.white, for: .normal)
            nextButton.alpha = 1.0
        } else {
            nextButton.backgroundColor = UIColor(hex: "#E8E8E8") // exact gray
            nextButton.setTitleColor(.white, for: .normal)
            nextButton.setTitleColor(.white, for: .disabled)
            nextButton.alpha = 1.0
        }
    }

    @IBAction func checkboxTapped(_ sender: UIButton) {
        isConfirmed.toggle()
        applyState()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        guard isConfirmed else { return }
        performSegue(withIdentifier: "toNextPage", sender: nil)
    }
}
