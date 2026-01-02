//
//  UploadPhotosViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 28/11/2025.
//

import UIKit
import PhotosUI

class UploadPhotosViewController: UIViewController {
    var draft: DraftDonation!

    @IBOutlet weak var uploadCardView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var helperLabel: UILabel!
    
    private let maxImages = 3
        private var helperOriginalText: String = ""

        private var selectedImages: [UIImage] = [] {
            didSet {
                draft.images = selectedImages
                updateUI()
            }
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            if draft == nil { draft = DraftDonation() }
            selectedImages = draft.images

            helperOriginalText = helperLabel.text ?? ""
            helperLabel.isHidden = true

            styleCard()
            addTapToUploadArea()
            styleNextButtonIfNeeded()
            updateUI()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            addDashedBorder()
        }

        // MARK: - Navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toSafety",
               let vc = segue.destination as? SafetyVC {
                vc.draft = draft
            }
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

            if let pop = sheet.popoverPresentationController {
                pop.sourceView = uploadCardView
                pop.sourceRect = uploadCardView.bounds
            }

            present(sheet, animated: true)
        }

        // MARK: - UI
        private func styleCard() {
            uploadCardView.backgroundColor = .white
            uploadCardView.layer.cornerRadius = 12
            uploadCardView.clipsToBounds = true
            uploadCardView.isUserInteractionEnabled = true
        }

        private func addDashedBorder() {
            uploadCardView.layer.sublayers?.removeAll(where: { $0.name == "dashedBorder" })

            let dashed = CAShapeLayer()
            dashed.name = "dashedBorder"
            dashed.path = UIBezierPath(roundedRect: uploadCardView.bounds, cornerRadius: 12).cgPath
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
            nextButton.layer.cornerRadius = 12
            nextButton.clipsToBounds = true
        }

        private func updateUI() {
            let count = selectedImages.count
            let hasPhotos = count > 0

            nextButton.isEnabled = hasPhotos
            nextButton.alpha = hasPhotos ? 1.0 : 0.5

            if hasPhotos {
                helperLabel.isHidden = false
                let word = (count == 1) ? "photo" : "photos"
                helperLabel.textColor = .systemGreen
                helperLabel.text = "\(count) \(word) uploaded successfully."
            } else {
                helperLabel.isHidden = true
            }
        }

        // MARK: - Photo Picker / Camera
        private func presentPhotoPicker(selectionLimit: Int) {
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = .images
            config.selectionLimit = selectionLimit

            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            present(picker, animated: true)
        }

        private func presentCamera() {
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

        // MARK: - Alert
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
