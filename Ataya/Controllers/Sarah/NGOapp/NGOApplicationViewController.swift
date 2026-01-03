//
//  NGOApplicationViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 21/12/2025.
//

import UIKit
import FirebaseFirestore

class NGOApplicationViewController: UIViewController {
//outlets
    @IBOutlet weak var ngoCard: UIView!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var nameValue: UILabel!
    @IBOutlet weak var typeValue: UILabel!
    @IBOutlet weak var emailValue: UILabel!
    @IBOutlet weak var phoneValue: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusValue: UILabel!
    @IBOutlet weak var dateValue: UILabel!
    @IBOutlet weak var docStackView: UIStackView!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    //var applicationStatus: String = "Pending"
    
    var application: NGOApplication?

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            loadDummyApplication()
        }

    //ui setup
    private func setupUI() {
        ngoCard.layer.borderColor = UIColor.systemGray.cgColor
        ngoCard.layer.borderWidth = 1.0
        ngoCard.layer.cornerRadius = 8
        
        notesTextView.layer.borderColor = UIColor.systemGray.cgColor
        notesTextView.layer.borderWidth = 1.0
        notesTextView.layer.cornerRadius = 8
        
        statusView.layer.cornerRadius = 8
        statusView.layer.masksToBounds = true
        
        profile.layer.cornerRadius = profile.frame.height / 2
          profile.clipsToBounds = true
        
        statusView.backgroundColor = UIColor(hex: "FFFBCC")
        docStackView.spacing = 12

    }
    
override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // Add padding inside notes text view
//    notesTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
}
    
    private func loadDummyApplication() {
            let dummyDocuments = [
                NGODocument(name: "Personal_Identification.pdf", url: ""),
                NGODocument(name: "Training_Certificate.docx", url: "")
            ]

            let dummyApp = NGOApplication(
                uid: "N-001",
                name: "HealBridge",
                type: "Medical & Psychological Support",
                email: "support@healbridge.org",
                phone: "+973 33490231",
                notes: "",
                approveStatus: "pending",
                createdAt: Date(),
                documents: dummyDocuments,
                profile: "Image3"
            )

            self.application = dummyApp
            bind(dummyApp)
        }
    
    //bind data to ui
    private func bind(_ app: NGOApplication) {
           nameValue.text = app.name
           typeValue.text = app.type
           emailValue.text = app.email
           phoneValue.text = app.phone
           notesTextView.text = app.notes

           statusValue.text = app.approveStatus.capitalized
           updateStatusColor(app.approveStatus)

           let formatter = DateFormatter()
           formatter.dateStyle = .medium
           dateValue.text = formatter.string(from: app.createdAt)

           loadDocuments(app.documents)

        if let image = UIImage(named: app.profile) {
            self.profile.image = image
        }

        if let url = URL(string: app.profile) {
            // Simple async image loading
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.profile.image = image
                    }
                }
            }
        }
        //if already reviewed read only mode
           if app.approveStatus != "pending" {
               lockUI()
           }
       }
 
    private func loadDocuments(_ documents: [NGODocument]) {
            docStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

            for doc in documents {
                let iconName = doc.name.hasSuffix(".pdf") ? "pdf" : "doc"
                let icon = UIImageView(image: UIImage(named: iconName))
                icon.translatesAutoresizingMaskIntoConstraints = false
                icon.contentMode = .scaleAspectFit
                NSLayoutConstraint.activate([
                    icon.widthAnchor.constraint(equalToConstant: 24),
                    icon.heightAnchor.constraint(equalToConstant: 24)
                ])

                let label = UILabel()
                label.text = doc.name
                label.font = .systemFont(ofSize: 16)

                let row = UIStackView(arrangedSubviews: [icon, label])
                row.axis = .horizontal
                row.spacing = 8

                let container = UIView()
                container.layer.borderWidth = 1
                container.layer.borderColor = UIColor.systemGray.cgColor
                container.layer.cornerRadius = 8
                container.addSubview(row)

                row.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
                    row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
                    row.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                    row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
                    container.heightAnchor.constraint(equalToConstant: 60)
                ])

                docStackView.addArrangedSubview(container)
            }
        }


    //STATUS COLOR
      private func updateStatusColor(_ status: String) {
          switch status {
          case "approved":
              statusView.backgroundColor = UIColor(hex: "D2F2C1")
          case "rejected":
              statusView.backgroundColor = UIColor(hex: "F44336")
          default:
              statusView.backgroundColor = UIColor(hex: "FFFBCC")
          }
      }

    //update decision
//    private func updateApplicationDecision(status: String) {
//        let notes = notesTextView.text ?? ""
//
//               db.collection("ngo_applications")
//                   .document("N-1")
//                   .updateData([
//                       "approveStatus": status,
//                       "notes": notes,
//                       "reviewedAt": FieldValue.serverTimestamp()
//                   ])
//    }

    //approve and reject action with popup
    @IBAction func approveTapped(_ sender: UIButton) {
        statusValue.text = "Verified"
              statusView.backgroundColor = UIColor(hex: "D2F2C1")
              lockUI()
              showPopup(title: "Application Successfully Verified",
                        description: "The Application has been approved and marked as verified.")
    }
   

    @IBAction func rejectedTapped(_ sender: UIButton) {
        statusValue.text = "Rejected"
        statusView.backgroundColor = UIColor(hex: "F44336")
        lockUI()
        showPopup(title: "Application Successfully Rejected",
                  description: "The application has been rejected successfully.")
    }
  

    private func lockUI() { notesTextView.isEditable = false
        approveButton.isHidden = true
        rejectButton.isHidden = true
        notesTextView.isEditable = false
//        // Save notes (for now, just print)
//        let notes = notesTextView.text ?? ""
//        print("Saved notes: \(notes)")

    }

//popup
    func showPopup(title: String, description: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
             if let vc = storyboard.instantiateViewController(withIdentifier: "NgoApplicationPopupVC")
                 as? PopupNGOApplicationViewController {
                 vc.popupTitle = title
                 vc.popupDescription = description
                 vc.modalPresentationStyle = .overCurrentContext
                 vc.modalTransitionStyle = .crossDissolve
                 present(vc, animated: true)
             }
         }
    
    }
   



    

