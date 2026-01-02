//
//  CreateCampaignViewController.swift
//  Ataya
//
//  Created by Maram on 24/12/2025.
//


import UIKit
import PhotosUI
import FirebaseFirestore
import FirebaseAuth

final class CreateCampaignViewController: UIViewController {

    // MARK: Public callback (optional)
    struct CampaignFormData {
        let title: String
        let category: String
        let goalAmount: String
        let startDate: Date
        let endDate: Date
        let location: String
        let overview: String
        let story: String
        let from: String
        let organization: String
        let showOnHome: Bool
        let image: UIImage?
    }

    enum Mode {
        case create
        case edit(existing: CampaignFormData)
    }

    var mode: Mode = .create

    // ✅ for edit (set from CampaignManagement)
    var editingDocumentId: String?
    var editingExistingImageUrl: String?
    var editingExistingPublicId: String?

    // MARK: Backend
    private let db = Firestore.firestore()

    // MARK: UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()

    private let titleField = LabeledTextField(title: "Title", placeholder: "Enter title")

    // ✅ CHANGED: Category is now dropdown like Organization
    private let categoryField = LabeledMenuField(
        title: "Category",
        initial: "Critical",
        items: ["Critical", "Climate change", "Emergency"]
    )

    private let goalField = LabeledTextField(title: "Goal Amount", placeholder: "e.g. 80,000 $", keyboard: .numbersAndPunctuation)

    private let startDateField = LabeledDateField(title: "Start Date")
    private let endDateField = LabeledDateField(title: "End Date")

    private let locationField = LabeledTextField(title: "Location", placeholder: "e.g. Gaza, Palestine")

    private let uploadView = UploadPhotoBox()

    private let overviewText = LabeledTextView(title: "Campaign Overview", placeholder: "Write overview…")
    private let storyText = LabeledTextView(title: "Story", placeholder: "Write story…")

    private let fromField = LabeledTextField(title: "From", placeholder: "e.g. Sharm’s Mother")

    // ✅ Organization field stays, but will be AUTO + LOCKED for NGO
    private let orgField = LabeledMenuField(title: "Organization / NGO", initial: "Loading…", items: [
        "LifeReach", "HopeAid", "MercyHands", "ReliefBridge", "CarePath"
    ])

    private let showHomeRow = UIView()
    private let showHomeLabel = UILabel()
    private let showHomeSwitch = UISwitch()

    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    private let savingSpinner = UIActivityIndicatorView(style: .medium)

    // MARK: State
    private var selectedImage: UIImage? {
        didSet { uploadView.setImage(selectedImage) }
    }

    // ✅ will be set automatically from users/{uid}
    private var selectedOrg: String = ""

    // ✅ ADDED: Category selected value
    private var selectedCategory: String = "Critical"

    // ✅ مهم: عشان Edit ما يعيد يرفع الصورة القديمة (اللي نحمّلها للعرض فقط)
    private var didPickNewImage: Bool = false

    // ✅ NEW: block create until NGO org loaded
    private var isOrgReady: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupNav()
        setupScroll()
        setupStack()
        setupFields()
        setupShowHomeRow()
        setupButtons()
        layoutUI()

        // ✅ category selection
        categoryField.onSelect = { [weak self] value in
            self?.selectedCategory = value
        }

        uploadView.onTap = { [weak self] in
            self?.presentImagePicker()
        }

        switch mode {
        case .create:
            title = "Create Campaign"
            createButton.setTitle("Create Campaign", for: .normal)

            startDateField.setDate(Date())
            endDateField.setDate(Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date())

            // ✅ default category display + value
            selectedCategory = "Critical"
            categoryField.setValue("Critical")

            // ✅ LOCK org field + load automatically from users/{uid}
            orgField.setLocked(true)
            orgField.setValue("Loading…")
            selectedOrg = ""
            isOrgReady = false

            // disable create until org ready
            createButton.isEnabled = false
            autoFillOrganizationForLoggedInNgo()

        case .edit(let existing):
            title = "Edit Campaign"
            createButton.setTitle("Save Changes", for: .normal)
            fillForm(with: existing)

            // ✅ lock org in edit too (campaign belongs to the NGO)
            orgField.setLocked(true)
            isOrgReady = true

            // show old image if exists (only if user didn't choose new)
            if selectedImage == nil, let s = editingExistingImageUrl, let url = URL(string: s) {
                downloadImage(url: url) { [weak self] img in
                    guard let self else { return }
                    // ✅ this is ONLY for preview (not considered "new pick")
                    DispatchQueue.main.async {
                        if self.selectedImage == nil {
                            self.selectedImage = img
                            self.didPickNewImage = false
                        }
                    }
                }
            }
        }
    }

    // ✅ AUTO: get org from Firestore users/{uid} for NGO account
    private func autoFillOrganizationForLoggedInNgo() {
        guard let uid = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.isOrgReady = false
                self.createButton.isEnabled = false
                self.showError("You must be logged in as NGO to create a campaign.")
            }
            return
        }

        db.collection("users").document(uid).getDocument { [weak self] snap, error in
            guard let self else { return }

            if let error {
                DispatchQueue.main.async {
                    self.isOrgReady = false
                    self.createButton.isEnabled = false
                    self.orgField.setValue("—")
                    self.showError("Failed to load NGO profile.\n\(error.localizedDescription)")
                }
                return
            }

            let data = snap?.data() ?? [:]

            // ✅ role must be ngo
            let role = (data["role"] as? String ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()

            guard role == "ngo" else {
                DispatchQueue.main.async {
                    self.isOrgReady = false
                    self.createButton.isEnabled = false
                    self.orgField.setValue("—")
                    self.showError("This screen is for NGO accounts only.")
                }
                return
            }

            // ✅ organization name from user doc (try common keys)
            let org =
                (data["organization"] as? String) ??
                (data["ngoName"] as? String) ??
                (data["orgName"] as? String) ??
                (data["name"] as? String)

            guard let org, !org.atayaTrimmed.isEmpty else {
                DispatchQueue.main.async {
                    self.isOrgReady = false
                    self.createButton.isEnabled = false
                    self.orgField.setValue("—")
                    self.showError("Organization/NGO name is missing in users/{uid}.\nAdd field: organization (or ngoName).")
                }
                return
            }

            DispatchQueue.main.async {
                self.selectedOrg = org
                self.orgField.setValue(org)
                self.orgField.setLocked(true)

                self.isOrgReady = true
                self.createButton.isEnabled = true
            }
        }
    }

    private func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data else { return completion(nil) }
            completion(UIImage(data: data))
        }.resume()
    }

    private func fillForm(with data: CampaignFormData) {
        titleField.textField.text = data.title

        // ✅ CHANGED: category is dropdown
        selectedCategory = data.category
        categoryField.setValue(data.category)

        goalField.textField.text = data.goalAmount
        locationField.textField.text = data.location
        fromField.textField.text = data.from

        startDateField.setDate(data.startDate)
        endDateField.setDate(data.endDate)

        overviewText.setText(data.overview)
        storyText.setText(data.story)

        // ✅ keep org
        selectedOrg = data.organization
        orgField.setValue(data.organization)

        showHomeSwitch.isOn = data.showOnHome
        selectedImage = data.image
    }

    private func clearAllErrors() {
        titleField.clearError()
        categoryField.clearError()   // ✅ CHANGED
        goalField.clearError()
        locationField.clearError()
        startDateField.clearError()
        endDateField.clearError()
    }

    // MARK: Nav
    private func setupNav() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
    }

    @objc private func didTapBack() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: Scroll
    private func setupScroll() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupStack() {
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupFields() {
        [titleField, categoryField, goalField, startDateField, endDateField, locationField, fromField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        goalField.textField.inputAccessoryView = keyboardToolbar()

        stack.addArrangedSubview(titleField)
        stack.addArrangedSubview(categoryField) // ✅ CHANGED
        stack.addArrangedSubview(goalField)
        stack.addArrangedSubview(startDateField)
        stack.addArrangedSubview(endDateField)
        stack.addArrangedSubview(locationField)

        stack.addArrangedSubview(uploadView)

        stack.addArrangedSubview(overviewText)
        stack.addArrangedSubview(storyText)

        stack.addArrangedSubview(fromField)
        stack.addArrangedSubview(orgField)
    }

    private func setupShowHomeRow() {
        showHomeLabel.text = "Show on Home Page"
        showHomeLabel.font = .systemFont(ofSize: 13, weight: .regular)
        showHomeLabel.textColor = .label

        showHomeSwitch.isOn = true
        showHomeSwitch.onTintColor = UIColor.systemGreen

        let row = UIStackView(arrangedSubviews: [showHomeLabel, UIView(), showHomeSwitch])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10

        showHomeRow.addSubview(row)
        row.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: showHomeRow.topAnchor),
            row.leadingAnchor.constraint(equalTo: showHomeRow.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: showHomeRow.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: showHomeRow.bottomAnchor)
        ])

        stack.addArrangedSubview(showHomeRow)
    }

    private func setupButtons() {
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cancelButton.setTitleColor(UIColor.atayaHex("#C28A00"), for: .normal)
        cancelButton.backgroundColor = .white
        cancelButton.layer.cornerRadius = 8
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.atayaHex("#F7D44C").cgColor
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)

        createButton.setTitle("Create Campaign", for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        createButton.setTitleColor(.label, for: .normal)
        createButton.backgroundColor = UIColor.atayaHex("#F7D44C")
        createButton.layer.cornerRadius = 8
        createButton.layer.masksToBounds = true
        createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)

        savingSpinner.hidesWhenStopped = true
        savingSpinner.translatesAutoresizingMaskIntoConstraints = false
        createButton.addSubview(savingSpinner)

        NSLayoutConstraint.activate([
            savingSpinner.centerYAnchor.constraint(equalTo: createButton.centerYAnchor),
            savingSpinner.trailingAnchor.constraint(equalTo: createButton.trailingAnchor, constant: -16)
        ])

        let buttons = UIStackView(arrangedSubviews: [cancelButton, createButton])
        buttons.axis = .vertical
        buttons.spacing = 12
        buttons.alignment = .center

        NSLayoutConstraint.activate([
            cancelButton.widthAnchor.constraint(equalToConstant: 362),
            cancelButton.heightAnchor.constraint(equalToConstant: 54),
            createButton.widthAnchor.constraint(equalToConstant: 362),
            createButton.heightAnchor.constraint(equalToConstant: 54),
        ])

        stack.addArrangedSubview(buttons)
        stack.setCustomSpacing(18, after: showHomeRow)
    }

    private func layoutUI() {
        let preferredWidth = stack.widthAnchor.constraint(equalToConstant: 362)
        preferredWidth.priority = .defaultHigh
        let maxWidth = stack.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, constant: -32)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            preferredWidth,
            maxWidth,
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -22),

            uploadView.heightAnchor.constraint(equalToConstant: 200),
            overviewText.heightAnchor.constraint(equalToConstant: 170),
            storyText.heightAnchor.constraint(equalToConstant: 140),
        ])
    }

    // MARK: Actions
    @objc private func didTapCancel() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func didTapCreate() {
        view.endEditing(true)
        clearAllErrors()

        // ✅ must have auto org ready
        if !isOrgReady || selectedOrg.atayaTrimmed.isEmpty {
            showError("Organization is still loading. Please wait a moment.")
            return
        }

        let t = titleField.text.atayaTrimmed

        // ✅ CHANGED: take category from dropdown selected value
        let c = selectedCategory.atayaTrimmed

        let g = goalField.text.atayaTrimmed
        let loc = locationField.text.atayaTrimmed
        let ov = overviewText.text.atayaTrimmed
        let st = storyText.text.atayaTrimmed
        let fr = fromField.text.atayaTrimmed

        var hasError = false
        if t.isEmpty { titleField.setError("Title is required"); hasError = true }
        if c.isEmpty { categoryField.setError("Category is required"); hasError = true }
        if g.isEmpty { goalField.setError("Goal Amount is required"); hasError = true }
        if loc.isEmpty { locationField.setError("Location is required"); hasError = true }

        let start = startDateField.dateValue
        let end = endDateField.dateValue
        if end < start { endDateField.setError("End Date must be after Start Date"); hasError = true }

        if hasError { return }

        // ✅ organization forced from NGO profile
        let form = CampaignFormData(
            title: t,
            category: c,
            goalAmount: g,
            startDate: start,
            endDate: end,
            location: loc,
            overview: ov.isEmpty ? "—" : ov,
            story: st.isEmpty ? "—" : st,
            from: fr.isEmpty ? "—" : fr,
            organization: selectedOrg,
            showOnHome: showHomeSwitch.isOn,
            image: selectedImage
        )

        submitToBackend(form: form)
    }

    private func submitToBackend(form: CampaignFormData) {
        setSaving(true)

        // ✅ Decide if we should upload new image:
        // - create: if selectedImage exists => upload
        // - edit: upload ONLY if user picked a new image
        let shouldUploadNewImage: Bool = {
            switch mode {
            case .create:
                return selectedImage != nil
            case .edit:
                return didPickNewImage && selectedImage != nil
            }
        }()

        // ✅ Uses your existing CloudinaryUploader.shared (from Cloudinary files)
        if shouldUploadNewImage, let img = selectedImage {
            CloudinaryUploader.shared.uploadImage(img, folder: "campaigns") { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let up):
                    self.saveToFirestore(form: form, imageURL: up.secureUrl, publicId: up.publicId)

                case .failure(let err):
                    self.setSaving(false)
                    self.showError("Cloudinary upload failed.\n\(err.localizedDescription)")
                }
            }
        } else {
            // no new image -> keep old (edit)
            saveToFirestore(form: form, imageURL: editingExistingImageUrl, publicId: editingExistingPublicId)
        }
    }

    // ✅ IMPORTANT: NO anonymous sign-in here (must be logged in)
    private func ensureSignedIn(completion: @escaping (Result<String, Error>) -> Void) {
        if let uid = Auth.auth().currentUser?.uid {
            completion(.success(uid))
        } else {
            completion(.failure(NSError(
                domain: "Auth",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Not logged in"]
            )))
        }
    }

    private func saveToFirestore(form: CampaignFormData, imageURL: String?, publicId: String?) {

        ensureSignedIn { [weak self] authResult in
            guard let self else { return }

            switch authResult {
            case .failure(let err):
                DispatchQueue.main.async {
                    self.setSaving(false)
                    self.showError("Sign-in failed.\n\(err.localizedDescription)")
                }
                return

            case .success(let uid):
                let goalDouble = CampaignAmountParser.parse(form.goalAmount)

                // ✅ Decide create vs edit safely
                let isEdit: Bool
                let docRef: DocumentReference

                switch self.mode {
                case .create:
                    isEdit = false
                    docRef = self.db.collection("campaigns").document()

                case .edit:
                    if let id = self.editingDocumentId, !id.atayaTrimmed.isEmpty {
                        isEdit = true
                        docRef = self.db.collection("campaigns").document(id)
                    } else {
                        isEdit = false
                        docRef = self.db.collection("campaigns").document()
                    }
                }

                var data: [String: Any] = [
                    "title": form.title,
                    "category": form.category,
                    "goalAmount": goalDouble,
                    "startDate": Timestamp(date: form.startDate),
                    "endDate": Timestamp(date: form.endDate),
                    "location": form.location,
                    "overview": form.overview,
                    "story": form.story,
                    "from": form.from,

                    // ✅ force org from logged-in NGO
                    "organization": self.selectedOrg,
                    "ngoId": uid,

                    "showOnHome": form.showOnHome,
                    "updatedAt": FieldValue.serverTimestamp(),
                    "lastUpdatedBy": uid
                ]

                if !isEdit {
                    data["raisedAmount"] = 0.0
                    data["createdAt"] = FieldValue.serverTimestamp()
                    data["createdBy"] = uid
                }

                // ✅ Save image keys in BOTH forms to avoid mismatches
                if let imageURL {
                    data["imageUrl"] = imageURL
                    data["imageURL"] = imageURL
                } else {
                    data["imageUrl"] = NSNull()
                    data["imageURL"] = NSNull()
                }

                if let publicId {
                    data["imagePublicId"] = publicId
                } else {
                    data["imagePublicId"] = NSNull()
                }

                docRef.setData(data, merge: true) { [weak self] err in
                    guard let self else { return }

                    DispatchQueue.main.async { self.setSaving(false) }

                    if let err {
                        print("❌ Firestore save error:", err)
                        DispatchQueue.main.async { self.showError("Save failed.\n\(err.localizedDescription)") }
                        return
                    }

                    let isEditMode: Bool = {
                        if case .edit = self.mode { return true }
                        return false
                    }()

                    DispatchQueue.main.async {
                        self.showCreatedPopup(isEdit: isEditMode) {
                            if let nav = self.navigationController, nav.viewControllers.count > 1 {
                                nav.popViewController(animated: true)
                            } else {
                                self.dismiss(animated: true)
                            }
                        }
                    }
                }
            }
        }
    }

    private func setSaving(_ saving: Bool) {
        createButton.isEnabled = !saving && isOrgReady
        cancelButton.isEnabled = !saving
        createButton.alpha = saving ? 0.7 : 1
        cancelButton.alpha = saving ? 0.7 : 1

        if saving {
            savingSpinner.startAnimating()
        } else {
            savingSpinner.stopAnimating()
        }
    }

    private func showError(_ msg: String) {
        let a = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    // MARK: ✅ Popup
    private func showCreatedPopup(isEdit: Bool, onViewCampaign: @escaping () -> Void) {
        let pop = CampaignCreatedPopupViewController()

        pop.titleText = isEdit ? "Changes Saved\nSuccessfully!" : "Campaign Created\nSuccessfully!"
        pop.subtitleText = isEdit
            ? "Your campaign details have been updated.\nAll changes are now live and visible."
            : "Your campaign has been created.\nIt’s now active and visible to users."
        pop.buttonText = "View Campaign"

        pop.modalPresentationStyle = .overFullScreen
        pop.modalTransitionStyle = .crossDissolve

        pop.onViewCampaign = { [weak pop] in
            pop?.dismiss(animated: true) {
                onViewCampaign()
            }
        }

        present(pop, animated: true)
    }

    // MARK: Image Picker
    private func presentImagePicker() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            self?.openPhotoLibrary()
        }))

        sheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            self?.openCamera()
        }))

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let pop = sheet.popoverPresentationController {
            pop.sourceView = uploadView
            pop.sourceRect = uploadView.bounds
        }

        present(sheet, animated: true)
    }

    private func openPhotoLibrary() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let a = UIAlertController(title: "Camera not available", message: "Try Photo Library on simulator.", preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "OK", style: .default))
            present(a, animated: true)
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: Toolbar
    private func keyboardToolbar() -> UIToolbar {
        let tb = UIToolbar()
        tb.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(endEditingNow))
        tb.items = [flex, done]
        return tb
    }

    @objc private func endEditingNow() {
        view.endEditing(true)
    }
}

// MARK: - Pickers
extension CreateCampaignViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let item = results.first?.itemProvider else { return }
        if item.canLoadObject(ofClass: UIImage.self) {
            item.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
                DispatchQueue.main.async {
                    self?.didPickNewImage = true
                    self?.selectedImage = object as? UIImage
                }
            }
        }
    }
}

extension CreateCampaignViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        didPickNewImage = true
        selectedImage = info[.originalImage] as? UIImage
    }
}

// MARK: - Popup VC (same file)
private final class CampaignCreatedPopupViewController: UIViewController {

    var onViewCampaign: (() -> Void)?

    var titleText: String = "Campaign Created\nSuccessfully!"
    var subtitleText: String = "Your campaign has been created.\nIt’s now active and visible to users."
    var buttonText: String = "View Campaign"

    private let dim = UIView()
    private let card = UIView()

    // ✅ icon layers (to FORCE the exact green like your screenshot)
    private let iconWrap = UIView()
    private let sealImg = UIImageView()
    private let checkImg = UIImageView()

    private let titleLbl = UILabel()
    private let subLbl = UILabel()

    private let viewButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        // dim
        dim.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        view.addSubview(dim)
        dim.translatesAutoresizingMaskIntoConstraints = false

        // card
        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        card.layer.masksToBounds = true
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false

        // ✅ EXACT green like screenshot
        let checkGreen = UIColor.atayaHex("#4F8E4F")   // dark check
        let fillGreen  = UIColor.atayaHex("#CFE6CF")   // light seal

        sealImg.image = UIImage(systemName: "seal.fill")
        sealImg.tintColor = fillGreen
        sealImg.contentMode = .scaleAspectFit

        checkImg.image = UIImage(systemName: "checkmark")
        checkImg.tintColor = checkGreen
        checkImg.contentMode = .scaleAspectFit

        // give them matching weights/sizes
        sealImg.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 150, weight: .regular)
        checkImg.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 85, weight: .bold)

        iconWrap.addSubview(sealImg)
        iconWrap.addSubview(checkImg)
        sealImg.translatesAutoresizingMaskIntoConstraints = false
        checkImg.translatesAutoresizingMaskIntoConstraints = false
        iconWrap.translatesAutoresizingMaskIntoConstraints = false

        // title/sub
        titleLbl.text = titleText
        titleLbl.font = .systemFont(ofSize: 28, weight: .bold)
        titleLbl.textAlignment = .center
        titleLbl.textColor = .label
        titleLbl.numberOfLines = 2

        subLbl.text = subtitleText
        subLbl.font = .systemFont(ofSize: 15, weight: .regular)
        subLbl.textAlignment = .center
        subLbl.textColor = .secondaryLabel
        subLbl.numberOfLines = 2

        // button (✅ radius 8)
        viewButton.setTitle(buttonText, for: .normal)
        viewButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        viewButton.setTitleColor(.label, for: .normal)
        viewButton.backgroundColor = UIColor.atayaHex("#F7D44C")
        viewButton.layer.cornerRadius = 8
        viewButton.layer.masksToBounds = true
        viewButton.addTarget(self, action: #selector(tapView), for: .touchUpInside)

        [iconWrap, titleLbl, subLbl, viewButton].forEach {
            card.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // ✅ responsive width like screenshot
        let maxW = card.widthAnchor.constraint(lessThanOrEqualToConstant: 360)
        maxW.priority = .required

        NSLayoutConstraint.activate([
            dim.topAnchor.constraint(equalTo: view.topAnchor),
            dim.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dim.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dim.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 22),
            card.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -22),
            maxW,
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 420),

            iconWrap.topAnchor.constraint(equalTo: card.topAnchor, constant: 56),
            iconWrap.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconWrap.widthAnchor.constraint(equalToConstant: 160),
            iconWrap.heightAnchor.constraint(equalToConstant: 160),

            sealImg.topAnchor.constraint(equalTo: iconWrap.topAnchor),
            sealImg.leadingAnchor.constraint(equalTo: iconWrap.leadingAnchor),
            sealImg.trailingAnchor.constraint(equalTo: iconWrap.trailingAnchor),
            sealImg.bottomAnchor.constraint(equalTo: iconWrap.bottomAnchor),

            checkImg.centerXAnchor.constraint(equalTo: iconWrap.centerXAnchor),
            checkImg.centerYAnchor.constraint(equalTo: iconWrap.centerYAnchor),
            checkImg.widthAnchor.constraint(equalToConstant: 90),
            checkImg.heightAnchor.constraint(equalToConstant: 90),

            titleLbl.topAnchor.constraint(equalTo: iconWrap.bottomAnchor, constant: 18),
            titleLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            titleLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),

            subLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 12),
            subLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            subLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),

            viewButton.topAnchor.constraint(equalTo: subLbl.bottomAnchor, constant: 28),
            viewButton.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            viewButton.widthAnchor.constraint(equalToConstant: 280),
            viewButton.heightAnchor.constraint(equalToConstant: 56),
            viewButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -34)
        ])
    }

    @objc private func tapView() {
        onViewCampaign?()
    }
}

// MARK: - UI Components (same file)
private final class LabeledTextField: UIView {
    let textField = UITextField()
    private let label = UILabel()
    private let box = UIView()
    private let errorLabel = UILabel()

    var text: String { textField.text ?? "" }

    init(title: String, placeholder: String, keyboard: UIKeyboardType = .default) {
        super.init(frame: .zero)

        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label

        box.backgroundColor = .white
        box.layer.cornerRadius = 8
        box.layer.borderWidth = 1
        box.layer.borderColor = UIColor.atayaHex("#E6E6E6").cgColor

        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 14, weight: .regular)
        textField.textColor = .label
        textField.keyboardType = keyboard
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .sentences
        textField.returnKeyType = .done

        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 12, weight: .regular)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        let v = UIStackView(arrangedSubviews: [label, box, errorLabel])
        v.axis = .vertical
        v.spacing = 6
        v.alignment = .fill
        addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false

        box.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: topAnchor),
            v.leadingAnchor.constraint(equalTo: leadingAnchor),
            v.trailingAnchor.constraint(equalTo: trailingAnchor),
            v.bottomAnchor.constraint(equalTo: bottomAnchor),

            box.heightAnchor.constraint(equalToConstant: 60),

            textField.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -12),
            textField.topAnchor.constraint(equalTo: box.topAnchor),
            textField.bottomAnchor.constraint(equalTo: box.bottomAnchor),
        ])
    }

    func setError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    func clearError() {
        errorLabel.text = nil
        errorLabel.isHidden = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class LabeledDateField: UIView {

    @objc private func openCalendarPicker() { textField.becomeFirstResponder() }

    private let label = UILabel()
    private let box = UIView()
    private let textField = UITextField()

    private let picker = UIDatePicker()
    private var currentDate: Date = Date()

    private let errorLabel = UILabel()

    var dateValue: Date { currentDate }

    init(title: String) {
        super.init(frame: .zero)

        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label

        box.backgroundColor = .white
        box.layer.cornerRadius = 8
        box.layer.borderWidth = 1
        box.layer.borderColor = UIColor.atayaHex("#E6E6E6").cgColor

        textField.font = .systemFont(ofSize: 14, weight: .regular)
        textField.textColor = .label
        textField.autocorrectionType = .no

        let calendarBtn = UIButton(type: .system)
        calendarBtn.setImage(UIImage(systemName: "calendar"), for: .normal)
        calendarBtn.tintColor = .secondaryLabel
        calendarBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 60)
        calendarBtn.addTarget(self, action: #selector(openCalendarPicker), for: .touchUpInside)

        textField.rightView = calendarBtn
        textField.rightViewMode = .always

        picker.datePickerMode = .date
        if #available(iOS 13.4, *) { picker.preferredDatePickerStyle = .wheels }
        textField.inputView = picker
        textField.inputAccessoryView = toolbar()
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 12, weight: .regular)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        let v = UIStackView(arrangedSubviews: [label, box, errorLabel])
        v.axis = .vertical
        v.spacing = 6
        v.alignment = .fill
        addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false

        box.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: topAnchor),
            v.leadingAnchor.constraint(equalTo: leadingAnchor),
            v.trailingAnchor.constraint(equalTo: trailingAnchor),
            v.bottomAnchor.constraint(equalTo: bottomAnchor),

            box.heightAnchor.constraint(equalToConstant: 60),

            textField.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -8),
            textField.topAnchor.constraint(equalTo: box.topAnchor),
            textField.bottomAnchor.constraint(equalTo: box.bottomAnchor),
        ])
    }

    func setDate(_ date: Date) {
        currentDate = date
        picker.date = date
        textField.text = date.atayaFormattedShort
    }

    @objc private func dateChanged() {
        currentDate = picker.date
        textField.text = currentDate.atayaFormattedShort
    }

    func setError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    func clearError() {
        errorLabel.text = nil
        errorLabel.isHidden = true
    }

    private func toolbar() -> UIToolbar {
        let tb = UIToolbar()
        tb.sizeToFit()
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTap))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTap))
        tb.items = [cancel, flex, done]
        return tb
    }

    @objc private func cancelTap() { textField.resignFirstResponder() }

    @objc private func doneTap() {
        currentDate = picker.date
        textField.text = currentDate.atayaFormattedShort
        textField.resignFirstResponder()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class LabeledTextView: UIView {

    private let label = UILabel()
    private let box = UIView()
    private let tv = UITextView()
    private let placeholderLabel = UILabel()

    var text: String { tv.text ?? "" }

    init(title: String, placeholder: String) {
        super.init(frame: .zero)

        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label

        box.backgroundColor = .white
        box.layer.cornerRadius = 8
        box.layer.borderWidth = 1
        box.layer.borderColor = UIColor.atayaHex("#E6E6E6").cgColor

        tv.font = .systemFont(ofSize: 14, weight: .regular)
        tv.textColor = .label
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)

        placeholderLabel.text = placeholder
        placeholderLabel.textColor = .secondaryLabel
        placeholderLabel.font = .systemFont(ofSize: 14, weight: .regular)

        tv.delegate = self

        addSubview(label)
        addSubview(box)
        box.addSubview(tv)
        box.addSubview(placeholderLabel)

        label.translatesAutoresizingMaskIntoConstraints = false
        box.translatesAutoresizingMaskIntoConstraints = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),

            box.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 6),
            box.leadingAnchor.constraint(equalTo: leadingAnchor),
            box.trailingAnchor.constraint(equalTo: trailingAnchor),
            box.bottomAnchor.constraint(equalTo: bottomAnchor),

            tv.topAnchor.constraint(equalTo: box.topAnchor),
            tv.leadingAnchor.constraint(equalTo: box.leadingAnchor),
            tv.trailingAnchor.constraint(equalTo: box.trailingAnchor),
            tv.bottomAnchor.constraint(equalTo: box.bottomAnchor),

            placeholderLabel.topAnchor.constraint(equalTo: box.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: box.trailingAnchor, constant: -16),
        ])
    }

    func setText(_ value: String) {
        tv.text = value
        placeholderLabel.isHidden = !value.atayaTrimmed.isEmpty
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension LabeledTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.atayaTrimmed.isEmpty
    }
}

// ✅ Menu field now has error support + LOCK support
private final class LabeledMenuField: UIView {

    private let label = UILabel()
    private let box = UIView()
    private let button = UIButton(type: .system)
    private let errorLabel = UILabel()

    // ✅ keep chevron as a property so we can hide it when locked
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.down"))

    var onSelect: ((String) -> Void)?

    init(title: String, initial: String, items: [String]) {
        super.init(frame: .zero)

        // label
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label

        // box
        box.backgroundColor = .white
        box.layer.cornerRadius = 8
        box.layer.borderWidth = 1
        box.layer.borderColor = UIColor.atayaHex("#E6E6E6").cgColor

        // button
        button.setTitle(initial, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 44)

        // chevron
        chevron.tintColor = .secondaryLabel
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false

        box.addSubview(button)
        box.addSubview(chevron)
        button.translatesAutoresizingMaskIntoConstraints = false

        // error label
        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 12, weight: .regular)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        // menu
        let actions = items.map { value in
            UIAction(title: value) { [weak self] _ in
                self?.button.setTitle(value, for: .normal)
                self?.clearError()
                self?.onSelect?(value)
            }
        }
        button.menu = UIMenu(children: actions)
        button.showsMenuAsPrimaryAction = true

        // stack
        let v = UIStackView(arrangedSubviews: [label, box, errorLabel])
        v.axis = .vertical
        v.spacing = 6
        v.alignment = .fill
        addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: topAnchor),
            v.leadingAnchor.constraint(equalTo: leadingAnchor),
            v.trailingAnchor.constraint(equalTo: trailingAnchor),
            v.bottomAnchor.constraint(equalTo: bottomAnchor),

            box.heightAnchor.constraint(equalToConstant: 60),

            button.topAnchor.constraint(equalTo: box.topAnchor),
            button.leadingAnchor.constraint(equalTo: box.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: box.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: box.bottomAnchor),

            chevron.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -12),
            chevron.widthAnchor.constraint(equalToConstant: 14),
            chevron.heightAnchor.constraint(equalToConstant: 14),
        ])
    }

    func setValue(_ value: String) {
        button.setTitle(value, for: .normal)
        clearError()
    }

    // ✅ NEW: lock / unlock (for NGO org auto)
    func setLocked(_ locked: Bool) {
        button.isUserInteractionEnabled = !locked
        chevron.isHidden = locked
    }

    func setError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    func clearError() {
        errorLabel.text = nil
        errorLabel.isHidden = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class UploadPhotoBox: UIView {

    var onTap: (() -> Void)?

    private let dashedLayer = CAShapeLayer()
    private let icon = UIImageView(image: UIImage(systemName: "camera.fill"))
    private let title = UILabel()
    private let subtitle = UILabel()
    private let imagePreview = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        layer.cornerRadius = 10
        layer.masksToBounds = true

        dashedLayer.strokeColor = UIColor.atayaHex("#CFCFCF").cgColor
        dashedLayer.fillColor = UIColor.clear.cgColor
        dashedLayer.lineWidth = 1
        dashedLayer.lineDashPattern = [14, 7]
        layer.addSublayer(dashedLayer)

        icon.tintColor = UIColor.atayaHex("#F7D44C")
        icon.contentMode = .scaleAspectFit

        title.text = "Tap to Upload or Take a Photo"
        title.font = .systemFont(ofSize: 13, weight: .semibold)
        title.textColor = .label
        title.textAlignment = .center

        subtitle.text = "Upload image in (JPG or PNG)"
        subtitle.font = .systemFont(ofSize: 12, weight: .regular)
        subtitle.textColor = .secondaryLabel
        subtitle.textAlignment = .center

        imagePreview.contentMode = .scaleAspectFill
        imagePreview.clipsToBounds = true
        imagePreview.isHidden = true

        addSubview(imagePreview)
        addSubview(icon)
        addSubview(title)
        addSubview(subtitle)

        imagePreview.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imagePreview.topAnchor.constraint(equalTo: topAnchor),
            imagePreview.leadingAnchor.constraint(equalTo: leadingAnchor),
            imagePreview.trailingAnchor.constraint(equalTo: trailingAnchor),
            imagePreview.bottomAnchor.constraint(equalTo: bottomAnchor),

            icon.centerXAnchor.constraint(equalTo: centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -14),
            icon.widthAnchor.constraint(equalToConstant: 91.01),
            icon.heightAnchor.constraint(equalToConstant: 103.55),

            title.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            subtitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            subtitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        dashedLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 2, dy: 2), cornerRadius: 10).cgPath
        dashedLayer.frame = bounds
    }

    @objc private func didTap() { onTap?() }

    func setImage(_ img: UIImage?) {
        if let img {
            imagePreview.image = img
            imagePreview.isHidden = false
            icon.isHidden = true
            title.isHidden = true
            subtitle.isHidden = true
        } else {
            imagePreview.isHidden = true
            icon.isHidden = false
            title.isHidden = false
            subtitle.isHidden = false
        }
    }
}

// MARK: - Helpers
private enum CampaignAmountParser {
    static func parse(_ text: String) -> Double {
        let cleaned = text
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "$", with: "")
        return Double(cleaned) ?? 0
    }
}

// MARK: - Local safe helpers (no conflicts with your project)
private extension String {
    var atayaTrimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

private extension Date {
    var atayaFormattedShort: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: self)
    }
}

extension UIColor {
    static func atayaHex(_ hex: String) -> UIColor {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
