//
//  PickUpDateViewController.swift
//  Ataya
//
//  Created by BP-36-224-16 on 18/12/2025.
//

import UIKit

class PickUpDateViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var timeSectionContainer: UIView!
    
    @IBOutlet weak var calenderCollectionView: UIDatePicker!
    
    private var selectedDate: Date?
        private var selectedTime: String?
        private var timeButtons: [UIButton] = []

        private let times: [String] = [
            "8:00 AM", "10:00 AM", "11:00 AM",
            "12:00 AM", "1:00 PM", "3:00 PM",
            "6:00 PM", "8:00 PM"
        ]

        // Colors
        private let borderGray = UIColor(hex: "#999999")
        private let selectedBorder = UIColor(hex: "#FEC400")
        private let selectedBackground = UIColor(hex: "#FFFBE7")

        override func viewDidLoad() {
            super.viewDidLoad()

            title = "Select Pickup Date"

            setupDatePicker()
            setupNextButton()

            selectedDate = calenderCollectionView.date

            buildTimeUI()

            updateNextButtonState()
        }

        // MARK: - Date Picker

        private func setupDatePicker() {
            if #available(iOS 14.0, *) {
                calenderCollectionView.preferredDatePickerStyle = .inline
            }
            calenderCollectionView.datePickerMode = .date
            calenderCollectionView.minimumDate = Date()
            calenderCollectionView.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        }

        @objc private func dateChanged(_ sender: UIDatePicker) {
            selectedDate = sender.date
            updateNextButtonState()
        }

        // MARK: - Next Button

        private func setupNextButton() {
            nextButton.layer.cornerRadius = 12
            nextButton.clipsToBounds = true
        }

        // MARK: - Build Time UI

        private func buildTimeUI() {
            timeSectionContainer.subviews.forEach { $0.removeFromSuperview() }

            // Label: Select a Time Slot (size 16)
            let titleLabel = UILabel()
            titleLabel.text = "Select a Time Slot"
            titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            titleLabel.textColor = .label

            // Label: Choose an available pickup time (size 14)
            let subtitleLabel = UILabel()
            subtitleLabel.text = "Choose an available pickup time"
            subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
            subtitleLabel.textColor = .secondaryLabel

            // Grid container
            let grid = UIStackView()
            grid.axis = .vertical
            grid.spacing = 16
            grid.distribution = .fillEqually

            // Create buttons
            timeButtons = times.map { makeTimeButton(title: $0) }

            // Rows: 3, 3, 2 (same layout)
            let rows: [[UIButton]] = [
                Array(timeButtons[0...2]),
                Array(timeButtons[3...5]),
                Array(timeButtons[6...7])
            ]

            for rowButtons in rows {
                let row = UIStackView(arrangedSubviews: rowButtons)
                row.axis = .horizontal
                row.spacing = 16
                row.distribution = .fillEqually

                // Last row has 2 → add spacer to keep 3 columns
                if rowButtons.count == 2 {
                    let spacer = UIView()
                    row.addArrangedSubview(spacer)
                }

                grid.addArrangedSubview(row)
            }

            // Add views
            [titleLabel, subtitleLabel, grid].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                timeSectionContainer.addSubview($0)
            }

            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: timeSectionContainer.topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: timeSectionContainer.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: timeSectionContainer.trailingAnchor),

                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
                subtitleLabel.leadingAnchor.constraint(equalTo: timeSectionContainer.leadingAnchor),
                subtitleLabel.trailingAnchor.constraint(equalTo: timeSectionContainer.trailingAnchor),

                grid.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
                grid.leadingAnchor.constraint(equalTo: timeSectionContainer.leadingAnchor),
                grid.trailingAnchor.constraint(equalTo: timeSectionContainer.trailingAnchor),
                grid.bottomAnchor.constraint(lessThanOrEqualTo: timeSectionContainer.bottomAnchor)
            ])
        }

        private func makeTimeButton(title: String) -> UIButton {
            let b = UIButton(type: .system)
            b.setTitle(title, for: .normal)

            // ✅ Text size 16
            b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            b.setTitleColor(.label, for: .normal)

            // ✅ Default style: white + border #999999 + radius 4
            b.backgroundColor = .white
            b.layer.cornerRadius = 4
            b.clipsToBounds = true
            b.layer.borderWidth = 1
            b.layer.borderColor = borderGray.cgColor

            // Actions
            b.addTarget(self, action: #selector(timeTapped(_:)), for: .touchUpInside)

            // “Hover” / press effect
            b.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
            b.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])

            // Height
            b.heightAnchor.constraint(equalToConstant: 56).isActive = true

            return b
        }

        // MARK: - Time Actions

        @objc private func timeTapped(_ sender: UIButton) {
            for btn in timeButtons { setTimeButton(btn, selected: false) }
            setTimeButton(sender, selected: true)

            selectedTime = sender.currentTitle
            updateNextButtonState()
        }

        private func setTimeButton(_ button: UIButton, selected: Bool) {
            if selected {
                // ✅ Selected: border #FEC400 + bg #FFFBE7
                button.layer.borderWidth = 2
                button.layer.borderColor = selectedBorder.cgColor
                button.backgroundColor = selectedBackground
            } else {
                // ✅ Default: white + border #999999
                button.layer.borderWidth = 1
                button.layer.borderColor = borderGray.cgColor
                button.backgroundColor = .white
            }
        }

        // Hover / press animation
        @objc private func buttonTouchDown(_ sender: UIButton) {
            UIView.animate(withDuration: 0.10) {
                sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
                sender.alpha = 0.9
            }
        }

        @objc private func buttonTouchUp(_ sender: UIButton) {
            UIView.animate(withDuration: 0.10) {
                sender.transform = .identity
                sender.alpha = 1.0
            }
        }

        // MARK: - Next + Alerts

        @IBAction func nextButtonTapped(_ sender: UIButton) {
            // Not empty checks
            guard let date = selectedDate else {
                showAlert(title: "Choose a date", message: "Please select a pickup date before continuing.")
                return
            }
            guard let time = selectedTime else {
                showAlert(title: "Choose a time", message: "Please select a pickup time before continuing.")
                return
            }

            // Format date
            let df = DateFormatter()
            df.dateStyle = .full
            df.timeStyle = .none
            let dateText = df.string(from: date)

            // Confirm alert
            let alert = UIAlertController(
                title: "Confirm Pickup Schedule",
                message: "Pickup Date:\n\(dateText)\n\nPickup Time:\n\(time)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
                print("✅ Confirmed:", dateText, time)
            })
            present(alert, animated: true)
        }

        private func updateNextButtonState() {
            let enabled = (selectedDate != nil && selectedTime != nil)
            nextButton.isEnabled = enabled
            nextButton.alpha = enabled ? 1.0 : 0.5
        }

        private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // MARK: - Hex Color Helper

//    private extension UIColor {
//        convenience init(hex: String) {
//            var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//            if hexString.hasPrefix("#") { hexString.removeFirst() }
//
//            var rgb: UInt64 = 0
//            Scanner(string: hexString).scanHexInt64(&rgb)
//
//            let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//            let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//            let b = CGFloat(rgb & 0x0000FF) / 255.0
//
//            self.init(red: r, green: g, blue: b, alpha: 1.0)
//        }
//    }
