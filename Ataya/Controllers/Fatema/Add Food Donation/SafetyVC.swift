//
//  SafetyVC.swift
//  Ataya
//
//  Created by Fatema Maitham on 29/11/2025.
//


import UIKit

final class SafetyVC: UIViewController {

    var draft: DraftDonation!

    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    private var isUploading = false

    private var isConfirmed = false {
        didSet {
            draft.safetyConfirmed = isConfirmed
            updateUI()
        }
    }

    private let checkedGreen = UIColor.systemGreen
    private let disabledGray  = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1)
    private let enabledYellow = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()

        if draft == nil { draft = DraftDonation() }

        configureUI()
        isConfirmed = draft.safetyConfirmed
    }

    @IBAction func checkboxTapped(_ sender: UIButton) {
        guard !isUploading else { return }
        isConfirmed.toggle()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        guard isConfirmed else { return }
        guard !isUploading else { return }

        // If already uploaded (user went back), don't upload again
        if !draft.photoURLs.isEmpty {
            performSegue(withIdentifier: "toEnterDetails", sender: nil)
            return
        }

        // Must have images
        guard !draft.images.isEmpty else {
            showAlert(title: "Missing photos", message: "Please upload at least 1 photo first.")
            return
        }

        // Ensure an id for folder naming
        if draft.id == nil || draft.id?.isEmpty == true {
            draft.id = UUID().uuidString
        }

        setUploading(true)

        let folder = "donations/\(draft.id!)"
        uploadImagesToCloudinary(draft.images, folder: folder) { [weak self] result in
            guard let self else { return }
            self.setUploading(false)

            switch result {
            case .success(let output):
                self.draft.photoURLs = output.urls
                self.draft.imagePublicIds = output.publicIds

            case .failure(let err):
                self.showAlert(title: "Upload failed", message: err.localizedDescription)
            }
        }
    }

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = (segue.destination as? UINavigationController)?.topViewController ?? segue.destination
        if let vc = dest as? EnterDetailsViewController {
            vc.draft = draft
        }
    }


    // MARK: - Cloudinary Upload (completion-based)
    private func uploadImagesToCloudinary(
        _ images: [UIImage],
        folder: String,
        completion: @escaping (Result<(urls: [String], publicIds: [String]), Error>) -> Void
    ) {
        var urls = Array(repeating: "", count: images.count)
        var publicIds = Array(repeating: "", count: images.count)
        var firstError: Error?

        let group = DispatchGroup()

        for (index, img) in images.enumerated() {
            group.enter()
            CloudinaryUploader.shared.uploadImage(img, folder: folder) { result in
                switch result {
                case .success(let output):
                    urls[index] = output.secureUrl
                    publicIds[index] = output.publicId
                case .failure(let err):
                    if firstError == nil { firstError = err }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let err = firstError {
                completion(.failure(err))
                return
            }
            completion(.success((urls.filter { !$0.isEmpty }, publicIds.filter { !$0.isEmpty })))
        }
    }

    // MARK: - UI
    private func configureUI() {
        if #available(iOS 15.0, *) {
            checkboxButton.configuration = nil

            let base = nextButton.configuration
            nextButton.configurationUpdateHandler = { [weak self] button in
                guard let self else { return }
                var cfg = button.configuration ?? base ?? .filled()

                cfg.baseBackgroundColor = button.isEnabled ? self.enabledYellow : self.disabledGray
                cfg.baseForegroundColor = button.isEnabled ? .black : .white
                cfg.title = self.isUploading ? "Uploading..." : "Next"

                button.configuration = cfg
            }
        } else {
            nextButton.setTitle("Next", for: .normal)
        }

        checkboxButton.setImage(UIImage(systemName: "square"), for: .normal)
        checkboxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        checkboxButton.tintColor = .lightGray

        updateUI()
    }

    private func updateUI() {
        checkboxButton.isSelected = isConfirmed
        checkboxButton.tintColor  = isConfirmed ? checkedGreen : .lightGray

        // Next enabled only if confirmed AND not uploading
        nextButton.isEnabled = isConfirmed && !isUploading
        checkboxButton.isEnabled = !isUploading

        if #available(iOS 15.0, *) {
            nextButton.setNeedsUpdateConfiguration()
        }
    }

    private func setUploading(_ uploading: Bool) {
        isUploading = uploading
        updateUI()
    }

    // MARK: - Alert
    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
