//
//  MyAddressListViewController.swift
//  Ataya
//
//  Created by BP-36-224-16 on 20/12/2025.
//

import UIKit

class MyAddressListViewController: UIViewController {

    
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var myAddressButton: UIButton!
    @IBOutlet weak var ngoButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    private let store = AddressRuntimeStore.shared

    private enum Choice {
            case myAddress
            case ngo
        }

        private var selectedChoice: Choice?

        // Colors
        private let grayBorder = UIColor(hex: "#999999")
        private let selectedBorder = UIColor(hex: "#FEC400")
        private let selectedBG = UIColor(hex: "#FFFBE7")

        override func viewDidLoad() {
            super.viewDidLoad()

            // Style both buttons
            setupOptionButton(myAddressButton)
            setupOptionButton(ngoButton)

            // ✅ SURE: make them clickable from code (even if storyboard actions not connected)
            myAddressButton.addTarget(self, action: #selector(myAddressTapped), for: .touchUpInside)
            ngoButton.addTarget(self, action: #selector(ngoTapped), for: .touchUpInside)

            // Start unselected
            applyDefaultStyle(myAddressButton)
            applyDefaultStyle(ngoButton)

            // Next disabled until user selects one
            setNextEnabled(false)
        }

        // MARK: - Button Setup

        private func setupOptionButton(_ button: UIButton) {
            // Text
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            button.contentHorizontalAlignment = .center

            // Shape
            button.layer.cornerRadius = 4
            button.clipsToBounds = true

            // Default style: white + gray border #999999
            button.backgroundColor = .white
            button.layer.borderWidth = 1
            button.layer.borderColor = grayBorder.cgColor

            // Hover/press effect
            button.addTarget(self, action: #selector(pressDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(pressUp(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])
        }

        // MARK: - Selection

        @objc private func myAddressTapped() {
            select(.myAddress)
        }

        @objc private func ngoTapped() {
            select(.ngo)
        }

        private func select(_ choice: Choice) {
            selectedChoice = choice

            // reset both
            applyDefaultStyle(myAddressButton)
            applyDefaultStyle(ngoButton)

            // select one
            switch choice {
            case .myAddress:
                applySelectedStyle(myAddressButton)
            case .ngo:
                applySelectedStyle(ngoButton)
            }

            setNextEnabled(true)
        }

        private func applyDefaultStyle(_ button: UIButton) {
            button.backgroundColor = .white
            button.layer.borderWidth = 1
            button.layer.borderColor = grayBorder.cgColor
        }

        private func applySelectedStyle(_ button: UIButton) {
            button.backgroundColor = selectedBG
            button.layer.borderWidth = 2
            button.layer.borderColor = selectedBorder.cgColor
        }

        // MARK: - Next button

        private func setNextEnabled(_ enabled: Bool) {
            nextButton.isEnabled = enabled
            nextButton.alpha = enabled ? 1.0 : 0.5
        }
    
    private func presentThankYouPopup() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let popup = sb.instantiateViewController(withIdentifier: "PopupConfirmPickupViewController") as? PopupConfirmPickupViewController else {
            showAlert(title: "Storyboard Error", message: "Set Popup Storyboard ID = PopupConfirmPickupViewController")
            return
        }
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        present(popup, animated: true)
    }


        // Connect this in storyboard if you want, OR addTarget like the others.
    @IBAction func nextTapped(_ sender: UIButton) {
        guard let selectedChoice else {
            showAlert(title: "Choose an option", message: "Please select My Address or NGO Drop-off Facility.")
            return
        }

        guard store.confirmedAddress != nil else {
            showAlert(title: "Confirm Address First", message: "Please choose an address and press Confirm first.")
            return
        }

        switch selectedChoice {
        case .ngo:
            presentThankYouPopup()
        case .myAddress:
            showAlert(title: "Done", message: "Address confirmed. Continue flow.")
        }
    }


        // MARK: - Hover / Press

        @objc private func pressDown(_ sender: UIButton) {
            UIView.animate(withDuration: 0.10) {
                sender.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                sender.alpha = 0.92
            }
        }

        @objc private func pressUp(_ sender: UIButton) {
            UIView.animate(withDuration: 0.10) {
                sender.transform = .identity
                sender.alpha = 1.0
            }
        }

        // MARK: - Alert

        private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // MARK: - Hex helper

    private extension UIColor {
        convenience init(hex: String) {
            var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            if hexString.hasPrefix("#") { hexString.removeFirst() }

            var rgb: UInt64 = 0
            Scanner(string: hexString).scanHexInt64(&rgb)

            let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
            let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
            let b = CGFloat(rgb & 0x0000FF) / 255

            self.init(red: r, green: g, blue: b, alpha: 1)
        }
    }
