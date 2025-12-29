//
//  NGOApplicationViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 21/12/2025.
//

import UIKit
















class NGOApplicationViewController: UIViewController {
    //ngo info
    @IBOutlet weak var ngoCard: UIView!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var nameValue: UILabel!
    @IBOutlet weak var typeValue: UILabel!
    @IBOutlet weak var emailValue: UILabel!
    @IBOutlet weak var phoneValue: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusValue: UILabel!
    @IBOutlet weak var dateValue: UILabel!
    
    //upload section
    @IBOutlet weak var docStackView: UIStackView!
    
    //notes section
    @IBOutlet weak var notesTextView: UITextView!
    
    //action buutons
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    var applicationStatus: String = "Pending"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadDummyApplication()
    }

    private func setupUI() {
        //card + notes + status + profiles styling
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
    notesTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
}
// Dummy Data Loader
private func loadDummyApplication() {
    nameValue.text = "HealBridge"
    typeValue.text = "Medical & Psychological Support"
    emailValue.text = "support@healbridge.org"
    phoneValue.text = "+973 33490231" 
    dateValue.text = "Oct 10, 2025"
    statusValue.text = "Pending"
    profile.image = UIImage(named: "ngo_profile")
    notesTextView.text = "Add note"
    addDummyDocuments()
}

    //Documents
    private func addDummyDocuments() {
        let documents = [
            ("Personal_Identification.pdf", "pdf"),
            ("Training_Certificate.docx", "doc")
        ]
        
        for (name, type) in documents {
            // Icon
            let icon = UIImageView()
            icon.image = UIImage(named: type == "pdf" ? "icon_pdf" : "icon_word")
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.widthAnchor.constraint(equalToConstant: 24).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 24).isActive = true
            
            // Label
            let label = UILabel()
            label.text = name
            label.textColor = .label
            label.font = UIFont.systemFont(ofSize: 16)
            label.numberOfLines = 1
            
            // Horizontal row
            let row = UIStackView(arrangedSubviews: [icon, label])
            row.axis = .horizontal
            row.spacing = 8
            row.alignment = .center
            row.distribution = .fill
            row.translatesAutoresizingMaskIntoConstraints = false
            
            // Container view for height + border
            let container = UIView()
            container.addSubview(row)
            container.translatesAutoresizingMaskIntoConstraints = false
            container.layer.borderColor = UIColor.systemGray.cgColor
            container.layer.borderWidth = 1.0
            container.layer.cornerRadius = 8
            container.backgroundColor = .systemBackground
            
            // Constraints for row inside container
            NSLayoutConstraint.activate([
                row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
                row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
                row.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 8),
                container.heightAnchor.constraint(equalToConstant: 48) // fixed height
            ])
            
            // Tap-to-download
            container.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleDocumentTap(_:)))
            container.addGestureRecognizer(tap)
            container.accessibilityLabel = name
            
            docStackView.addArrangedSubview(container)
        }
    }



    @objc func handleDocumentTap(_ sender: UITapGestureRecognizer) {
        guard let stack = sender.view as? UIStackView,
              let fileName = stack.accessibilityLabel else { return }
        
        print("Admin tapped to download: \(fileName)")
        
        // Later: open file from Firebase Storage or local bundle
        // Example:
        // let url = URL(string: "https://your-storage-url/\(fileName)")
        // UIApplication.shared.open(url)
    }

    
    //approve and reject action with popup
    @IBAction func approveTapped(_ sender: UIButton) {
        statusValue.text = "Verified"
        statusView.backgroundColor = UIColor(hex: "D2F2C1")//light green
        lockUI()
        showPopup(title: "Application Successfully Verified",
                  description: "The Application has been approved and marked as verified.")
    }
   

    @IBAction func rejectedTapped(_ sender: UIButton) {
        statusValue.text = "Rejected"
        statusView.backgroundColor = UIColor(hex: "F44336") // red
        lockUI()
        showPopup(title: "Application Successfully Rejected",
                  description: "The application has been rejected successfully.")
    }
  

    private func lockUI() { notesTextView.isEditable = false
        approveButton.isHidden = true
        rejectButton.isHidden = true
        
        // Save notes (for now, just print)
        let notes = notesTextView.text ?? ""
        print("Saved notes: \(notes)")

    }

//popup
    func showPopup(title: String, description: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let popupVC = storyboard.instantiateViewController(withIdentifier: "NgoApplicationPopupVC") as? PopupNGOApplicationViewController {
            popupVC.popupTitle = title
            popupVC.popupDescription = description
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.modalTransitionStyle = .crossDissolve
            present(popupVC, animated: true, completion: nil) }
    }
    
    
    }
   



    

