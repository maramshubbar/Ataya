import UIKit
import PhotosUI

final class AddEditCardDesignViewController: UIViewController {

    // MARK: - Callbacks
    var onSave: ((CardDesign) -> Void)?

    private var existingDesign: CardDesign?

    private var pickedImage: UIImage?

    private var currentImageURL: String?
    private var currentPublicId: String?

    private var currentAssetName: String = "c1"
    private let defaultAssetName = "c1"

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let nameField = UITextField()
    private let nameErrorLabel = UILabel()

    private let activeSwitch = UISwitch()

    // upload box
    private let uploadContainer = UIView()
    private let uploadPlaceholderStack = UIStackView()
    private let uploadIconView = UIImageView()
    private let uploadTitleLabel = UILabel()
    private let uploadSubtitleLabel = UILabel()
    private let artworkErrorLabel = UILabel()
    private let previewImageView = UIImageView()

    private let saveButton = UIButton(type: .system)
    private let loading = UIActivityIndicatorView(style: .medium)

    private let brandYellow = UIColor(atayaHex: "F7D44C")
    private let borderGray = UIColor.systemGray3
    private var dashedBorderLayer: CAShapeLayer?

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
        setupLayout()
        setupUploadBox()
        setupErrorLabels()
        bindExisting()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateDashedBorder()
    }

    // MARK: - Nav
    private func setupNav() {
        view.backgroundColor = .systemBackground
        title = existingDesign == nil ? "Add Design" : "Edit Design"
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
        addFieldSection(title: "Design Name", fieldView: nameField, errorLabel: nameErrorLabel)

        // Upload
        addFieldSection(title: "Card Artwork", fieldView: uploadContainer, errorLabel: artworkErrorLabel)

        // Active
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

        // loader
        loading.hidesWhenStopped = true
        loading.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addSubview(loading)
        NSLayoutConstraint.activate([
            loading.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
            loading.trailingAnchor.constraint(equalTo: saveButton.trailingAnchor, constant: -14)
        ])
    }

    // MARK: - Errors
    private func setupErrorLabels() {
        [nameErrorLabel, artworkErrorLabel].forEach { label in
            label.font = .systemFont(ofSize: 13, weight: .regular)
            label.textColor = .systemRed
            label.numberOfLines = 0
            label.isHidden = true
        }
    }

    private func clearErrors() {
        nameErrorLabel.isHidden = true
        nameErrorLabel.text = nil
        artworkErrorLabel.isHidden = true
        artworkErrorLabel.text = nil
    }

    private func setSaving(_ saving: Bool) {
        saveButton.isEnabled = !saving
        navigationItem.hidesBackButton = saving
        if saving { loading.startAnimating() } else { loading.stopAnimating() }
        saveButton.alpha = saving ? 0.85 : 1.0
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

        uploadSubtitleLabel.text = "Upload image in (JPG or PNG)"
        uploadSubtitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        uploadSubtitleLabel.textColor = .systemGray2
        uploadSubtitleLabel.textAlignment = .center

        uploadPlaceholderStack.addArrangedSubview(uploadIconView)
        uploadPlaceholderStack.addArrangedSubview(uploadTitleLabel)
        uploadPlaceholderStack.addArrangedSubview(uploadSubtitleLabel)

        uploadContainer.addSubview(uploadPlaceholderStack)

        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.contentMode = .scaleAspectFill
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

        DispatchQueue.main.async { [weak self] in
            self?.updateDashedBorder()
        }
    }

    private func updateDashedBorder() {
        dashedBorderLayer?.removeFromSuperlayer()
        uploadContainer.layoutIfNeeded()

        guard uploadContainer.bounds.width > 0, uploadContainer.bounds.height > 0 else { return }

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
        guard let design = existingDesign else {
            activeSwitch.isOn = true
            currentAssetName = defaultAssetName
            return
        }

        nameField.text = design.name
        activeSwitch.isOn = design.isActive

        currentImageURL = design.imageURL
        currentPublicId = design.imagePublicId
        currentAssetName = design.imageName.isEmpty ? defaultAssetName : design.imageName

        if let url = design.imageURL, !url.isEmpty {
            previewImageView.isHidden = false
            uploadPlaceholderStack.isHidden = true

            let placeholder = UIImage(named: currentAssetName) ?? UIImage(named: defaultAssetName)

            ImageLoader.shared.setImage(
                on: previewImageView,
                from: url,
                placeholder: placeholder
            )

        } else if let img = UIImage(named: currentAssetName) ?? UIImage(named: defaultAssetName) {
            previewImageView.image = img
            previewImageView.isHidden = false
            uploadPlaceholderStack.isHidden = true
        }
    }

    // MARK: - Actions
    @objc private func uploadTapped() {
        clearErrors()

        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in self.presentCamera() })
        sheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in self.presentPhotoPicker() })
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
            nameErrorLabel.text = "Design name is required."
            nameErrorLabel.isHidden = false
            hasError = true
        }

        if existingDesign == nil && pickedImage == nil {
            artworkErrorLabel.text = "Please upload the card artwork."
            artworkErrorLabel.isHidden = false
            hasError = true
        }

        if existingDesign != nil {
            let hasAnyImage = (pickedImage != nil)
                || ((currentImageURL ?? "").isEmpty == false)
                || (currentAssetName.isEmpty == false)

            if !hasAnyImage {
                artworkErrorLabel.text = "Please upload the card artwork."
                artworkErrorLabel.isHidden = false
                hasError = true
            }
        }

        if hasError { return }

        setSaving(true)

        if let img = pickedImage {
            CloudinaryUploader.shared.uploadImage(img, folder: "card_designs") { [weak self] result in
                guard let self else { return }

                switch result {
                case .failure(let err):
                    self.setSaving(false)
                    self.artworkErrorLabel.text = "Upload failed. Please try again."
                    self.artworkErrorLabel.isHidden = false
                    print("❌ Cloudinary upload error:", err.localizedDescription)

                case .success(let out):
                    self.currentImageURL = out.secureUrl
                    self.currentPublicId = out.publicId

                    // نخلي imageName fallback ثابت (UI)
                    if self.currentAssetName.isEmpty {
                        self.currentAssetName = self.existingDesign?.imageName ?? self.defaultAssetName
                    }

                    self.finishSave(name: trimmedName)
                }
            }
        } else {
            finishSave(name: trimmedName)
        }
    }

    private func finishSave(name: String) {
        let id = existingDesign?.id ?? UUID().uuidString
        let isDefault = existingDesign?.isDefault ?? false

        let design = CardDesign(
            id: id,
            name: name,
            imageName: currentAssetName.isEmpty ? defaultAssetName : currentAssetName,
            isActive: activeSwitch.isOn,
            isDefault: isDefault,
            imageURL: currentImageURL,
            imagePublicId: currentPublicId,
            ngoId: existingDesign?.ngoId
        )

        setSaving(false)
        onSave?(design)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Image handling
private extension AddEditCardDesignViewController {
    func handlePicked(image: UIImage) {
        pickedImage = image

        previewImageView.image = image
        previewImageView.isHidden = false
        uploadPlaceholderStack.isHidden = true
        artworkErrorLabel.isHidden = true
    }
}

// MARK: - Delegates
extension AddEditCardDesignViewController: PHPickerViewControllerDelegate,
                                           UIImagePickerControllerDelegate,
                                           UINavigationControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)

        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }

        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }
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
