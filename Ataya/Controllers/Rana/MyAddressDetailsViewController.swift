//
//  MyAddressDetailsViewController.swift
//  Ataya
//
//  Created by BP-36-215-01 on 21/12/2025.
//

import UIKit

final class MyAddressDetailsViewController: UIViewController {

    @IBOutlet weak var twobuttonView: UIView!
    @IBOutlet weak var cancelbtn: UIButton!
    @IBOutlet weak var savebtn: UIButton!
    @IBOutlet weak var viewLocationtxt: UIButton!
    @IBOutlet weak var blacktxt: UITextField!
    @IBOutlet weak var streettxt: UITextField!
    @IBOutlet weak var houseNumbertxt: UITextField!
    @IBOutlet weak var addressLabeltxt: UITextField!

        private let yellow = UIColor(hex: "#FEC400")
        private let yellowBG = UIColor(hex: "#FFFBE7")

        // holds confirmed pin data
        private var confirmedLat: Double?
        private var confirmedLng: Double?
        private var confirmedAddress: String?

        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Address Details"

            setupButtons()
            wireButtons()
            makeButtonsSameSize()

            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Load confirmed location after coming back from ConfirmLocation screen
        if let saved = locationStorage.load() {

            // If you have these variables, keep them:
            confirmedLat = saved.latitude
            confirmedLng = saved.longitude
            confirmedAddress = saved.address

            // Show the address (pick what you want)
            // Option 1: put in Address Label field (ONLY if you want it there)
            // addressLabeltxt.text = saved.address

            // Option 2 (recommended): show address on the button
            viewLocationtxt.setTitle(saved.address, for: .normal)

        } else {
            // Optional: reset UI when no saved location yet
            viewLocationtxt.setTitle("View or Change Pin Location", for: .normal)
        }
    }


        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            savebtn.layer.cornerRadius = 8
            cancelbtn.layer.cornerRadius = 8
            viewLocationtxt.layer.cornerRadius = 8
        }

        // MARK: - UI

        private func setupButtons() {
            twobuttonView.backgroundColor = .clear

            // SAVE
            savebtn.clipsToBounds = true
            savebtn.backgroundColor = yellow
            savebtn.setTitleColor(.black, for: .normal)
            savebtn.layer.borderWidth = 0
            savebtn.layer.borderColor = UIColor.clear.cgColor

            // CANCEL
            cancelbtn.clipsToBounds = true
            cancelbtn.backgroundColor = .white
            cancelbtn.setTitleColor(yellow, for: .normal)
            cancelbtn.layer.borderWidth = 2
            cancelbtn.layer.borderColor = yellow.cgColor

            // Location button
            viewLocationtxt.setTitleColor(yellow, for: .normal)
            viewLocationtxt.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            viewLocationtxt.backgroundColor = yellowBG
            viewLocationtxt.layer.borderWidth = 2
            viewLocationtxt.layer.borderColor = yellow.cgColor
            viewLocationtxt.clipsToBounds = true

            // press effect
            [savebtn, cancelbtn].forEach { btn in
                btn.addTarget(self, action: #selector(pressDown(_:)), for: .touchDown)
                btn.addTarget(self, action: #selector(pressUp(_:)),
                              for: [.touchUpInside, .touchCancel, .touchDragExit, .touchUpOutside])
            }
        }

        private func makeButtonsSameSize() {
            savebtn.translatesAutoresizingMaskIntoConstraints = false
            cancelbtn.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                savebtn.widthAnchor.constraint(equalTo: cancelbtn.widthAnchor),
                savebtn.heightAnchor.constraint(equalTo: cancelbtn.heightAnchor)
            ])
        }

        private func wireButtons() {
            savebtn.removeTarget(nil, action: nil, for: .touchUpInside)
            cancelbtn.removeTarget(nil, action: nil, for: .touchUpInside)

            savebtn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
            cancelbtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

            // viewLocationtxt uses storyboard segue → don’t wire here
        }

        // MARK: - Actions

        @objc private func saveTapped() {
            let label = addressLabeltxt.text?.trimmed ?? ""
            let house = houseNumbertxt.text?.trimmed ?? ""
            let street = streettxt.text?.trimmed ?? ""
            let block = blacktxt.text?.trimmed ?? ""

            guard !label.isEmpty else { return showAlert("Missing info", "Please enter Address Label.") }
            guard !house.isEmpty else { return showAlert("Missing info", "Please enter House Number.") }
            guard !street.isEmpty else { return showAlert("Missing info", "Please enter Street.") }
            guard !block.isEmpty else { return showAlert("Missing info", "Please enter Block.") }

            // ✅ require confirmed location
            guard confirmedLat != nil, confirmedLng != nil else {
                return showAlert("Missing Location", "Please confirm your location on the map.")
            }

            // At this point you have:
            // confirmedAddress, confirmedLat, confirmedLng
            // Later you can send these to Firebase.

            showAlert("Saved", "Address saved successfully.") { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }

        @objc private func cancelTapped() {
            navigationController?.popViewController(animated: true)
        }

        // MARK: - Helpers

        @objc private func dismissKeyboard() {
            view.endEditing(true)
        }

        private func showAlert(_ title: String, _ message: String, completion: (() -> Void)? = nil) {
            let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
            present(a, animated: true)
        }

        @objc private func pressDown(_ sender: UIButton) {
            UIView.animate(withDuration: 0.1) {
                sender.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                sender.alpha = 0.92
            }
        }

        @objc private func pressUp(_ sender: UIButton) {
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
                sender.alpha = 1.0
            }
        }
    }

    // MARK: - Small helpers

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
