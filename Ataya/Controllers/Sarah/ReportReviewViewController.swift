//
//  ReportReviewViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 27/12/2025.
//

import UIKit
import FirebaseFirestore

class ReportReviewViewController: UIViewController {
    //outlets
    //report info card
    @IBOutlet weak var reportCard: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var reportTitleValue: UILabel!
    @IBOutlet weak var reportIdLabel: UILabel!
    @IBOutlet weak var reportIdValue: UILabel!
    @IBOutlet weak var reportType: UILabel!
    @IBOutlet weak var reportTypeValue: UILabel!
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
    
    let db = Firestore.firestore()
    var report: Report?
    
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            fetchReport()
        }

    func fetchReport() {
        let documentId = "2qKheNZlqtzsWjqMgGyC"
        db.collection("supportTickets").document(documentId).getDocument {
            snapshot, error in if let error = error {
                print("Error fetching report: \(error.localizedDescription)")
                return }
            guard let data = snapshot?.data() else { print("No data found")
                return }
            let report = Report(id: documentId, data: data)
            self.report = report
            self.populateUI(with: report)
        }
    }
    
    // MARK: - Populate UI
    func populateUI(with report: Report) {
        reportTitleValue.text = report.title
        reportIdValue.text = report.id
        reportTypeValue.text = report.type
        dateValue.text = report.date
        reportDetailsTextView.text = report.details
        feedbackTextView.text = report.feedback
        statusLabel.text = report.status
        
    }
    
    
    
    private func setupUI() {
        reportCard.layer.borderColor = UIColor.systemGray.cgColor
        reportCard.layer.borderWidth = 1.0
        reportCard.layer.cornerRadius = 8
        statusView.backgroundColor = UIColor.systemYellow
        reportDetailsTextView.layer.borderColor = UIColor.systemGray.cgColor
        reportDetailsTextView.layer.borderWidth = 1.0
        reportDetailsTextView.layer.cornerRadius = 8
        feedbackTextView.layer.borderColor = UIColor.systemGray.cgColor
        feedbackTextView.layer.borderWidth = 1.0
        feedbackTextView.layer.cornerRadius = 8
        feedbackTextView.backgroundColor = .systemBackground
        feedbackTextView.font = UIFont.systemFont(ofSize: 16)
        feedbackTextView.textAlignment = .left
        feedbackTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        feedbackTextView.textContainer.lineFragmentPadding = 0
        feedbackTextView.isScrollEnabled = true


        statusView.layer.cornerRadius = 8
        statusView.layer.masksToBounds = true
        
        reportDetailsTextView.backgroundColor = .systemBackground
        reportDetailsTextView.layer.borderColor = UIColor.systemGray.cgColor
        reportDetailsTextView.layer.borderWidth = 1.0
        reportDetailsTextView.layer.cornerRadius = 8
        reportDetailsTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        reportDetailsTextView.isEditable = false
        reportDetailsTextView.isScrollEnabled = false
        reportDetailsTextView.font = UIFont.systemFont(ofSize: 16)


    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
         feedbackTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
         reportDetailsTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

    }

   
//    private func loadDummyReport() {
//        let dummy = Report(
//            id: "RPT-001",
//            title: "Damaged Food Donation",
//            type: "Donation Issue",
//            date: "2025-12-27",
//            details: "The package collected during the recent donation pickup was damaged and unusable.", status: "Pending",
//            feedback: "" )
//        
//        // Fill UI
//        reportTitleValue.text = dummy.title
//        reportIdValue.text = dummy.id
//        reportTypeValue.text = dummy.type
//        dateValue.text = dummy.date
//        reportDetailsTextView.text = dummy.details
//        statusLabel.text = dummy.status
//        feedbackTextView.text = dummy.feedback
//
//    }
    
    
    // MARK: - Firestore Updates
    func saveFeedback(forReportId reportId: String, feedback: String) {
        db.collection("supportTickets").document(reportId).updateData([
            "adminReply": feedback,
            "status": "Resolved", "updatedAt": FieldValue.serverTimestamp() ]) {
                error in if let error = error {
                    print("Error saving feedback: \(error.localizedDescription)")
                } else {
                    print("Feedback saved successfully for report \(reportId)")
                }
            }
    }
    
    func updateUserStatus(userId: String, status: String) {
        db.collection("users").document(userId).updateData([
                   "accountStatus": status,
                   "updatedAt": FieldValue.serverTimestamp()
               ]) { error in
                   if let error = error {
                       print("Error updating user status: \(error.localizedDescription)")
                   } else {
                       print("User status updated to \(status)")
                   }
               }
     }
    @IBAction func suspendAccountTapped(_ sender: UIButton!) {
        guard let userId = report?.userId else { return }
             updateUserStatus(userId: userId, status: "Suspended")
             showPopup(title: "Account Suspended Successfully!", description: "This account is now suspended and access has been restricted.")
    }
    
    @IBAction func blockPermanentlyTapped(_ sender: UIButton) {
        guard let userId = report?.userId else { return }
        updateUserStatus(userId: userId, status: "Blocked")
        showPopup(title: "Account Blocked Successfully!", description: "This account is now blocked and access has been restricted.")
    }
    
    @IBAction func issueWarningTapped(_ sender: UIButton!) {
        showPopup(title: "Warning Issued!", description: "The warning has been issued successfully.")
           
    }
    
    
    @IBAction func markResolvedTapped(_ sender: UIButton) {
        guard let report = report else { return }
        let feedback = feedbackTextView.text ?? ""
        
        db.collection("supportTickets").document(report.id).updateData([
            "adminReply": feedback,
            "status": "Resolved",
            "updatedAt": FieldValue.serverTimestamp() ])
        {
                error in if let error = error {
                    print("Error updating report:\(error.localizedDescription)")
                } else {
                    // Update UI immediately
                    self.statusLabel.text = "Resolved"
                    self.statusView.backgroundColor = UIColor.systemGreen
                    self.feedbackTextView.isEditable = false
                    
                    // Hide all action buttons
                    self.suspendButton.isHidden = true
                    self.blockButton.isHidden = true
                    self.issueButton.isHidden = true
                    self.markResolvedButton.isHidden = true
                    print("Report marked as resolved")
                }
            }
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
