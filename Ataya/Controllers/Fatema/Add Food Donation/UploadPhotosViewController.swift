//
//  UploadPhotosViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 28/11/2025.
//

import UIKit
import PhotosUI
import FirebaseStorage

class UploadPhotosViewController: UIViewController {
    var draft: DraftDonation?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSafety",
           let vc = segue.destination as? SafetyVC {
            vc.draft = draft
        }
    }

    
    @IBOutlet weak var uploadCardView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    private let maxImages = 3
    private var selectedImages: [UIImage] = [] {
        didSet { updateUI() }
    }
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        styleCard()
        addTapToUploadArea()
        styleNextButtonIfNeeded()
        updateUI()
        if draft == nil { draft = DraftDonation() }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addDashedBorder()
    }
    
    // MARK: - UI Setup
    private func styleCard() {
        uploadCardView.backgroundColor = .white
        uploadCardView.layer.cornerRadius = 12
        uploadCardView.clipsToBounds = true
        uploadCardView.isUserInteractionEnabled = true
    }
    
    private func addDashedBorder() {
        // Remove old dashed border
        uploadCardView.layer.sublayers?.removeAll(where: { $0.name == "dashedBorder" })
        
        let dashed = CAShapeLayer()
        dashed.name = "dashedBorder"
        dashed.path = UIBezierPath(
            roundedRect: uploadCardView.bounds,
            cornerRadius: 12
        ).cgPath
        dashed.strokeColor = UIColor.systemGray3.cgColor
        dashed.fillColor = UIColor.clear.cgColor
        dashed.lineWidth = 1
        dashed.lineDashPattern = [6, 4]
        
        uploadCardView.layer.addSublayer(dashed)
    }
    
    private func addTapToUploadArea() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(uploadAreaTapped))
        uploadCardView.addGestureRecognizer(tap)
    }
    
    private func styleNextButtonIfNeeded() {
        // Optional: keep your UI, just make sure disabled looks disabled
        nextButton.layer.cornerRadius = 12
        nextButton.clipsToBounds = true
    }
    
    private func updateUI() {
        let hasPhotos = !selectedImages.isEmpty
        nextButton.isEnabled = hasPhotos
        nextButton.alpha = hasPhotos ? 1.0 : 0.5
    }
    
    @objc private func uploadAreaTapped() {
            let remaining = maxImages - selectedImages.count
            guard remaining > 0 else {
                showAlert(title: "Max reached", message: "You can upload up to \(maxImages) images.")
                return
            }

            let sheet = UIAlertController(title: "Add Photos", message: nil, preferredStyle: .actionSheet)

            sheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
                self?.presentPhotoPicker(selectionLimit: remaining)
            })

            sheet.addAction(UIAlertAction(title: "Take a Photo", style: .default) { [weak self] _ in
                self?.presentCamera()
            })

            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            // iPad safety
            if let pop = sheet.popoverPresentationController {
                pop.sourceView = uploadCardView
                pop.sourceRect = uploadCardView.bounds
            }

            present(sheet, animated: true)
        }

//        // MARK: - Next
//        @IBAction func nextTapped(_ sender: UIButton) {
//            guard !selectedImages.isEmpty else { return }
//
//            Task {
//                do {
//                    // 1) Ensure signed-in (anonymous)
//                    try await AuthManager.shared.ensureSignedIn()
//
//                    // 2) Make sure draft has an id
//                    if draft.id.isEmpty {
//                        draft.id = UUID().uuidString
//                    }
//
//                    // 3) Upload photos -> URLs
//                    let urls = try await uploadSelectedImagesToFirebase()
//                    draft.photoURLs = urls
//
//                    print("✅ Uploaded photo URLs:", urls)
//
//                    // 4) Go next screen (use your segue / push)
//                    await MainActor.run {
//                        self.performSegue(withIdentifier: "toSafety", sender: nil)
//                    }
//
//
//                } catch {
//                    showAlert(title: "Upload Failed", message: error.localizedDescription)
//                }
//            }
//        }

        // MARK: - Photo Picker
        private func presentPhotoPicker(selectionLimit: Int) {
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = .images
            config.selectionLimit = selectionLimit

            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            present(picker, animated: true)
        }

    private func presentCamera() {
        // ✅ Put the guard HERE (first line inside the function)
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "Camera not available", message: "Use a real iPhone for camera testing.")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true)
    }


//        // MARK: - Firebase Storage Upload
//        private func uploadSelectedImagesToFirebase() async throws -> [String] {
//            let uid = AuthManager.shared.uid
//            let storage = Storage.storage()
//
//            var urls: [String] = []
//            urls.reserveCapacity(selectedImages.count)
//
//            for (index, image) in selectedImages.enumerated() {
//                guard let data = image.jpegData(compressionQuality: 0.85) else { continue }
//
//                let filename = "photo_\(index+1)_\(UUID().uuidString).jpg"
//                let path = "donations/\(uid)/\(draft.id)/\(filename)"
//                let ref = storage.reference().child(path)
//
//                let meta = StorageMetadata()
//                meta.contentType = "image/jpeg"
//
//                _ = try await ref.putDataAsync(data, metadata: meta)
//                let url = try await ref.downloadURL()
//                urls.append(url.absoluteString)
//            }
//
//            return urls
//        }

        // MARK: - Helpers
        private func showAlert(title: String, message: String) {
            let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "OK", style: .default))
            present(a, animated: true)
        }
    }

    // MARK: - PHPicker Delegate
    extension UploadPhotosViewController: PHPickerViewControllerDelegate {
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            dismiss(animated: true)
            guard !results.isEmpty else { return }

            let group = DispatchGroup()
            var newImages: [UIImage] = []

            for r in results {
                let provider = r.itemProvider
                guard provider.canLoadObject(ofClass: UIImage.self) else { continue }

                group.enter()
                provider.loadObject(ofClass: UIImage.self) { object, _ in
                    defer { group.leave() }
                    if let img = object as? UIImage {
                        newImages.append(img)
                    }
                }
            }

            group.notify(queue: .main) { [weak self] in
                guard let self else { return }
                let space = self.maxImages - self.selectedImages.count
                self.selectedImages.append(contentsOf: newImages.prefix(space))
            }
        }
    }

    // MARK: - Camera Delegate
extension UploadPhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        guard selectedImages.count < maxImages else { return }
        
        selectedImages.append(image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
