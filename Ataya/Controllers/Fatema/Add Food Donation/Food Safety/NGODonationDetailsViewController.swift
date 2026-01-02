//
//  NGODonationDetailsViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 02/12/2025.
//
import UIKit

final class NGODonationDetailsViewController: UIViewController {

    @IBOutlet weak var donationCardView: UIView!
    @IBOutlet weak var donorCardView: UIView!
    @IBOutlet weak var collectorCardView: UIView!
    @IBOutlet weak var proceedToInspectionTapped: UIButton!

    // ✅ set from overview
    var donationId: String!

    // ✅ OPTIONAL outlets (إذا عندج labels وصلّيهم، إذا ما عندج عادي)
    @IBOutlet weak var donationTitleLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var donorNameLabel: UILabel?
    @IBOutlet weak var donorCityLabel: UILabel?
    @IBOutlet weak var donorEmailLabel: UILabel?
    @IBOutlet weak var donorPhoneLabel: UILabel?
    @IBOutlet weak var safetyConfirmedLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        donationCardView.applyCardStyle()
        donorCardView.applyCardStyle()
        collectorCardView.applyCardStyle()

        loadDonation()
    }

    private func loadDonation() {
        DonationService.shared.getDonation(donationId: donationId) { [weak self] doc in
            guard let self, let data = doc?.data() else { return }

            let itemName = (data["itemName"] as? String) ?? "—"
            let code = (data["donationCode"] as? String) ?? self.donationId
            let status = (data["status"] as? String) ?? "—"

            let donorName = (data["donorName"] as? String) ?? "—"
            let donorCity = (data["donorCity"] as? String) ?? "—"
            let donorEmail = (data["donorEmail"] as? String) ?? "—"
            let donorPhone = (data["donorPhone"] as? String) ?? "—"
            let safety = (data["donorSafetyConfirmed"] as? Bool) ?? false

            self.donationTitleLabel?.text = "\(itemName) (\(code))"
            self.statusLabel?.text = status.capitalized

            self.donorNameLabel?.text = donorName
            self.donorCityLabel?.text = donorCity
            self.donorEmailLabel?.text = donorEmail
            self.donorPhoneLabel?.text = donorPhone

            self.safetyConfirmedLabel?.text = safety ? "✅ Confirmed" : "⚠️ Not confirmed"
        }
    }

    @IBAction func proceedToInspectionTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "InspectDonationViewController") as! InspectDonationViewController
        vc.donationId = donationId
        navigationController?.pushViewController(vc, animated: true)
    }
}
