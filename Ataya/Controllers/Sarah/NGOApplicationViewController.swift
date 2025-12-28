//
//  NGOApplicationViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 21/12/2025.
//

import UIKit
















class NGOApplicationViewController: UIViewController {
    //ngo info
    @IBOutlet weak var ngoInfoCard: UIView!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var titleValueLabel: UILabel!
    @IBOutlet weak var TypeValueTitle: UILabel!
    @IBOutlet weak var EmailValueTitle: UILabel!
    @IBOutlet weak var PhoneUserValue: UILabel!
    @IBOutlet weak var Status: UIView!
    @IBOutlet weak var StatusValueLabel: UILabel!
    @IBOutlet weak var DateUserValue: UILabel!
    
    //upload section
    @IBOutlet weak var documentView: UIView!
    
    //notes section
    @IBOutlet weak var notesTextView: UITextView!
    
    //action buutons
    @IBOutlet weak var approveButton: UIButton!
    
    @IBOutlet weak var rejectButton: UIButton!
    
    var isApplicationFinalized = false
    var applicationStatus: String = "Pending"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dummy NGO application data
        titleValueLabel.text = "HealBridge"
        TypeValueTitle.text = "Medical & Psychological Support"
        EmailValueTitle.text = "support@healbridge.org"
        PhoneUserValue.text = "+973 33490231"
        DateUserValue.text = "Oct 10, 2025"
        StatusValueLabel.text = "Pending"
        
        // Optional: style status
        Status.layer.cornerRadius = 8
        Status.backgroundColor = UIColor.systemGray
    }

    @IBAction func approveTapped(_ sender: UIButton) {
        showPopup(for: "Approved")
    }

    @IBAction func rejectTapped(_ sender: UIButton) {
        showPopup(for: "Rejected")
    }

    func showPopup(for status: String) {
        let alert = UIAlertController(title: "\(status) Application?", message: "Are you sure you want to mark this application as \(status.lowercased())?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            self.updateStatus(to: status)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }


    func finalizeApplication(status: String) {
        applicationStatus = status
        isApplicationFinalized = true
        
        // Update UI
        StatusValueLabel.text = status
        Status.backgroundColor = status == "Approved" ? UIColor.systemGreen : UIColor.systemRed
        
        // Save notes (for now, just print — later you can persist to Firestore)
        let notes = notesTextView.text ?? ""
        print("Saved notes: \(notes)")
        
        // Disable editing
        notesTextView.isEditable = false
        approveButton.isEnabled = false
        rejectButton.isEnabled = false
    }

    func updateStatus(to newStatus: String) {
        StatusValueLabel.text = newStatus
        Status.backgroundColor = newStatus == "Approved" ? UIColor.systemGreen : UIColor.systemRed
        
        // Disable buttons
        // You can also hide them or fade them out
        approveButton.isEnabled = false
        rejectButton.isEnabled = false
        approveButton.alpha = 0.5
        rejectButton.alpha = 0.5
        
        // Lock notes field if you add one
        notesTextView?.isEditable = false
    }

    
}
