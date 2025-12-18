import UIKit

final class DonationCell: UITableViewCell {

    static let reuseId = "DonationCell"

    @IBOutlet weak var donationCardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var donorLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var statusContainerView: UIView!
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var detailsButton: UIButton!

    var onViewDetailsTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        styleUI()
    }

    private func styleUI() {
        // Cell background
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Card (border only)
        donationCardView.layer.cornerRadius = 14
        donationCardView.clipsToBounds = true
        donationCardView.layer.borderWidth = 1
        donationCardView.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor

        // Status badge
        statusContainerView.layer.cornerRadius = 12
        statusContainerView.clipsToBounds = true
        statusLabel.textAlignment = .center

        // Button (yellow)
        detailsButton.layer.cornerRadius = 8
        detailsButton.clipsToBounds = true
        detailsButton.backgroundColor = UIColor(red: 255/255, green: 216/255, blue: 63/255, alpha: 1)
        detailsButton.setTitleColor(.black, for: .normal)
        detailsButton.titleLabel?.textAlignment = .center
    }

    @IBAction func detailsTapped(_ sender: UIButton) {
        onViewDetailsTapped?()
    }

    // ✅ Use this to fill data (same idea as your other cell)
    func configure(title: String,
                   donor: String,
                   location: String,
                   date: String,
                   status: String,
                   imageName: String) {

        titleLabel.text = title
        donorLabel.text = donor
        locationLabel.text = location
        dateLabel.text = date

        statusLabel.text = status

        switch status.lowercased() {
        case "pending":
            statusContainerView.backgroundColor = UIColor(red: 255/255, green: 244/255, blue: 191/255, alpha: 1)
        case "accepted", "approved":
            statusContainerView.backgroundColor = UIColor(red: 213/255, green: 244/255, blue: 214/255, alpha: 1)
        case "rejected":
            statusContainerView.backgroundColor = UIColor(red: 242/255, green: 156/255, blue: 148/255, alpha: 1)
        default:
            statusContainerView.backgroundColor = UIColor.systemGray5
        }

        productImageView.image = UIImage(named: imageName)
    }
}
