//
//  AddEditGiftViewController.swift
//  Ataya
//

import UIKit
import PhotosUI

final class AddEditGiftViewController: UIViewController {

    // MARK: - Callbacks

    var onSave: ((Gift) -> Void)?

    private var existingGift: Gift?

    private var storedImageId: String?

    private enum PricingMode {
        case fixed
        case custom
    }

    private var pricingMode: PricingMode = .fixed

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
        // scroll
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        // Save button
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

        // helper: labeled section
        func addFieldSection(title: String, fieldView: UIView, errorLabel: UILabel? = nil) {
            let titleLabel = UILabel()
            titleLabel.text = title        // مرري العنوان مع * اذا تبين
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
        fixedAmountField.placeholder = "e.g. 500"
        fixedAmountField.keyboardType = .decimalPad

        fixedAmountContainer.addArrangedSubview(amountLabel)
        fixedAmountContainer.addArrangedSubview(fixedAmountField)

        let pricingStack = UIStackView(arrangedSubviews: [pricingSegmented, fixedAmountContainer])
        pricingStack.axis = .vertical
        pricingStack.spacing = 8

        addFieldSection(title: "* Pricing", fieldView: pricingStack, errorLabel: pricingErrorLabel)

        // Upload section
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

        addFieldSection(title: "Description", fieldView: descriptionTextView, errorLabel: nil)

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

        // placeholder stack
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

        uploadSubtitleLabel.text = "Upload image in  (JPG or PNG)"
        uploadSubtitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        uploadSubtitleLabel.textColor = .systemGray2
        uploadSubtitleLabel.textAlignment = .center

        uploadPlaceholderStack.addArrangedSubview(uploadIconView)
        uploadPlaceholderStack.addArrangedSubview(uploadTitleLabel)
        uploadPlaceholderStack.addArrangedSubview(uploadSubtitleLabel)

        uploadContainer.addSubview(uploadPlaceholderStack)

        // preview (normal مستطيل مو قلب)
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

        // tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(uploadTapped))
        uploadContainer.addGestureRecognizer(tap)
        uploadContainer.isUserInteractionEnabled = true
    }

    private func updateDashedBorder() {
        uploadContainer.layoutIfNeeded()

        dashedBorderLayer?.removeFromSuperlayer()

        guard uploadContainer.bounds.width > 0,
              uploadContainer.bounds.height > 0 else {
            return
        }

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
        if let gift = existingGift {
            nameField.text = gift.title
            descriptionTextView.text = gift.description
            descriptionPlaceholderLabel.isHidden = !gift.description
                .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            activeSwitch.isOn = gift.isActive

            let imgName = gift.imageName
            if let img = UIImage(named: imgName) {
                previewImageView.image = img
                previewImageView.isHidden = false
                uploadPlaceholderStack.isHidden = true
                storedImageId = imgName
            }

        } else {
            activeSwitch.isOn = true
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
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.presentCamera()
        }))
        sheet.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.presentPhotoPicker()
        }))
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

    @objc private func saveTapped() {
        clearErrors()

        let trimmedName = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        var hasError = false

        if trimmedName.isEmpty {
            nameErrorLabel.text = "Gift name is required."
            nameErrorLabel.isHidden = false
            hasError = true
        }

        var pricing: Gift.Pricing = .custom

        if pricingMode == .fixed {
            let text = (fixedAmountField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if let value = Decimal(string: text), value > 0 {
                pricing = .fixed(amount: value)
            } else {
                pricingErrorLabel.text = "Enter a valid fixed amount."
                pricingErrorLabel.isHidden = false
                hasError = true
            }
        } else {
            pricing = .custom
        }

        if storedImageId == nil {
            artworkErrorLabel.text = "Please upload the gift artwork."
            artworkErrorLabel.isHidden = false
            hasError = true
        }

        if hasError { return }
        guard let imageId = storedImageId else { return }

        let desc = descriptionTextView.text ?? ""
        let id = existingGift?.id ?? UUID().uuidString

        let gift = Gift(
            id: id,
            title: trimmedName,
            pricing: pricing,
            description: desc,
            imageName: imageId,
            isActive: activeSwitch.isOn
        )

        onSave?(gift)
        navigationController?.popViewController(animated: true)
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
        previewImageView.image = image
        previewImageView.isHidden = false
        uploadPlaceholderStack.isHidden = true
        artworkErrorLabel.isHidden = true

        storedImageId = "uploaded_\(UUID().uuidString)"
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
            guard let self = self,
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
