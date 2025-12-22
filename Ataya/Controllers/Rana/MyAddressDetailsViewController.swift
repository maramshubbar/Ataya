//
//  MyAddressDetailsViewController.swift
//  Ataya
//
//  Created by BP-36-224-14 on 22/12/2025.
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

    // MARK: - UI Colors
        private let yellow = UIColor(hex: "#FEC400")
        private let yellowBG = UIColor(hex: "#FFFBE7")

        // MARK: - From List VC (Edit/Add)
        var editIndex: Int?
        var existingAddress: AddressModel?
        var onSaveAddress: ((AddressModel, Int?) -> Void)?

        // MARK: - Confirmed location from map
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

            // If editing existing address
            if let existing = existingAddress {
                addressLabeltxt.text = existing.title
                confirmedLat = existing.latitude
                confirmedLng = existing.longitude
                confirmedAddress = existing.fullAddress

                viewLocationtxt.setTitle("Location Selected", for: .normal)
            } else {
                // New address (default button title)
                viewLocationtxt.setTitle("View or Change Pin Location", for: .normal)
            }
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            // ✅ ONLY update if Confirm screen saved something
            if let saved = LocationStorage.load() {
                confirmedLat = saved.latitude
                confirmedLng = saved.longitude
                confirmedAddress = saved.address

                viewLocationtxt.setTitle(saved.address, for: .normal)

                // ✅ IMPORTANT: stop it from re-loading forever
                // so next time it won't keep showing old location unless user confirms again
                LocationStorage.clear()
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

            // ✅ IMPORTANT: don't use storyboard segue for location
            // We wire it so we can clear old location before opening confirm screen
            viewLocationtxt.removeTarget(nil, action: nil, for: .touchUpInside)
            viewLocationtxt.addTarget(self, action: #selector(openConfirmLocation), for: .touchUpInside)
        }

        // MARK: - Open Confirm Location (clears old before going)

        @objc private func openConfirmLocation() {
            // ✅ Clear any old saved location BEFORE opening confirm screen
            LocationStorage.clear()

            // push confirm location screen
            let vc = storyboard?.instantiateViewController(withIdentifier: "ConfirmLocationViewController") as! ConfirmLocationViewController
            navigationController?.pushViewController(vc, animated: true)
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

            guard let lat = confirmedLat, let lng = confirmedLng else {
                return showAlert("Missing Location", "Please confirm your location on the map.")
            }

            let full = "Block \(block), Street \(street), House \(house)"

            let newAddress = AddressModel(
                title: label,
                fullAddress: full,
                latitude: lat,
                longitude: lng
            )

            // ✅ Normal flow: list VC will save it
            if let onSaveAddress {
                onSaveAddress(newAddress, editIndex)
            } else {
                // ✅ Safety: if opened directly, still save
                var list = AddressStorage.shared.loadAddresses()
                if let i = editIndex, i < list.count {
                    list[i] = newAddress
                } else {
                    guard list.count < 2 else {
                        return showAlert("Limit Reached", "You can only save 2 addresses.")
                    }
                    list.append(newAddress)
                }
                AddressStorage.shared.saveAddresses(list)
            }

            // ✅ go back (works for push or modal)
            if let nav = navigationController {
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true)
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
