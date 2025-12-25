//
//  AddEditCardDesignViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//

import UIKit
import PhotosUI

final class AddEditCardDesignViewController: UIViewController {

    // MARK: - Callbacks
    var onSave: ((CardDesign) -> Void)?

    // لو جايين من Edit
    private var existingDesign: CardDesign?

    // نخزن الـ ID حق الصورة (لاحقاً URL / publicId)
    private var storedImageId: String?

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

    // زر الحفظ تحت الصفحة
    private let saveButton = UIButton(type: .system)

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
        // scroll
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        // Save button (تحت الصفحة)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            // scroll فوق زر الحفظ
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -12),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),

            // زر Save
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // helper: labeled section مع error label تحت
        func addFieldSection(title: String, fieldView: UIView, errorLabel: UILabel?) {
            let titleLabel = UILabel()
            // ⭐️ النجمة قبل الاسم
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

        // Design Name
        nameField.borderStyle = .roundedRect
        addFieldSection(title: "Design Name", fieldView: nameField, errorLabel: nameErrorLabel)

        // Upload box section
        addFieldSection(title: "Card Artwork", fieldView: uploadContainer, errorLabel: artworkErrorLabel)

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
        [nameErrorLabel, artworkErrorLabel].forEach { label in
            label.font = .systemFont(ofSize: 13, weight: .regular)
            label.textColor = .systemRed
            label.numberOfLines = 0
            label.isHidden = true   // تبقى موجودة لكن فاضية لين يصير إيرور
        }
    }

    private func clearErrors() {
        nameErrorLabel.isHidden = true
        nameErrorLabel.text = nil
        artworkErrorLabel.isHidden = true
        artworkErrorLabel.text = nil
    }

    // MARK: - Upload Box (style مثل التصميم)

    private func setupUploadBox() {
        uploadContainer.translatesAutoresizingMaskIntoConstraints = false
        uploadContainer.heightAnchor.constraint(equalToConstant: 210).isActive = true
        uploadContainer.backgroundColor = .white
        uploadContainer.layer.cornerRadius = 18
        uploadContainer.clipsToBounds = true
        
        // placeholder stack (icon + text)
        uploadPlaceholderStack.axis = .vertical
        uploadPlaceholderStack.alignment = .center
        uploadPlaceholderStack.spacing = 8
        uploadPlaceholderStack.translatesAutoresizingMaskIntoConstraints = false
        
        // أيقونة من الأست "camera"
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
        
        // preview image (تغطي الصندوق لما نختار صورة)
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
        
        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(uploadTapped))
        uploadContainer.addGestureRecognizer(tap)
        uploadContainer.isUserInteractionEnabled = true
        
        DispatchQueue.main.async { [weak self] in
            self?.updateDashedBorder()
        }
    }
    /// نرسم الداش حوالين الصندوق (دايماً)
    private func updateDashedBorder() {
        dashedBorderLayer?.removeFromSuperlayer()

        let shape = CAShapeLayer()
        shape.strokeColor = borderGray.cgColor
        shape.lineDashPattern = [10, 6]    // طويل/قصير مثل التصميم
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

    // MARK: - Bind existing (Edit)

    private func bindExisting() {
        if let design = existingDesign {
            nameField.text = design.name
            activeSwitch.isOn = design.isActive
            storedImageId = design.imageName

            if let img = UIImage(named: design.imageName) {
                previewImageView.image = img
                previewImageView.isHidden = false
                uploadPlaceholderStack.isHidden = true
            }
        } else {
            activeSwitch.isOn = true
        }
    }

    // MARK: - Actions

    @objc private func uploadTapped() {
        clearErrors()

        // 📸 شيت فيه خيار Camera + Library
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
            nameErrorLabel.text = "Design name is required."
            nameErrorLabel.isHidden = false
            hasError = true
        }

        if storedImageId == nil {
            artworkErrorLabel.text = "Please upload the card artwork."
            artworkErrorLabel.isHidden = false
            hasError = true
        }

        if hasError { return }

        guard let imageId = storedImageId else { return }

        let id = existingDesign?.id ?? UUID().uuidString
        let isDefault = existingDesign?.isDefault ?? false

        let design = CardDesign(
            id: id,
            name: trimmedName,
            imageName: imageId,
            isActive: activeSwitch.isOn,
            isDefault: isDefault
        )

        onSave?(design)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Common image handling

private extension AddEditCardDesignViewController {
    func handlePicked(image: UIImage) {
        previewImageView.image = image
        previewImageView.isHidden = false
        uploadPlaceholderStack.isHidden = true
        artworkErrorLabel.isHidden = true

        // TODO: هنا بعدين تحطين رفع Cloudinary / Storage وترجعين ID الحقيقي
        storedImageId = "uploaded_\(UUID().uuidString)"
    }
}

// MARK: - Delegates

extension AddEditCardDesignViewController: PHPickerViewControllerDelegate,
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
