//
//  PickUpDateViewController.swift
//  Ataya
//
//  Created by BP-36-224-16 on 18/12/2025.
//
import UIKit

final class PickUpDateViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var timeSectionContainer: UIView!
    @IBOutlet weak var calenderCollectionView: UIDatePicker!

    var draft: DraftDonation?

    private var selectedDate: Date?
    private var selectedTime: String?
    private var timeButtons: [UIButton] = []

    private let times: [String] = [
        "8:00 AM", "10:00 AM", "11:00 AM",
        "12:00 PM", "1:00 PM", "3:00 PM",
        "6:00 PM", "8:00 PM"
    ]

    private let borderGray = UIColor(hex: "#999999")
    private let selectedBorder = UIColor(hex: "#FEC400")
    private let selectedBackground = UIColor(hex: "#FFFBE7")

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Select Pickup Date"

        // IMPORTANT: do NOT create a new draft here. It must be passed from EnterDetails.
        if draft == nil {
            
            draft = DraftDonation()
        }


        setupDatePicker()
        setupNextButton()

        selectedDate = calenderCollectionView.date
        buildTimeUI()
        updateNextButtonState()
    }

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

    private func setupNextButton() {
        nextButton.layer.cornerRadius = 12
        nextButton.clipsToBounds = true
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
    }

    private func buildTimeUI() {
        timeSectionContainer.subviews.forEach { $0.removeFromSuperview() }

        let titleLabel = UILabel()
        titleLabel.text = "Select a Time Slot"
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Choose an available pickup time"
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 16
        grid.distribution = .fillEqually

        timeButtons = times.map { makeTimeButton(title: $0) }

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

            if rowButtons.count == 2 { row.addArrangedSubview(UIView()) }
            grid.addArrangedSubview(row)
        }

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
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.setTitleColor(.label, for: .normal)

        b.backgroundColor = .white
        b.layer.cornerRadius = 4
        b.clipsToBounds = true
        b.layer.borderWidth = 1
        b.layer.borderColor = borderGray.cgColor

        b.addTarget(self, action: #selector(timeTapped(_:)), for: .touchUpInside)
        b.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        b.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])

        b.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return b
    }

    @objc private func timeTapped(_ sender: UIButton) {
        for btn in timeButtons { setTimeButton(btn, selected: false) }
        setTimeButton(sender, selected: true)

        selectedTime = sender.currentTitle
        updateNextButtonState()
    }

    private func setTimeButton(_ button: UIButton, selected: Bool) {
        if selected {
            button.layer.borderWidth = 2
            button.layer.borderColor = selectedBorder.cgColor
            button.backgroundColor = selectedBackground
        } else {
            button.layer.borderWidth = 1
            button.layer.borderColor = borderGray.cgColor
            button.backgroundColor = .white
        }
    }

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

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let date = selectedDate else {
            showAlert(title: "Choose a date", message: "Please select a pickup date before continuing.")
            return
        }
        guard let time = selectedTime else {
            showAlert(title: "Choose a time", message: "Please select a pickup time before continuing.")
            return
        }
        guard let draftObj = draft else {
            showAlert(title: "Missing draft", message: "Draft not passed from previous screen. Go back and try again.")
            navigationController?.popViewController(animated: true)
            return
        }

        draftObj.pickupDate = date
        draftObj.pickupTime = time

        let sb = UIStoryboard(name: "Pickup", bundle: nil)
        guard let vc = sb.instantiateViewController(
            withIdentifier: "MyAddressListViewController"
        ) as? MyAddressListViewController else {
            showAlert(
                title: "Storyboard Error",
                message: "In Pickup.storyboard set Storyboard ID = MyAddressListViewController"
            )
            return
        }

        
        vc.draft = draft ?? DraftDonation()
        
        navigationController?.pushViewController(vc, animated: true)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}

