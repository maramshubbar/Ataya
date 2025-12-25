//
//  AddEditGiftViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//

import UIKit

final class AddEditGiftViewController: UIViewController {

    var onSave: ((CardDesign) -> Void)?

    private var existingDesign: CardDesign?

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    private let nameField = UITextField()
    private let descriptionView = UITextView()    
    private let pricingControl = UISegmentedControl(items: ["Fixed amount", "Custom"])
    private let amountField = UITextField()

    private let imageNameField = UITextField()
    private let previewImageView = UIImageView()

    private let activeSwitch = UISwitch()
    private let saveButton = UIButton(type: .system)

    private let brandYellow = UIColor(atayaHex: "F7D44C")

    // MARK: - Init

    init(existingDesign: CardDesign? = nil) {
        self.existingDesign = existingDesign
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        bindExisting()
    }

    // MARK: - Setup

    private func setupNav() {
        view.backgroundColor = .systemBackground
        title = existingDesign == nil ? "Add Card Design" : "Edit Card Design"
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupUI() {
        // scroll
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -30)
        ])

        func addLabeled(_ text: String, view v: UIView) {
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 14, weight: .semibold)

            let container = UIStackView(arrangedSubviews: [label, v])
            container.axis = .vertical
            container.spacing = 6
            stack.addArrangedSubview(container)
        }

        // Name
        nameField.borderStyle = .roundedRect
        nameField.placeholder = "Card name *"
        addLabeled("Card Name *", view: nameField)

        // Description (اختياري، مو محفوظ في CardDesign حالياً)
        descriptionView.font = .systemFont(ofSize: 14)
        descriptionView.layer.cornerRadius = 8
        descriptionView.layer.borderWidth = 0.5
        descriptionView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        addLabeled("Description (optional)", view: descriptionView)

        // Pricing controls غير مستخدمة في CardDesign → نخفيها لكن نخليها لو حبيتي تستخدمينها بعدين
        pricingControl.selectedSegmentIndex = 0
        pricingControl.isHidden = true
        addLabeled("Pricing Type (not used)", view: pricingControl)

        amountField.borderStyle = .roundedRect
        amountField.keyboardType = .decimalPad
        amountField.placeholder = "Amount"
        amountField.isHidden = true
        addLabeled("Fixed Amount (not used)", view: amountField)

        // Image asset name
        imageNameField.borderStyle = .roundedRect
        imageNameField.placeholder = "Image asset name (e.g. c1, c2...)"
        imageNameField.addTarget(self, action: #selector(imageNameChanged), for: .editingChanged)
        addLabeled("Image Asset", view: imageNameField)

        // Preview
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.clipsToBounds = true
        previewImageView.layer.cornerRadius = 12
        previewImageView.backgroundColor = UIColor.systemGray6
        previewImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        addLabeled("Preview", view: previewImageView)

        // Active switch
        let activeRow = UIStackView()
        activeRow.axis = .horizontal
        activeRow.distribution = .equalSpacing

        let activeLabel = UILabel()
        activeLabel.text = "Active"
        activeLabel.font = .systemFont(ofSize: 14, weight: .semibold)

        activeRow.addArrangedSubview(activeLabel)
        activeRow.addArrangedSubview(activeSwitch)
        stack.addArrangedSubview(activeRow)

        // Save button
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = brandYellow
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.layer.cornerRadius = 12
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        stack.addArrangedSubview(saveButton)
    }

    // MARK: - Existing values

    private func bindExisting() {
        guard let design = existingDesign else {
            activeSwitch.isOn = true
            return
        }

        nameField.text = design.name
        activeSwitch.isOn = design.isActive
        imageNameField.text = design.imageName
        previewImageView.image = UIImage(named: design.imageName)
    }

    // MARK: - Actions

    @objc private func imageNameChanged() {
        let name = imageNameField.text ?? ""
        previewImageView.image = UIImage(named: name)
    }

    @objc private func saveTapped() {
        // Validation
        let trimmedName = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            showError("Card name is required.")
            return
        }

        let image = (imageNameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if image.isEmpty {
            showError("Please enter an image asset name.")
            return
        }

        let id = existingDesign?.id ?? UUID().uuidString

        let newDesign = CardDesign(
            id: id,
            name: trimmedName,
            imageName: image,
            isActive: activeSwitch.isOn,
            isDefault: existingDesign?.isDefault ?? false   // نتركه مثل ما هو لو تعديــل
        )

        onSave?(newDesign)
        navigationController?.popViewController(animated: true)
    }

    private func showError(_ msg: String) {
        let alert = UIAlertController(title: "Validation", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
