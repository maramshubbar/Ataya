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
    
    var isApplicationFinalized = false
    var applicationStatus: String = "Pending"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addDummyDocuments()
        
        // Dummy NGO application data
        nameValue.text = "HealBridge"
        typeValue.text = "Medical & Psychological Support"
        emailValue.text = "support@healbridge.org"
        phoneValue.text = "+973 33490231"
        dateValue.text = "Oct 10, 2025"
        statusValue.text = "Pending"
        
        statusView.layer.cornerRadius = 8
        statusView.backgroundColor = UIColor.systemGray
    }

    private func setupUI() {
        //Ui styling
        ngoCard.layer.borderColor = UIColor.systemGray.cgColor
        ngoCard.layer.borderWidth = 1.0
        ngoCard.layer.cornerRadius = 8
        
        notesTextView.layer.borderColor = UIColor.systemGray.cgColor
        notesTextView.layer.borderWidth = 1.0
        notesTextView.layer.cornerRadius = 8
        
        docStackView.layer.borderColor = UIColor.systemGray.cgColor
        docStackView.layer.borderWidth = 1.0
        docStackView.layer.cornerRadius = 8
        
        statusView.layer.cornerRadius = 8
        statusView.layer.masksToBounds = true
        statusView.backgroundColor = UIColor.systemGray

    }
    
override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    notesTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
}

private func loadDummyApplication() {
    nameValue.text = "HealBridge"
    typeValue.text = "Medical & Psychological Support"
    emailValue.text = "support@healbridge.org"
    phoneValue.text = "+973 33490231" 
    dateValue.text = "Oct 10, 2025"
    statusValue.text = "Pending"
    
    notesTextView.text = "Collector provided missing documents."
    
    addDummyDocuments()
}

    private func addDummyDocuments() {
        let doc1 = UILabel() 
        doc1.text = "Personal_Identification.pdf"
        doc1.textColor = .systemBlue
        
        let doc2 = UILabel()
        doc2.text = "Training_Certificate.docx"
        doc2.textColor = .systemBlue
        
        docStackView.addArrangedSubview(doc1)
        docStackView.addArrangedSubview(doc2)
    }
    
    //approve and reject action with popup
    @IBAction func approveTapped(_ sender: UIButton) {
        statusValue.text = "Verified"
        statusView.backgroundColor = UIColor.systemGreen
        lockUI()
        showPopup(title: "Application Successfully Verified", description: "Collector has been approved and marked as verified.")
    }

@IBAction func rejectTapped(_ sender: UIButton) {
    statusValue.text = "Rejected"
    statusView.backgroundColor = UIColor.systemRed
    lockUI()
    showPopup(title: "Application Successfully Rejected", description: "The application has been rejected successfully.")
}

private func lockUI() { notesTextView.isEditable = false
    approveButton.isHidden = true
    rejectButton.isHidden = true }

//MARK: - Popup
    func showPopup(title: String, description: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let popupVC = storyboard.instantiateViewController(withIdentifier: "ActionPopupVC") as? ActionPopupViewController {
            popupVC.popupTitle = title
            popupVC.popupDescription = description
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.modalTransitionStyle = .crossDissolve
            present(popupVC, animated: true, completion: nil) }
    }
    }
   



    

