//
//  NGOdetailsViewController.swift
//  Ataya
//
//  Created by Ruqaya Habib on 18/12/2025.
//

import UIKit
import UniformTypeIdentifiers
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class NGOdetailsViewController: UIViewController, UIDocumentPickerDelegate {
    
    
    @IBOutlet weak var typeButton: UIButton!
    
    private var selectedType: String? = nil
    
    
    @IBOutlet weak var personalIDCard: UIView!
    
    @IBOutlet weak var trainingCard: UIView!
    
    
    @IBOutlet weak var missionCard: UIView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    private enum UploadKind { case personalID, training, mission }
    private var currentUploadKind: UploadKind?
    
    private var personalIDURL: URL?
    private var trainingURL: URL?
    private var missionURL: URL?
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        applyTypeButton(title: "Select Type", isPlaceholder: true)
        
        // Menu
        setupTypeDropdown()
        
        
        styleDocumentCard(personalIDCard)
        styleDocumentCard(trainingCard)
        styleDocumentCard(missionCard)
        
        styleSubmitButton()
        definesPresentationContext = true
        
        addTap(to: personalIDCard, kind: .personalID)
        addTap(to: trainingCard, kind: .training)
        addTap(to: missionCard, kind: .mission)
        
        
    }
    
    
    private func addTap(to view: UIView, kind: UploadKind) {
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        tap.name = String(describing: kind)
        view.addGestureRecognizer(tap)
    }
    
    @objc private func cardTapped(_ sender: UITapGestureRecognizer) {
        guard let name = sender.name else { return }
        
        if name.contains("personalID") { currentUploadKind = .personalID }
        else if name.contains("training") { currentUploadKind = .training }
        else { currentUploadKind = .mission }
        
        presentDocumentPicker()
    }
    
    private func presentDocumentPicker() {
        let allowedTypes: [UTType] = [.pdf, .image, .data]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes, asCopy: true)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    
    
    private func styleDocumentCard(_ view: UIView) {
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.backgroundColor = .white
    }
    
    
    private func styleSubmitButton() {
        submitButton.layer.cornerRadius = 8
        submitButton.clipsToBounds = true
    }
    
    
    
    // MARK: - UI (Button Style + Placeholder)
    private func applyTypeButton(title: String, isPlaceholder: Bool) {
        
        typeButton.layer.cornerRadius = 8
        typeButton.layer.borderWidth = 1
        typeButton.layer.borderColor = UIColor.systemGray3.cgColor
        typeButton.backgroundColor = .white
        
        typeButton.contentHorizontalAlignment = .fill
        
        var config = UIButton.Configuration.plain()
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let textColor: UIColor = isPlaceholder ? .systemGray2 : .label
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([.foregroundColor: textColor])
        )
        
        // Arrow (Right)
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 10
        
        typeButton.configuration = config
        typeButton.tintColor = .systemGray
        
        typeButton.showsMenuAsPrimaryAction = true
    }
    
    // MARK: - Dropdown Menu
    private func setupTypeDropdown() {
        
        let option1 = UIAction(title: "Humanitarian / Non-Profit") { [weak self] _ in
            self?.selectedType = "Humanitarian / Non-Profit"
            self?.applyTypeButton(title: "Humanitarian / Non-Profit", isPlaceholder: false)
        }
        
        let option2 = UIAction(title: "Medical & Psychological") { [weak self] _ in
            self?.selectedType = "Medical & Psychological"
            self?.applyTypeButton(title: "Medical & Psychological", isPlaceholder: false)
        }
        
        let option3 = UIAction(title: "Community Support & Donation") { [weak self] _ in
            self?.selectedType = "Community Support & Donation"
            self?.applyTypeButton(title: "Community Support & Donation", isPlaceholder: false)
        }
        
        let menu = UIMenu(title: "", options: .displayInline, children: [
            option1, option2, option3
        ])
        
        typeButton.menu = menu
    }
    
    
    private func uploadFileToStorage(uid: String, kind: String, fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        
        
        let ext = fileURL.pathExtension.isEmpty ? "dat" : fileURL.pathExtension
        let fileName = "\(kind).\(ext)"
        let ref = storage.reference().child("ngo_docs/\(uid)/\(fileName)")
        
        // رفع الملف
        ref.putFile(from: fileURL, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // ناخذ رابط التحميل
            ref.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let url = url else {
                    completion(.failure(NSError(domain: "downloadURL", code: -1)))
                    return
                }
                completion(.success(url.absoluteString))
            }
        }
    }
    
    private func showSimpleAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    
    @IBAction func submitTapped(_ sender: UIButton) {
        // 1) لازم يكون مسجل دخول
        guard let uid = Auth.auth().currentUser?.uid else {
            showSimpleAlert("Error", "No logged-in user.")
            return
        }
        
        
        guard let selectedTypeValue = selectedType else {
            showSimpleAlert("Missing Type", "Please select NGO type.")
            return
        }
        
        
        // 3) لازم يختار 3 ملفات (إذا تبين تخليها optional قولي)
        guard let personal = personalIDURL,
              let training = trainingURL,
              let mission = missionURL else {
            showSimpleAlert("Missing Documents", "Please upload all required documents.")
            return
        }
        
        submitButton.isEnabled = false
        submitButton.alpha = 0.5
        
        // 4) ارفع الملفات الثلاثة (واحد واحد)
        uploadFileToStorage(uid: uid, kind: "personal_id", fileURL: personal) { [weak self] res1 in
            guard let self = self else { return }
            
            switch res1 {
            case .failure(let e):
                self.submitButton.isEnabled = true
                self.submitButton.alpha = 1
                self.showSimpleAlert("Upload Failed", e.localizedDescription)
                return
                
            case .success(let personalURL):
                
                self.uploadFileToStorage(uid: uid, kind: "training", fileURL: training) { [weak self] res2 in
                    guard let self = self else { return }
                    
                    switch res2 {
                    case .failure(let e):
                        self.submitButton.isEnabled = true
                        self.submitButton.alpha = 1
                        self.showSimpleAlert("Upload Failed", e.localizedDescription)
                        return
                        
                    case .success(let trainingURL):
                        
                        self.uploadFileToStorage(uid: uid, kind: "mission", fileURL: mission) { [weak self] res3 in
                            guard let self = self else { return }
                            
                            switch res3 {
                            case .failure(let e):
                                self.submitButton.isEnabled = true
                                self.submitButton.alpha = 1
                                self.showSimpleAlert("Upload Failed", e.localizedDescription)
                                return
                                
                            case .success(let missionURL):
                                
                                let data: [String: Any] = [
                                    "orgType": selectedTypeValue,
                                    "documents": [
                                        "personalID": personalURL,
                                        "training": trainingURL,
                                        "mission": missionURL
                                    ],
                                    "detailsSubmittedAt": FieldValue.serverTimestamp(),
                                    "approvalStatus": "pending",
                                    "detailsCompleted": true
                                ]
                                
                                self.db.collection("users").document(uid).setData(data, merge: true) { err in
                                    self.submitButton.isEnabled = true
                                    self.submitButton.alpha = 1
                                    
                                    if let err = err {
                                        self.showSimpleAlert("Firestore Error", err.localizedDescription)
                                        return
                                    }
                                    
                                    
                                    let sb = UIStoryboard(name: "Main", bundle: nil)
                                    let vc = sb.instantiateViewController(withIdentifier: "NGOSubmittedViewController")
                                    vc.modalPresentationStyle = .overFullScreen
                                    vc.modalTransitionStyle = .crossDissolve
                                    self.present(vc, animated: true)
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first, let kind = currentUploadKind else { return }
            
            switch kind {
            case .personalID:
                personalIDURL = url
                personalIDCard.layer.borderColor = UIColor.systemGreen.cgColor
                personalIDCard.layer.borderWidth = 1.5
                
            case .training:
                trainingURL = url
                trainingCard.layer.borderColor = UIColor.systemGreen.cgColor
                trainingCard.layer.borderWidth = 1.5
                
            case .mission:
                missionURL = url
                missionCard.layer.borderColor = UIColor.systemGreen.cgColor
                missionCard.layer.borderWidth = 1.5
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Cancelled")
        }
        
        
        
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    }
}
