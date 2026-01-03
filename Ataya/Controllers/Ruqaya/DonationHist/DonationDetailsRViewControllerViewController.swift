//
//  DonationDetailsRViewControllerViewController.swift
//  DonationHistory
//
//  Created by Ruqaya Habib on 02/01/2026.
//

import UIKit

class DonationDetailsRViewControllerViewController: UIViewController {


    @IBOutlet weak var donationDetailsCard: UIView!
    
    @IBOutlet weak var collectorInfoCard: UIView!
    
    @IBOutlet weak var adminReviewCard: UIView!
    
    
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusBadgeLabel: UILabel!
    @IBOutlet weak var donationImageView: UIImageView!
    
    
    @IBOutlet weak var donationIdValueLabel: UILabel!
    @IBOutlet weak var itemNameValueLabel: UILabel!
    @IBOutlet weak var quantityValueLabel: UILabel!
    @IBOutlet weak var categoryValueLabel: UILabel!
    @IBOutlet weak var expiryDateValueLabel: UILabel!
    @IBOutlet weak var packagingValueLabel: UILabel!
    @IBOutlet weak var allergenInfoValueLabel: UILabel!
    
    
    @IBOutlet weak var collectorNameValueLabel: UILabel!
    @IBOutlet weak var assignedDateValueLabel: UILabel!
    @IBOutlet weak var pickupStatusValueLabel: UILabel!
    @IBOutlet weak var phoneValueLabel: UILabel!
    @IBOutlet weak var emailValueLabel: UILabel!
    @IBOutlet weak var collectorNotesValueLabel: UILabel!
    
    
    @IBOutlet weak var reviewDateValueLabel: UILabel!
    @IBOutlet weak var decisionValueLabel: UILabel!
    @IBOutlet weak var remarksValueLabel: UILabel!
    
    var item: DonationHistoryItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = "Donation Details"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .white


        styleCards()
        styleStatus()
        styleImage()

        bindData()
    }
    
    // MARK: - Styling

      private func styleCards() {
          let cards = [donationDetailsCard, collectorInfoCard, adminReviewCard]
          cards.forEach { card in
              guard let card else { return }
              card.layer.cornerRadius = 8
              card.layer.borderWidth = 1
              card.layer.borderColor = UIColor(hex: "#D0D0D0").cgColor
              card.layer.masksToBounds = true
              card.backgroundColor = .white
          }
      }

      private func styleStatus() {
          statusView.layer.cornerRadius = 8
          statusView.layer.masksToBounds = true

          statusBadgeLabel.layer.cornerRadius = 8
          statusBadgeLabel.clipsToBounds = true
      }

      private func styleImage() {
          donationImageView.layer.cornerRadius = 6
          donationImageView.clipsToBounds = true
          donationImageView.contentMode = .scaleAspectFit
      }

      // MARK: - Bind Data

      private func bindData() {
          guard let item else {
              // Dummy fallback
              applyStatus("Completed")
              return
          }

          applyStatus(item.status.rawValue)
          
          donationIdValueLabel.text = item.donationId
          itemNameValueLabel.text = item.title
          quantityValueLabel.text = item.quantity
          categoryValueLabel.text = item.category
          expiryDateValueLabel.text = item.expiryDate
          packagingValueLabel.text = item.packaging
          allergenInfoValueLabel.text = item.allergenInfo

          collectorNameValueLabel.text = item.collectorName
          assignedDateValueLabel.text = item.assignedDate
          pickupStatusValueLabel.text = item.pickupStatus
          phoneValueLabel.text = item.phone
          emailValueLabel.text = item.email
          collectorNotesValueLabel.text = item.collectorNotes

          reviewDateValueLabel.text = item.reviewDate
          decisionValueLabel.text = item.decision
          remarksValueLabel.text = item.remarks

          if let name = item.imageName, !name.isEmpty {
              donationImageView.image = UIImage(named: name)
          } else {
              donationImageView.image = UIImage(systemName: "photo")
          }
      }

      // MARK: - Status

    private func applyStatus(_ status: String) {
        let s = status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if s == "completed" {

            statusBadgeLabel.text = "Completed"
            statusBadgeLabel.textColor = .black
            statusBadgeLabel.backgroundColor = .clear

            statusView.backgroundColor = UIColor(hex: "#D2F2C1")
            statusView.layer.cornerRadius = 10

        } else if s == "rejected" {

            statusBadgeLabel.text = "Rejected"
            statusBadgeLabel.textColor = .black
            statusBadgeLabel.backgroundColor = .clear

            statusView.backgroundColor = UIColor(hex: "#F44336", alpha: 0.7)
            statusView.layer.cornerRadius = 10

        } else {

            statusBadgeLabel.text = status
            statusBadgeLabel.textColor = .darkGray
            statusBadgeLabel.backgroundColor = .clear

            statusView.backgroundColor = UIColor(hex: "#EDEDED")
            statusView.layer.cornerRadius = 10
        }
    }


  }

  // MARK: - UIColor HEX
//  private extension UIColor {
//      convenience init(hex: String, alpha: CGFloat = 1) {
//          var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//          if hex.hasPrefix("#") { hex.removeFirst() }
//
//          var rgb: UInt64 = 0
//          Scanner(string: hex).scanHexInt64(&rgb)
//
//          let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//          let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//          let b = CGFloat(rgb & 0x0000FF) / 255.0
//
//          self.init(red: r, green: g, blue: b, alpha: alpha)
//      }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

//}
