//
//  NGOApplicationViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 21/12/2025.
//

import UIKit
// MARK: - Status Enum (controls the whole screen)
enum ApplicationStatus {
    case pending
    case approved
    case rejected
}


class NGOApplicationViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    
    
    @IBOutlet weak var uploadedDocumentsContainerView: UIView!
    
    @IBOutlet weak var documentsStackView: UIStackView!
    
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var notesContainerView: UIView!
    
    @IBOutlet weak var actionButtonsContainerView: UIView!
    
    // MARK: - State (TEMP for now, real data later)
        var applicationStatus: ApplicationStatus = .pending
        var adminNote: String?

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()

            setupUI()
            loadDummyDocuments()   // TEMP – remove later
            configureUI()
        }

        // MARK: - Initial UI Setup
        private func setupUI() {
            title = "NGO Application"

            statusLabel.layer.cornerRadius = 8
            statusLabel.clipsToBounds = true
            statusLabel.textAlignment = .center

            notesLabel.numberOfLines = 0
        }

        // MARK: - UI STATE CONTROLLER (MOST IMPORTANT PART)
        private func configureUI() {
            switch applicationStatus {

            case .pending:
                statusLabel.text = "Pending"
                statusLabel.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.3)

                uploadedDocumentsContainerView.isHidden = false
                actionButtonsContainerView.isHidden = false
                notesContainerView.isHidden = false

                notesLabel.text = "Please review the documents and take action."

            case .approved:
                statusLabel.text = "Approved"
                statusLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)

                uploadedDocumentsContainerView.isHidden = true
                actionButtonsContainerView.isHidden = true
                notesContainerView.isHidden = false

                notesLabel.text = adminNote ?? "The application has been approved."

            case .rejected:
                statusLabel.text = "Rejected"
                statusLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)

                uploadedDocumentsContainerView.isHidden = true
                actionButtonsContainerView.isHidden = true
                notesContainerView.isHidden = false

                notesLabel.text = adminNote ?? "The application has been rejected."
            }
        }

        // MARK: - TEMP Documents (for UI testing only)
        private func loadDummyDocuments() {
            documentsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

            let documents = [
                "Personal_Identification.pdf",
                "Training_Certificate.pdf",
                "NGO_License.pdf"
            ]

            for name in documents {
                let docView = createDocumentView(fileName: name)
                documentsStackView.addArrangedSubview(docView)
            }
        }

        private func createDocumentView(fileName: String) -> UIView {
            let container = UIView()
            container.heightAnchor.constraint(equalToConstant: 55).isActive = true
            container.layer.cornerRadius = 10
            container.layer.borderWidth = 1
            container.layer.borderColor = UIColor.systemGray4.cgColor

            let icon = UIImageView()
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.image = UIImage(systemName: "doc.text.fill")
            icon.tintColor = .systemBlue

            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = fileName
            label.font = UIFont.systemFont(ofSize: 15, weight: .medium)

            container.addSubview(icon)
            container.addSubview(label)

            NSLayoutConstraint.activate([
                icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: 24),
                icon.heightAnchor.constraint(equalToConstant: 24),

                label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
                label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])

            return container
        }

        // MARK: - Admin Actions

        @IBAction func approveTapped(_ sender: UIButton) {
            applicationStatus = .approved
            adminNote = "The NGO application has been approved and verified."
            configureUI()
        }

        @IBAction func rejectTapped(_ sender: UIButton) {
            let alert = UIAlertController(
                title: "Reject Application",
                message: "Enter rejection reason",
                preferredStyle: .alert
            )

            alert.addTextField {
                $0.placeholder = "Reason"
            }

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Submit", style: .destructive) { _ in
                self.adminNote = alert.textFields?.first?.text
                self.applicationStatus = .rejected
                self.configureUI()
            })

            present(alert, animated: true)
        }

}
