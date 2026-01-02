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
    
    var reportId: String?   // Must be set before presenting this VC
        var report: Report?
        let db = Firestore.firestore()

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            fetchReport()
        }

    private func fetchReport() {
            guard let reportId = reportId else {
                print("Error: reportId not set")
                return
            }

            db.collection("supportTickets").document(reportId).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching report: \(error.localizedDescription)")
                    return
                }

                guard let data = snapshot?.data() else {
                    print("No data found for reportId: \(reportId)")
                    return
                }

                // Map Firestore data to Report model
                let report = Report(id: reportId, data: data)
                self.report = report
                self.populateUI(with: report)
            }
        }
    
    // MARK: - Populate UI
    private func populateUI(with report: Report) { reportTitleValue.text = report.title
        reportIdValue.text = report.id
        reportTypeValue.text = report.type
        dateValue.text = report.date
        reportDetailsTextView.text = report.details
        statusLabel.text = report.status
        feedbackTextView.text = report.feedback.isEmpty ? "No feedback yet" : report.feedback
        
        switch report.status { case "Resolved": feedbackTextView.isEditable = false
            suspendButton.isHidden = true
            blockButton.isHidden = true
            issueButton.isHidden = true
            markResolvedButton.isHidden = true
            statusView.backgroundColor = UIColor.systemGreen
        case "Pending":
            statusView.backgroundColor = UIColor.systemYellow
        default:
            statusView.backgroundColor = UIColor.systemGray }
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
        statusView.layer.cornerRadius = 8
        statusView.layer.masksToBounds = true
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
          let feedbackMessage = feedbackTextView.text ?? ""

          // Update UI immediately
          statusLabel.text = "Resolved"
          statusView.backgroundColor = UIColor(hex: "D2F2C1")
          feedbackTextView.isEditable = false
          suspendButton.isHidden = true
          blockButton.isHidden = true
          issueButton.isHidden = true
          markResolvedButton.isHidden = true

          // Save feedback & status to Firestore
          saveFeedback(forReportId: report.id, feedback: feedbackMessage)

          showPopup(title: "Report Resolved!", description: "This report has been marked as resolved.")
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
