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
    
    //properties
    let db = Firestore.firestore()
    var applicationId : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchApplication()
        //loadDummyApplication()
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
    
    //fetch backend data
    private func fetchApplication() {
        db.collection("ngo_applications")
                 .document("N-1") //dynamic
                 .getDocument { snapshot, error in

                     if let error = error {
                         print("Fetch error:", error.localizedDescription)
                         return
                     }

                     guard let snapshot,
                           let application = NGOApplication(snapshot: snapshot) else { return }

                     self.bind(application)
                 }
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

    
    
//// Dummy Data Loader
//private func loadDummyApplication() {
//    nameValue.text = "HealBridge"
//    typeValue.text = "Medical & Psychological Support"
//    emailValue.text = "support@healbridge.org"
//    phoneValue.text = "+973 33490231" 
//    dateValue.text = "Oct 10, 2025"
//    statusValue.text = "Pending"
//    profile.image = UIImage(named: "ngo_profile")
//    notesTextView.text = "Add note"
//    addDummyDocuments()
//}
//
//    //Documents
//    private func addDummyDocuments() {
//        let documents = [
//            ("Personal_Identification.pdf", "pdf"),
//            ("Training_Certificate.docx", "doc")
//        ]
//        
//        for (name, type) in documents {
//            // Icon
//            let icon = UIImageView()
//            icon.image = UIImage(named: type == "pdf" ? "icon_pdf" : "icon_word")
//            icon.contentMode = .scaleAspectFit
//            icon.translatesAutoresizingMaskIntoConstraints = false
//            icon.widthAnchor.constraint(equalToConstant: 24).isActive = true
//            icon.heightAnchor.constraint(equalToConstant: 24).isActive = true
//            
//            // Label
//            let label = UILabel()
//            label.text = name
//            label.textColor = .label
//            label.font = UIFont.systemFont(ofSize: 16)
//            label.numberOfLines = 1
//            
//            // Horizontal row
//            let row = UIStackView(arrangedSubviews: [icon, label])
//            row.axis = .horizontal
//            row.spacing = 8
//            row.alignment = .center
//            row.distribution = .fill
//            row.translatesAutoresizingMaskIntoConstraints = false
//            
//            // Container view for height + border
//            let container = UIView()
//            container.addSubview(row)
//            container.translatesAutoresizingMaskIntoConstraints = false
//            container.layer.borderColor = UIColor.systemGray.cgColor
//            container.layer.borderWidth = 1.0
//            container.layer.cornerRadius = 8
//            container.backgroundColor = .systemBackground
//            
//            // Constraints for row inside container
//            NSLayoutConstraint.activate([
//                row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
//                row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
//                row.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
//                row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 8),
//                container.heightAnchor.constraint(equalToConstant: 48) // fixed height
//            ])
//            
//            // Tap-to-download
//            container.isUserInteractionEnabled = true
//            let tap = UITapGestureRecognizer(target: self, action: #selector(handleDocumentTap(_:)))
//            container.addGestureRecognizer(tap)
//            container.accessibilityLabel = name
//            
//            docStackView.addArrangedSubview(container)
//        }
//    }

    
//documents
    private func loadDocuments(_ documents: [NGODocument]) {
            docStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

            for doc in documents {
                let iconName = doc.name.hasSuffix(".pdf") ? "icon_pdf" : "icon_word"

                let icon = UIImageView(image: UIImage(named: iconName))
                icon.translatesAutoresizingMaskIntoConstraints = false
                icon.contentMode = .scaleAspectFit   // ✅ IMPORTANT
                icon.clipsToBounds = true

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
    private func updateApplicationDecision(status: String) {
        let notes = notesTextView.text ?? ""

               db.collection("ngo_applications")
                   .document("N-1")
                   .updateData([
                       "approveStatus": status,
                       "notes": notes,
                       "reviewedAt": FieldValue.serverTimestamp()
                   ])
    }

    //approve and reject action with popup
    @IBAction func approveTapped(_ sender: UIButton) {
        updateApplicationDecision(status: "approved")
        
                statusValue.text = "Verified"
                statusView.backgroundColor = UIColor(hex: "D2F2C1")
                lockUI()
                showPopup(
                    title: "Application Successfully Verified",
                    description: "The Application has been approved and marked as verified."
                )
    }
   

    @IBAction func rejectedTapped(_ sender: UIButton) {
        updateApplicationDecision(status: "rejected")
        
               statusValue.text = "Rejected"
               statusView.backgroundColor = UIColor(hex: "F44336")
               lockUI()
               showPopup(
                   title: "Application Successfully Rejected",
                   description: "The application has been rejected successfully."
               )
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
   



    

