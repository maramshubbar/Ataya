//
//  AddEditCardDesignViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//

import UIKit

final class AddEditCardDesignViewController: UIViewController {

    var onSave: ((CardDesign) -> Void)?

    private var existingDesign: CardDesign?

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    private let nameField = UITextField()
    private let imageNameField = UITextField()
    private let previewImage = UIImageView()
    private let activeSwitch = UISwitch()

    private let saveButton = UIButton(type: .system)

    private let brandYellow = UIColor(atayaHex: "F7D44C")

    // mode: add / edit
    init(existingDesign: CardDesign? = nil) {
        self.existingDesign = existingDesign
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        bindExisting()
    }

    // MARK: - Nav
    private func setupNav() {
        view.backgroundColor = .systemBackground
        title = existingDesign == nil ? "Add Design" : "Edit Design"
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - UI
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        stack.axis = .vertical
        stack.spacing = 12
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
        addLabeled("Design Name *", view: nameField)

        // Image asset name
        imageNameField.borderStyle = .roundedRect
        imageNameField.placeholder = "Image asset name *"
        imageNameField.addTarget(self, action: #selector(imageNameChanged), for: .editingChanged)
        addLabeled("Image Asset", view: imageNameField)

        // Preview
        previewImage.translatesAutoresizingMaskIntoConstraints = false
        previewImage.contentMode = .scaleAspectFit
        previewImage.clipsToBounds = true
        previewImage.layer.cornerRadius = 12
        previewImage.backgroundColor = UIColor.systemGray6
        previewImage.heightAnchor.constraint(equalToConstant: 220).isActive = true
        addLabeled("Preview", view: previewImage)

        // Active
        let activeRowLabel = UILabel()
        activeRowLabel.text = "Active"
        activeRowLabel.font = .systemFont(ofSize: 14, weight: .semibold)

        let activeRow = UIStackView(arrangedSubviews: [activeRowLabel, activeSwitch])
        activeRow.axis = .horizontal
        activeRow.distribution = .equalSpacing
        stack.addArrangedSubview(activeRow)

        // Save
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = brandYellow
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.layer.cornerRadius = 12
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        stack.addArrangedSubview(saveButton)
    }

    // MARK: - Bind existing
    private func bindExisting() {
        guard let design = existingDesign else {
            activeSwitch.isOn = true
            return
        }

        nameField.text = design.name
        imageNameField.text = design.imageName
        previewImage.image = UIImage(named: design.imageName)
        activeSwitch.isOn = design.isActive
    }

    // MARK: - Actions
    @objc private func imageNameChanged() {
        let name = imageNameField.text ?? ""
        previewImage.image = UIImage(named: name)
    }

    @objc private func saveTapped() {
        let trimmedName = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            showError("Design name is required.")
            return
        }

        let img = (imageNameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if img.isEmpty {
            showError("Image asset name is required.")
            return
        }

        let id = existingDesign?.id ?? UUID().uuidString
        let isDefault = existingDesign?.isDefault ?? false

        let design = CardDesign(
            id: id,
            name: trimmedName,
            imageName: img,
            isActive: activeSwitch.isOn,
            isDefault: isDefault
        )

        onSave?(design)
        navigationController?.popViewController(animated: true)
    }

    private func showError(_ msg: String) {
        let alert = UIAlertController(title: "Validation", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
