//
//  ReportReviewViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 27/12/2025.
//

import UIKit

class ReportReviewViewController: UIViewController {
    struct Report {
        let id: String
        let title: String
        let type: String
        let location: String
        let reportedBy: String
        let reportedUser: String
        let date: String
        let details: String
        var status: String
        var feedback: String
    }
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
        setupUI()
        loadDummyReport()
        
        /*//designing part
        reportCard.layer.borderColor = UIColor.systemGray.cgColor
        reportCard.layer.borderWidth = 1.0
        reportCard.layer.cornerRadius = 8
        
        reportDetailsTextView.layer.borderColor = UIColor.systemGray.cgColor
        reportDetailsTextView.layer.borderWidth = 1.0
        reportDetailsTextView.layer.cornerRadius = 8
        
        feedbackTextView.layer.borderColor = UIColor.systemGray.cgColor
        feedbackTextView.layer.borderWidth = 1.0
        feedbackTextView.layer.cornerRadius = 8
        
        statusView.layer.cornerRadius = 8
        statusView.layer.masksToBounds = true
       
        self.definesPresentationContext = true*/
    }
    
    private func setupUI() {
        reportCard.layer.borderColor = UIColor.systemGray.cgColor
        reportCard.layer.borderWidth = 1.0
        reportCard.layer.cornerRadius = 8
        statusView.backgroundColor = UIColor(hex: "FFFBCC")
        
        reportDetailsTextView.layer.borderColor = UIColor.systemGray.cgColor;
        reportDetailsTextView.layer.borderWidth = 1.0
        reportDetailsTextView.layer.cornerRadius = 8
        
        feedbackTextView.layer.borderColor = UIColor.systemGray.cgColor;
        feedbackTextView.layer.borderWidth = 1.0
        feedbackTextView.layer.cornerRadius = 8
      
        statusView.layer.cornerRadius = 8
        statusView.layer.masksToBounds = true


        print("reportCard:", reportCard ?? "nil")
        print("statusView:", statusView ?? "nil")
        print("reportDetailsTextView:", reportDetailsTextView ?? "nil")
        print("feedbackTextView:", feedbackTextView ?? "nil")

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        feedbackTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        reportDetailsTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

    }

    
    private func loadDummyReport() {
        let dummy = Report(
            id: "RPT-001",
            title: "Damaged Food Donation",
            type: "Donation Issue",
            location: "Warehouse A",
            reportedBy: "Fatema",
            reportedUser: "Maram",
            date: "2025-12-27",
            details: "The package collected during the recent donation pickup was damaged and unusable.", status: "Pending",
            feedback: "" )
        
        // Fill UI
        reportTitleValue.text = dummy.title
        reportIdValue.text = dummy.id
        reportTypeValue.text = dummy.type
        locationValue.text = dummy.location
        reportedByValue.text = dummy.reportedBy
        reportedUserValue.text = dummy.reportedUser
        dateValue.text = dummy.date
        reportDetailsTextView.text = dummy.details
        statusLabel.text = dummy.status
        feedbackTextView.text = dummy.feedback

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
        showPopup(title: "Account Suspended Successfully!", description: "This account is now suspended and access has been restricted.")
    }
    
    @IBAction func blockPermanentlyTapped(_ sender: UIButton) {
        // Backend call to block account permanently
        showPopup(title: "Account Blocked Successfully!", description: "This account is now blocked and access has been restricted.")
    }
    
    @IBAction func issueWarningTapped(_ sender: UIButton!) {
        // Backend call to issue warning
        showPopup(title: "Warning Issued!", description: "The warning has been issued successfully.")
    }
    
    
    @IBAction func markResolvedTapped(_ sender: UIButton) {
        statusLabel.text = "Resolved"
        statusView.backgroundColor = UIColor(hex: "D2F2C1")
        let feedbackMessage = feedbackTextView.text ?? ""
        saveFeedback(forReportId: reportIdValue.text ?? "", feedback: feedbackMessage)
        feedbackTextView.isEditable = false
        suspendButton.isHidden = true
        blockButton.isHidden = true
        issueButton.isHidden = true
        markResolvedButton.isHidden = true
        showPopup(title: "Report Marked Resolved Successfully!", description: "This report has been closed and marked as resolved.")
    }
    
    
    //for alerts
    func showPopup(title: String, description: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let popupVC = storyboard.instantiateViewController(withIdentifier: "ActionPopupVC") as? ActionPopupViewController {
            popupVC.popupTitle = title
            popupVC.popupDescription = description
            popupVC.modalPresentationStyle = .overCurrentContext   //  overlays instead of full screen
            popupVC.modalTransitionStyle = .crossDissolve          // fade in
            present(popupVC, animated: true, completion: nil)
        }
    }

}
