//
//  ReportReviewViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 27/12/2025.
//

import UIKit

class ReportReviewViewController: UIViewController {
    
    //outlets
    //report info card
    @IBOutlet weak var reportCard: UIView!
    
    @IBOutlet weak var statusView: UIView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var reportTitleValue: UILabel!
    
    @IBOutlet weak var reportId: UILabel!
    
    @IBOutlet weak var reportIdValue: UILabel!
    
    @IBOutlet weak var reportType: UILabel!
    
    @IBOutlet weak var reportTypeValue: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var locationValue: UILabel!
    
    @IBOutlet weak var reportedBy: UILabel!
    
    @IBOutlet weak var reportedByValue: UILabel!
    
    @IBOutlet weak var reportedUser: UILabel!
    
    @IBOutlet weak var reportedUserValue: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var dateValue: UILabel!
    
    //report details section
    @IBOutlet weak var reportDetailsTextView: UITextView!
    
    //feedback section
    @IBOutlet weak var feedbackTextView: UITextView!
    
    //action buttons
    @IBOutlet weak var suspendButton: UIButton!
    
    @IBOutlet weak var blockButton: UIButton!
    
    @IBOutlet weak var issueButton: UIButton!
    
    @IBOutlet weak var markResolvedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //designing part
        reportCard.layer.borderColor = UIColor.systemGray.cgColor
        reportCard.layer.borderWidth = 1.0
        reportCard.layer.cornerRadius = 8
        
        reportDetailsTextView.layer.borderColor = UIColor.systemGray.cgColor
        reportDetailsTextView.layer.borderWidth = 1.0
        reportDetailsTextView.layer.cornerRadius = 8
        
        feedbackTextView.layer.borderColor = UIColor.systemGray.cgColor
        feedbackTextView.layer.borderWidth = 1.0
        feedbackTextView.layer.cornerRadius = 8
        
    }
    
    func saveFeedback(forReportId reportId: String, feedback: String) {
        // Example: send to backend
        print("Saving feedback for report \(reportId): \(feedback)")
        
        // TODO: Replace with actual API call or database write
        /* exmaple of the replacement
         import FirebaseFirestore
         
         func saveFeedback(forReportId reportId: String, feedback: String) {
             let db = Firestore.firestore()
             db.collection("reports").document(reportId).updateData([
                 "feedback": feedback,
                 "status": "Resolved"
             ]) { error in
                 if let error = error {
                     print("Error saving feedback: \(error)")
                 } else {
                     print("Feedback saved successfully for report \(reportId)")
                 }
             }
         }
*/
    }
    
    
    @IBAction func suspendAccountTapped(_ sender: UIButton!) {
        // Backend call to suspend account would go here
        showPopup(title: "Success", description: "Account suspended successfully.")
    }
    
    @IBAction func blockPermanentlyTapped(_ sender: UIButton) {
        // Backend call to block account permanently
        showPopup(title: "Success", description: "Account blocked permanently.")
    }
    
    @IBAction func issueWarningTapped(_ sender: UIButton!) {
        // Backend call to issue warning
        showPopup(title: "Success", description: "Warning issued successfully.")
    }
    
    
    @IBAction func markResolvedTapped(_ sender: UIButton) {
        // Change status from Pending → Resolved
        statusLabel.text = "Resolved";
        statusLabel.textColor = UIColor.systemGreen
        // Save feedback (this would normally go to your backend/database)
        let feedbackMessage = feedbackTextView.text ?? ""
        saveFeedback(forReportId: reportIdValue.text ?? "", feedback: feedbackMessage)
        //make feedback view readonly
        feedbackTextView.isEditable = false

        // Hide action buttons
        suspendButton.isHidden = true
        blockButton.isHidden = true
        issueButton.isHidden = true
        markResolvedButton.isHidden = true
        // Show confirmation popup
        showPopup(title: "Success", description: "Report marked as resolved successfully.")
    }
    
    
    //for alerts
    func showPopup(title: String, description: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let popupVC = storyboard.instantiateViewController(withIdentifier: "ActionPopupVC") as? ActionPopupViewController {
            popupVC.popupTitle = title
            popupVC.popupDescription = description
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.modalTransitionStyle = .crossDissolve
            present(popupVC, animated: true, completion: nil)
        }
    }

    
}
