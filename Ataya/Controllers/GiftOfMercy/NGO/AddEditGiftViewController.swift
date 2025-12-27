//
//  AddEditGiftViewController.swift
//  Ataya
//

import UIKit
import PhotosUI
import FirebaseAuth

final class AddEditGiftViewController: UIViewController {

    // MARK: - Callbacks
    var onSave: ((Gift) -> Void)?

    private var existingGift: Gift?

    // ✅ Keep picked image for Cloudinary upload
    private var pickedImage: UIImage?

    // ✅ Use Gift.PricingMode directly
    private var pricingMode: Gift.PricingMode = .fixed

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let nameField = UITextField()
    private let nameErrorLabel = UILabel()

    private let pricingSegmented = UISegmentedControl(items: ["Fixed amount", "Custom amount"])
    private let fixedAmountContainer = UIStackView()
    private let fixedAmountField = UITextField()
    private let pricingErrorLabel = UILabel()

    // upload box
    private let uploadContainer = UIView()
    private let uploadPlaceholderStack = UIStackView()
    private let uploadIconView = UIImageView()
    private let uploadTitleLabel = UILabel()
    private let uploadSubtitleLabel = UILabel()
    private let artworkErrorLabel = UILabel()
    private let previewImageView = UIImageView()

    // description
    private let descriptionTextView = UITextView()
    private let descriptionPlaceholderLabel = UILabel()

    private let activeSwitch = UISwitch()

    private let saveButton = UIButton(type: .system)
    private let savingSpinner = UIActivityIndicatorView(style: .medium)

    private let brandYellow = UIColor(atayaHex: "F7D44C")
    private let borderGray = UIColor.systemGray3
    private var dashedBorderLayer: CAShapeLayer?

    // MARK: - Init

    init(existingGift: Gift? = nil) {
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
        setupUploadBox()
        setupErrorLabels()
        bindExisting()
        updateDashedBorder()
        pricingChanged()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateDashedBorder()
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

        func addFieldSection(title: String, fieldView: UIView, errorLabel: UILabel? = nil) {
            let titleLabel = UILabel()
            titleLabel.text = title
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

        // Gift Name
        nameField.borderStyle = .roundedRect
        addFieldSection(title: "* Gift Name", fieldView: nameField, errorLabel: nameErrorLabel)

        // Pricing
        pricingSegmented.selectedSegmentIndex = 0
        pricingSegmented.addTarget(self, action: #selector(pricingChanged), for: .valueChanged)

        fixedAmountContainer.axis = .vertical
        fixedAmountContainer.spacing = 4

        let amountLabel = UILabel()
        amountLabel.text = "Amount in BHD"
        amountLabel.font = .systemFont(ofSize: 13, weight: .regular)

        fixedAmountField.borderStyle = .roundedRect
        fixedAmountField.placeholder = "e.g. 5"
        fixedAmountField.keyboardType = .decimalPad

        fixedAmountContainer.addArrangedSubview(amountLabel)
        fixedAmountContainer.addArrangedSubview(fixedAmountField)

        let pricingStack = UIStackView(arrangedSubviews: [pricingSegmented, fixedAmountContainer])
        pricingStack.axis = .vertical
        pricingStack.spacing = 8

        addFieldSection(title: "* Pricing", fieldView: pricingStack, errorLabel: pricingErrorLabel)

        // Upload
        addFieldSection(title: "* Gift Artwork", fieldView: uploadContainer, errorLabel: artworkErrorLabel)

        // Description
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.font = .systemFont(ofSize: 14)
        descriptionTextView.delegate = self
        descriptionTextView.heightAnchor.constraint(equalToConstant: 140).isActive = true

        descriptionPlaceholderLabel.text = "Gift description (optional)"
        descriptionPlaceholderLabel.font = .systemFont(ofSize: 14)
        descriptionPlaceholderLabel.textColor = .placeholderText
        descriptionPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false

        descriptionTextView.addSubview(descriptionPlaceholderLabel)
        NSLayoutConstraint.activate([
            descriptionPlaceholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 6),
            descriptionPlaceholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 8)
        ])

        addFieldSection(title: "Description", fieldView: descriptionTextView)

        // Active row
        let activeLabel = UILabel()
        activeLabel.text = "Active"
        activeLabel.font = .systemFont(ofSize: 14, weight: .semibold)

        let activeRow = UIStackView(arrangedSubviews: [activeLabel, activeSwitch])
        activeRow.axis = .horizontal
        activeRow.distribution = .equalSpacing
        contentStack.addArrangedSubview(activeRow)

        // Save button
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = brandYellow
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        saveButton.layer.cornerRadius = 14
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        savingSpinner.hidesWhenStopped = true
        savingSpinner.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addSubview(savingSpinner)

        NSLayoutConstraint.activate([
            savingSpinner.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
            savingSpinner.trailingAnchor.constraint(equalTo: saveButton.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Error labels

    private func setupErrorLabels() {
        [nameErrorLabel, pricingErrorLabel, artworkErrorLabel].forEach { label in
            label.font = .systemFont(ofSize: 13)
            label.textColor = .systemRed
            label.numberOfLines = 0
            label.isHidden = true
        }
    }

    private func clearErrors() {
        [nameErrorLabel, pricingErrorLabel, artworkErrorLabel].forEach { label in
            label.isHidden = true
            label.text = nil
        }
    }

    // MARK: - Upload Box

    private func setupUploadBox() {
        uploadContainer.translatesAutoresizingMaskIntoConstraints = false
        uploadContainer.heightAnchor.constraint(equalToConstant: 210).isActive = true
        uploadContainer.backgroundColor = .white
        uploadContainer.layer.cornerRadius = 18
        uploadContainer.clipsToBounds = true

        uploadPlaceholderStack.axis = .vertical
        uploadPlaceholderStack.alignment = .center
        uploadPlaceholderStack.spacing = 8
        uploadPlaceholderStack.translatesAutoresizingMaskIntoConstraints = false

        uploadIconView.image = UIImage(named: "camera")
        uploadIconView.contentMode = .scaleAspectFit
        uploadIconView.translatesAutoresizingMaskIntoConstraints = false
        uploadIconView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        uploadIconView.widthAnchor.constraint(equalToConstant: 56).isActive = true

        uploadTitleLabel.text = "Tap to Upload or Take a Photo"
        uploadTitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        uploadTitleLabel.textAlignment = .center

        uploadSubtitleLabel.text = "Upload image (JPG or PNG)"
        uploadSubtitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        uploadSubtitleLabel.textColor = .systemGray2
        uploadSubtitleLabel.textAlignment = .center

        uploadPlaceholderStack.addArrangedSubview(uploadIconView)
        uploadPlaceholderStack.addArrangedSubview(uploadTitleLabel)
        uploadPlaceholderStack.addArrangedSubview(uploadSubtitleLabel)

        uploadContainer.addSubview(uploadPlaceholderStack)

        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.clipsToBounds = true
        previewImageView.isHidden = true
        uploadContainer.addSubview(previewImageView)

        NSLayoutConstraint.activate([
            uploadPlaceholderStack.centerXAnchor.constraint(equalTo: uploadContainer.centerXAnchor),
            uploadPlaceholderStack.centerYAnchor.constraint(equalTo: uploadContainer.centerYAnchor),

            previewImageView.topAnchor.constraint(equalTo: uploadContainer.topAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: uploadContainer.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: uploadContainer.trailingAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: uploadContainer.bottomAnchor)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(uploadTapped))
        uploadContainer.addGestureRecognizer(tap)
        uploadContainer.isUserInteractionEnabled = true
    }

    private func updateDashedBorder() {
        uploadContainer.layoutIfNeeded()
        dashedBorderLayer?.removeFromSuperlayer()

        if previewImageView.isHidden == false { return }

        guard uploadContainer.bounds.width > 0,
              uploadContainer.bounds.height > 0 else { return }

        let shape = CAShapeLayer()
        shape.strokeColor = borderGray.cgColor
        shape.lineDashPattern = [10, 6]
        shape.lineWidth = 1
        shape.fillColor = UIColor.clear.cgColor

        let path = UIBezierPath(
            roundedRect: uploadContainer.bounds.insetBy(dx: 1.5, dy: 1.5),
            cornerRadius: 18
        )
        shape.path = path.cgPath

        uploadContainer.layer.addSublayer(shape)
        dashedBorderLayer = shape
    }

    // MARK: - Bind existing

    private func bindExisting() {
        guard let gift = existingGift else {
            activeSwitch.isOn = true
            return
        }

        nameField.text = gift.title
        descriptionTextView.text = gift.description
        descriptionPlaceholderLabel.isHidden = !gift.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        activeSwitch.isOn = gift.isActive

        switch gift.pricingMode {
        case .fixed:
            pricingSegmented.selectedSegmentIndex = 0
            pricingMode = .fixed
            fixedAmountContainer.isHidden = false
            if let amount = gift.fixedAmount { fixedAmountField.text = String(amount) }
        case .custom:
            pricingSegmented.selectedSegmentIndex = 1
            pricingMode = .custom
            fixedAmountContainer.isHidden = true
            fixedAmountField.text = nil
        }

        // Existing image preview from Cloudinary URL
        if let url = gift.imageURL, !url.isEmpty {
            previewImageView.isHidden = false
            uploadPlaceholderStack.isHidden = true
            ImageLoader.shared.setImage(on: previewImageView, from: url, placeholder: nil)
            updateDashedBorder()
        }
    }

    // MARK: - Actions

    @objc private func pricingChanged() {
        pricingMode = pricingSegmented.selectedSegmentIndex == 0 ? .fixed : .custom
        fixedAmountContainer.isHidden = (pricingMode == .custom)
    }

    @objc private func uploadTapped() {
        clearErrors()

        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.presentCamera()
        })
        sheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.presentPhotoPicker()
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(sheet, animated: true)
    }

    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker()
            return
        }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    private func presentPhotoPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func setSaving(_ saving: Bool) {
        saveButton.isEnabled = !saving
        saving ? savingSpinner.startAnimating() : savingSpinner.stopAnimating()
        saveButton.alpha = saving ? 0.85 : 1.0
    }

    @objc private func saveTapped() {
        clearErrors()

        let trimmedName = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let desc = descriptionTextView.text ?? ""

        var hasError = false

        if trimmedName.isEmpty {
            nameErrorLabel.text = "Gift name is required."
            nameErrorLabel.isHidden = false
            hasError = true
        }

        var fixedAmount: Double? = nil
        if pricingMode == .fixed {
            let text = (fixedAmountField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let normalized = text.replacingOccurrences(of: ",", with: "")
            if let value = Double(normalized), value > 0 {
                fixedAmount = value
            } else {
                pricingErrorLabel.text = "Enter a valid fixed amount."
                pricingErrorLabel.isHidden = false
                hasError = true
            }
        }

        let hasExistingImage = (existingGift?.imageURL?.isEmpty == false)
        let hasPickedImage = (pickedImage != nil)

        if !hasExistingImage && !hasPickedImage {
            artworkErrorLabel.text = "Please upload the gift artwork."
            artworkErrorLabel.isHidden = false
            hasError = true
        }

        if hasError { return }

        setSaving(true)

        let id = existingGift?.id ?? UUID().uuidString

        // ✅ If user picked new image -> upload first using YOUR CloudinaryUploader
        if let picked = pickedImage {
            CloudinaryUploader.shared.uploadImage(picked, folder: "ataya_gifts") { [weak self] result in
                guard let self else { return }

                switch result {
                case .failure(let err):
                    self.setSaving(false)
                    self.artworkErrorLabel.text = err.localizedDescription
                    self.artworkErrorLabel.isHidden = false

                case .success(let uploaded):
                    let gift = self.buildGift(
                        id: id,
                        title: trimmedName,
                        description: desc,
                        pricingMode: self.pricingMode,
                        fixedAmount: fixedAmount,
                        imageURL: uploaded.secureUrl,
                        imagePublicId: uploaded.publicId
                    )
                    self.setSaving(false)
                    self.onSave?(gift)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            // No new image, keep existing Cloudinary fields
            let gift = buildGift(
                id: id,
                title: trimmedName,
                description: desc,
                pricingMode: pricingMode,
                fixedAmount: fixedAmount,
                imageURL: existingGift?.imageURL,
                imagePublicId: existingGift?.imagePublicId
            )

            setSaving(false)
            onSave?(gift)
            navigationController?.popViewController(animated: true)
        }
    }

    private func buildGift(
        id: String,
        title: String,
        description: String,
        pricingMode: Gift.PricingMode,
        fixedAmount: Double?,
        imageURL: String?,
        imagePublicId: String?
    ) -> Gift {

        return Gift(
            id: id,
            title: title,
            description: description,
            isActive: activeSwitch.isOn,
            pricingMode: pricingMode,
            fixedAmount: pricingMode == .fixed ? fixedAmount : nil,
            minAmount: nil,
            maxAmount: nil,
            imageURL: imageURL,
            imagePublicId: imagePublicId,
            ngoId: existingGift?.ngoId ?? Auth.auth().currentUser?.uid,
            createdAt: existingGift?.createdAt,
            updatedAt: existingGift?.updatedAt
        )
    }
}

// MARK: - UITextViewDelegate

extension AddEditGiftViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholderLabel.isHidden =
            !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Image handling

private extension AddEditGiftViewController {
    func handlePicked(image: UIImage) {
        pickedImage = image

        previewImageView.image = image
        previewImageView.isHidden = false
        uploadPlaceholderStack.isHidden = true
        artworkErrorLabel.isHidden = true

        updateDashedBorder()
    }
}

// MARK: - Delegates

extension AddEditGiftViewController: PHPickerViewControllerDelegate,
                                     UIImagePickerControllerDelegate,
                                     UINavigationControllerDelegate {

    func picker(_ picker: PHPickerViewController,
                didFinishPicking results: [PHPickerResult]) {

        dismiss(animated: true)

        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }

        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self,
                  let image = object as? UIImage else { return }

            DispatchQueue.main.async {
                self.handlePicked(image: image)
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            handlePicked(image: image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
