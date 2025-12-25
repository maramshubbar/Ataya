//
//  AddEditGiftViewController.swift
//  Ataya
//
//  Created by Maram on 25/12/2025.
//

import UIKit

final class AddEditGiftViewController: UIViewController {

    // MARK: - Callback

    var onSave: ((Gift) -> Void)?

    // لو جايين من Edit
    private var existingGift: Gift?

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let nameField = UITextField()
    private let nameErrorLabel = UILabel()

    private let pricingSegment = UISegmentedControl(items: ["Fixed amount", "Custom amount"])
    private let amountField = UITextField()
    private let amountErrorLabel = UILabel()

    private let descriptionTextView = UITextView()
    private let descriptionPlaceholder = UILabel()

    private let activeSwitch = UISwitch()

    private let saveButton = UIButton(type: .system)

    private let brandYellow = UIColor(atayaHex: "F7D44C")

    // MARK: - Init

    init(existingGift: Gift?) {
        self.existingGift = existingGift
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupLayout()
        setupErrorLabels()
        bindExisting()
    }

    // MARK: - Nav

    private func setupNav() {
        view.backgroundColor = .systemBackground
        title = existingGift == nil ? "Add Gift" : "Edit Gift"
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - Layout

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        // زر Save تحت
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -12),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),

            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        func addFieldSection(title: String, fieldView: UIView, errorLabel: UILabel?) {
            let titleLabel = UILabel()
            titleLabel.text = "* " + title
            titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)

            let stack = UIStackView(arrangedSubviews: [titleLabel, fieldView])
            stack.axis = .vertical
            stack.spacing = 8

            if let errorLabel {
                let outer = UIStackView(arrangedSubviews: [stack, errorLabel])
                outer.axis = .vertical
                outer.spacing = 4
                contentStack.addArrangedSubview(outer)
            } else {
                contentStack.addArrangedSubview(stack)
            }
        }

        // Name
        nameField.borderStyle = .roundedRect
        addFieldSection(title: "Gift Name", fieldView: nameField, errorLabel: nameErrorLabel)

        // Pricing
        pricingSegment.selectedSegmentIndex = 0
        pricingSegment.addTarget(self, action: #selector(pricingChanged), for: .valueChanged)
        addFieldSection(title: "Pricing", fieldView: pricingSegment, errorLabel: nil)

        // Amount (for fixed)
        amountField.borderStyle = .roundedRect
        amountField.keyboardType = .decimalPad
        amountField.placeholder = "Enter amount e.g. 500"
        addFieldSection(title: "Amount", fieldView: amountField, errorLabel: amountErrorLabel)

        // Description
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.font = .systemFont(ofSize: 14)
        descriptionTextView.delegate = self
        descriptionTextView.heightAnchor.constraint(equalToConstant: 120).isActive = true

        descriptionPlaceholder.text = "Gift description (optional)"
        descriptionPlaceholder.font = .systemFont(ofSize: 14)
        descriptionPlaceholder.textColor = .placeholderText
        descriptionPlaceholder.translatesAutoresizingMaskIntoConstraints = false

        let descriptionContainer = UIView()
        descriptionContainer.translatesAutoresizingMaskIntoConstraints = false
        descriptionContainer.addSubview(descriptionTextView)
        descriptionContainer.addSubview(descriptionPlaceholder)

        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: descriptionContainer.topAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: descriptionContainer.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: descriptionContainer.trailingAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: descriptionContainer.bottomAnchor),

            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 8),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 6)
        ])

        let descTitle = UILabel()
        descTitle.text = "Description"
        descTitle.font = .systemFont(ofSize: 14, weight: .semibold)

        let descStack = UIStackView(arrangedSubviews: [descTitle, descriptionContainer])
        descStack.axis = .vertical
        descStack.spacing = 8
        contentStack.addArrangedSubview(descStack)

        // Active row
        let activeLabel = UILabel()
        activeLabel.text = "Active"
        activeLabel.font = .systemFont(ofSize: 14, weight: .semibold)

        let activeRow = UIStackView(arrangedSubviews: [activeLabel, activeSwitch])
        activeRow.axis = .horizontal
        activeRow.distribution = .equalSpacing
        contentStack.addArrangedSubview(activeRow)

        // Save button style
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = brandYellow
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        saveButton.layer.cornerRadius = 14
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        // default visibility
        updateAmountVisibility()
    }

    // MARK: - Error labels

    private func setupErrorLabels() {
        [nameErrorLabel, amountErrorLabel].forEach { label in
            label.font = .systemFont(ofSize: 13)
            label.textColor = .systemRed
            label.numberOfLines = 0
            label.isHidden = true
        }
    }

    private func clearErrors() {
        nameErrorLabel.isHidden = true
        nameErrorLabel.text = nil
        amountErrorLabel.isHidden = true
        amountErrorLabel.text = nil
    }

    // MARK: - Bind existing

    private func bindExisting() {
        guard let gift = existingGift else {
            activeSwitch.isOn = true
            pricingSegment.selectedSegmentIndex = 0
            updateAmountVisibility()
            return
        }

        nameField.text = gift.title
        descriptionTextView.text = gift.description
        descriptionPlaceholder.isHidden = !gift.description.isEmpty
        activeSwitch.isOn = gift.isActive

        switch gift.pricing {
        case .custom:
            pricingSegment.selectedSegmentIndex = 1
            amountField.text = nil
        case .fixed(let amount):
            pricingSegment.selectedSegmentIndex = 0
            amountField.text = "\(amount)"
        }

        updateAmountVisibility()
    }

    // MARK: - Helpers

    @objc private func pricingChanged() {
        updateAmountVisibility()
    }

    private func updateAmountVisibility() {
        let isFixed = pricingSegment.selectedSegmentIndex == 0
        amountField.superview?.isHidden = !isFixed
        amountErrorLabel.isHidden = true
        amountErrorLabel.text = nil
    }

    // MARK: - Save

    @objc private func saveTapped() {
        clearErrors()

        let trimmedName = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        var hasError = false

        if trimmedName.isEmpty {
            nameErrorLabel.text = "Gift name is required."
            nameErrorLabel.isHidden = false
            hasError = true
        }

        // pricing
        let isFixed = pricingSegment.selectedSegmentIndex == 0
        var pricing: Gift.Pricing = .custom

        if isFixed {
            let raw = (amountField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if raw.isEmpty {
                amountErrorLabel.text = "Please enter an amount."
                amountErrorLabel.isHidden = false
                hasError = true
            } else if let dec = Decimal(string: raw.replacingOccurrences(of: ",", with: "")), dec > 0 {
                pricing = .fixed(amount: dec)
            } else {
                amountErrorLabel.text = "Amount must be a positive number."
                amountErrorLabel.isHidden = false
                hasError = true
            }
        } else {
            pricing = .custom
        }

        if hasError { return }

        let desc = descriptionTextView.text ?? ""
        let id = existingGift?.id ?? UUID().uuidString


        let imageName = existingGift?.imageName ?? "c4"

        let gift = Gift(
            id: id,
            title: trimmedName,
            pricing: pricing,
            description: desc,
            imageName: imageName,
            isActive: activeSwitch.isOn
        )

        onSave?(gift)
        navigationController?.popViewController(animated: true)
    }

}

// MARK: - UITextViewDelegate

extension AddEditGiftViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholder.isHidden = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
