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
    
 /*var reportId: String? */
//        var report: SupportReport?
//        let db = Firestore.firestore()

    var report: SupportReport?
    var reportId: String?
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
//            fetchReport()
            loadDummyReport()
        }

//    private func fetchReport() {
//            guard let reportId = reportId else {
//                print("Error: reportId not set")
//                return
//            }
//
//            db.collection("supportTickets").document(reportId).getDocument { snapshot, error in
//                if let error = error {
//                    print("Error fetching report: \(error.localizedDescription)")
//                    return
//                }
//
//                guard let data = snapshot?.data() else {
//                    print("No data found for reportId: \(reportId)")
//                    return
//                }
//
//                // Map Firestore data to Report model
//                let report = SupportReport(id: reportId, data: data)
//                self.report = report
//                self.populateUI(with: report)
//            }
//        }
    
    private func populateUI(with report: SupportReport) {
           reportTitleValue.text = report.title
           reportIdValue.text = report.id
           reportTypeValue.text = report.type
           dateValue.text = report.date
           reportDetailsTextView.text = report.details
           statusLabel.text = report.status
           feedbackTextView.text = report.feedback.isEmpty ? "No feedback yet" : report.feedback

           switch report.status {
           case "Resolved":
               feedbackTextView.isEditable = false
               suspendButton.isHidden = true
               blockButton.isHidden = true
               issueButton.isHidden = true
               markResolvedButton.isHidden = true
               statusView.backgroundColor = UIColor.systemGreen

           case "Pending":
               statusView.backgroundColor = UIColor.systemYellow

           default:
               statusView.backgroundColor = UIColor.systemGray
           }
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

   
    // MARK: - Dummy Data
       private func loadDummyReport() {
           let dummy = SupportReport(
                     id: "RPT-001",
                     title: "Damaged Food Donation",
                     type: "Donation Issue",
                     date: "2025-12-27",
                     details: "The package collected during the recent donation pickup was damaged and unusable.",
                     status: "Pending",
                     feedback: "",
                     userId: "USR-001"
                 )
                 self.report = dummy
                 populateUI(with: dummy)
       }
    
    
    // MARK: - Firestore Updates
//    func saveFeedback(forReportId reportId: String, feedback: String) {
//        db.collection("supportTickets").document(reportId).updateData([
//            "adminReply": feedback,
//            "status": "Resolved", "updatedAt": FieldValue.serverTimestamp() ]) {
//                error in if let error = error {
//                    print("Error saving feedback: \(error.localizedDescription)")
//                } else {
//                    print("Feedback saved successfully for report \(reportId)")
//                }
//            }
//    }
//    
//    func updateUserStatus(userId: String, status: String) {
//        db.collection("users").document(userId).updateData([
//                   "accountStatus": status,
//                   "updatedAt": FieldValue.serverTimestamp()
//               ]) { error in
//                   if let error = error {
//                       print("Error updating user status: \(error.localizedDescription)")
//                   } else {
//                       print("User status updated to \(status)")
//                   }
//               }
//     }
    @IBAction func suspendAccountTapped(_ sender: UIButton!) {
        guard let _ = report else { return }
               showPopup(title: "Account Suspended!", description: "This account is now suspended.")
    }
    
    @IBAction func blockPermanentlyTapped(_ sender: UIButton) {
        showPopup(title: "Account Blocked!", description: "This account is now blocked permanently.")
    }
    
    @IBAction func issueWarningTapped(_ sender: UIButton!) {
        showPopup(title: "Warning Issued!", description: "A warning has been issued successfully.")
    }
    
    @IBAction func markResolvedTapped(_ sender: UIButton) {
        statusLabel.text = "Resolved"
          statusView.backgroundColor = UIColor.systemGreen
          feedbackTextView.isEditable = false
          suspendButton.isHidden = true
          blockButton.isHidden = true
          issueButton.isHidden = true
          markResolvedButton.isHidden = true

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
