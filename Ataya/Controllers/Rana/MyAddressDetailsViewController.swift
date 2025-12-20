//
//  MyAddressDetailsViewController.swift
//  Ataya
//
//  Created by BP-36-224-16 on 20/12/2025.
//

import UIKit

class MyAddressDetailsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var twobtnView: UIView!
    @IBOutlet weak var additionaltxt: UITextField!
    @IBOutlet weak var blocktxt: UITextField!
    @IBOutlet weak var streettxt: UITextField!
    @IBOutlet weak var houseNumbertxt: UITextField!
    @IBOutlet weak var addressLabeltxt: UITextField!
    
    @IBOutlet weak var cancelbtn: UIButton!
    @IBOutlet weak var savebtn: UIButton!
    @IBOutlet weak var viewLocationbtn: UIButton!
    

    private let selectedBorder = UIColor(hex: "#FEC400")
        private let selectedBG = UIColor(hex: "#FFFBE7")

        override func viewDidLoad() {
            super.viewDidLoad()

            title = "Address Details"

            setupTextFields()
            setupButtons()

            // IMPORTANT:
            // - Save + Cancel actions can be from storyboard OR forced here (safe)
            // - ViewLocation is NOT wired from code (so segue works, no popup)
            forceWireActionsOnlyForSaveCancel()

            // Optional: only update height IF a height constraint already exists (no new constraints!)
            setExistingHeightConstraintIfFound(viewLocationbtn, to: 54)
            // If you want Save height 54, set it in storyboard.
            // setExistingHeightConstraintIfFound(savebtn, to: 54)

            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }

        // MARK: - Setup

        private func setupTextFields() {
            let fields: [UITextField] = [
                addressLabeltxt,
                houseNumbertxt,
                streettxt,
                blocktxt,
                additionaltxt
            ]

            fields.forEach {
                $0.delegate = self
                $0.autocorrectionType = .no
                $0.spellCheckingType = .no
            }

            houseNumbertxt.keyboardType = .numberPad

            addressLabeltxt.returnKeyType = .next
            houseNumbertxt.returnKeyType = .next
            streettxt.returnKeyType = .next
            blocktxt.returnKeyType = .next
            additionaltxt.returnKeyType = .done
        }

        private func setupButtons() {
            twobtnView.backgroundColor = .clear

            // Save (keep storyboard size/constraints)
            savebtn.clipsToBounds = true
            savebtn.layer.cornerRadius = 8   // adjust if you want more sharp/less round

            // Cancel text color
            cancelbtn.setTitleColor(selectedBorder, for: .normal)

            // View Location style (keep storyboard size/constraints)
            viewLocationbtn.setTitleColor(.black, for: .normal)
            viewLocationbtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            viewLocationbtn.backgroundColor = selectedBG
            viewLocationbtn.layer.cornerRadius = 8
            viewLocationbtn.layer.borderWidth = 2
            viewLocationbtn.layer.borderColor = selectedBorder.cgColor
            viewLocationbtn.clipsToBounds = true

            // press effect only (doesn't change layout)
            viewLocationbtn.addTarget(self, action: #selector(pressDown(_:)), for: .touchDown)
            viewLocationbtn.addTarget(self, action: #selector(pressUp(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit, .touchUpOutside])

            savebtn.addTarget(self, action: #selector(pressDown(_:)), for: .touchDown)
            savebtn.addTarget(self, action: #selector(pressUp(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit, .touchUpOutside])
        }

        // Only wire Save/Cancel from code (safe). Leave ViewLocation to storyboard segue.
        private func forceWireActionsOnlyForSaveCancel() {
            cancelbtn.removeTarget(nil, action: nil, for: .touchUpInside)
            savebtn.removeTarget(nil, action: nil, for: .touchUpInside)

            cancelbtn.addTarget(self, action: #selector(cancelTapped(_:)), for: .touchUpInside)
            savebtn.addTarget(self, action: #selector(saveTapped(_:)), for: .touchUpInside)
        }

        // ✅ Updates height ONLY if it already exists (no adding constraints, no translatesAutoresizingMaskIntoConstraints)
        private func setExistingHeightConstraintIfFound(_ view: UIView, to value: CGFloat) {
            // 1) search inside the view itself
            if let c = view.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .equal }) {
                c.constant = value
                return
            }

            // 2) search in the superview constraints (often height constraint lives there)
            if let superview = view.superview,
               let c = superview.constraints.first(where: {
                   ($0.firstItem as? UIView) == view && $0.firstAttribute == .height && $0.relation == .equal
               }) {
                c.constant = value
                return
            }
        }

        // MARK: - Actions

        @objc private func cancelTapped(_ sender: UIButton) {
            navigationController?.popViewController(animated: true)
        }

        @objc private func saveTapped(_ sender: UIButton) {
            let label = addressLabeltxt.text?.trimmed ?? ""
            let house = houseNumbertxt.text?.trimmed ?? ""
            let street = streettxt.text?.trimmed ?? ""
            let block = blocktxt.text?.trimmed ?? ""
            // additional is optional
            // let additional = additionaltxt.text?.trimmed ?? ""

            guard !label.isEmpty else { return showAlert(title: "Missing info", message: "Please enter Address Label.") }
            guard !house.isEmpty else { return showAlert(title: "Missing info", message: "Please enter House Number.") }
            guard !street.isEmpty else { return showAlert(title: "Missing info", message: "Please enter Street.") }
            guard !block.isEmpty else { return showAlert(title: "Missing info", message: "Please enter Block.") }

            showAlert(title: "Saved", message: "Address saved successfully.") { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }

        // ✅ NO LOCATION POPUP FUNCTION HERE.
        // Your storyboard segue will handle navigation when viewLocationbtn is tapped.

        // MARK: - UITextFieldDelegate

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            switch textField {
            case addressLabeltxt: houseNumbertxt.becomeFirstResponder()
            case houseNumbertxt:  streettxt.becomeFirstResponder()
            case streettxt:       blocktxt.becomeFirstResponder()
            case blocktxt:        additionaltxt.becomeFirstResponder()
            default: textField.resignFirstResponder()
            }
            return true
        }

        // MARK: - Helpers

        @objc private func dismissKeyboard() {
            view.endEditing(true)
        }

        private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
            present(alert, animated: true)
        }

        @objc private func pressDown(_ sender: UIButton) {
            UIView.animate(withDuration: 0.10) {
                sender.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                sender.alpha = 0.95
            }
        }

        @objc private func pressUp(_ sender: UIButton) {
            UIView.animate(withDuration: 0.10) {
                sender.transform = .identity
                sender.alpha = 1.0
            }
        }
    }

    private extension String {
        var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    private extension UIColor {
        convenience init(hex: String) {
            var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            if s.hasPrefix("#") { s.removeFirst() }
            var rgb: UInt64 = 0
            Scanner(string: s).scanHexInt64(&rgb)
            self.init(
                red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgb & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        }
    }
