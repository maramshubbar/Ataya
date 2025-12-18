import UIKit

final class DonationOverviewCell: UITableViewCell {

    static let reuseId = "DonationOverviewCell"

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!

    @IBOutlet weak var donorLabel: UILabel!
    @IBOutlet weak var ngoLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var btnViewDetails: UIButton!

    var onViewDetailsTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        styleUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        donorLabel.text = nil
        ngoLabel.text = nil
        locationLabel.text = nil
        dateLabel.text = nil

        badgeLabel.text = nil
        badgeView.backgroundColor = .clear

        itemImageView.image = nil
    }

    private func styleUI() {
        // Card (border only)
        cardView.layer.cornerRadius = 14
        cardView.clipsToBounds = true
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor

        // Badge
        badgeView.layer.cornerRadius = 8
        badgeView.clipsToBounds = true
        badgeLabel.textAlignment = .center
        badgeLabel.numberOfLines = 1

        // Button
        btnViewDetails.layer.cornerRadius = 4.6
        btnViewDetails.clipsToBounds = true
        btnViewDetails.backgroundColor = UIColor(red: 255/255, green: 216/255, blue: 63/255, alpha: 1)
        btnViewDetails.setTitleColor(.black, for: .normal)
        btnViewDetails.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        // Image (عشان ما تختفي إذا كانت فاتحة/شفافة)
        // Image (بدون خلفية)
        itemImageView.contentMode = .scaleAspectFit
        itemImageView.backgroundColor = .clear
        itemImageView.layer.cornerRadius = 0
        itemImageView.clipsToBounds = false

    }

    @IBAction func viewDetailsTapped(_ sender: UIButton) {
        onViewDetailsTapped?()
    }

    func configure(item: DonationItem) {
        titleLabel.text = item.title
        donorLabel.text = item.donorText
        ngoLabel.text = item.ngoText
        locationLabel.text = item.locationText
        dateLabel.text = item.dateText
        badgeLabel.text = item.status.rawValue

        switch item.status {
        case .pending:
            badgeView.backgroundColor = UIColor(red: 255/255, green: 244/255, blue: 191/255, alpha: 1)
        case .approved:
            badgeView.backgroundColor = UIColor(red: 213/255, green: 244/255, blue: 214/255, alpha: 1)
        case .rejected:
            badgeView.backgroundColor = UIColor(red: 242/255, green: 156/255, blue: 148/255, alpha: 1)
        }

        // Image
        let img = UIImage(named: item.imageName)?.withRenderingMode(.alwaysOriginal)
        let testImg = UIImage(named: "image88")
        print("FOUND image88:", testImg != nil)
        itemImageView.image = testImg

        #if DEBUG
        if img == nil {
            print("❌ Image not found in Assets:", item.imageName)
        }
        #endif
    }
}
/*
 
 
 func configure(title: String,
                location: String,
                reporter: String,
                ngo: String,
                date: String,
                status: String) {

     titleLabel.text = title
     locationLabel.text = location
     reporterLabel.text = reporter
     ngoLabel.text = ngo
     dateLabel.text = date

     badgeLabel.text = status

     if status.lowercased() == "resolved" {
         badgeView.backgroundColor = UIColor(red: 213/255, green: 244/255, blue: 214/255, alpha: 1)
     } else {
         badgeView.backgroundColor = UIColor(red: 255/255, green: 244/255, blue: 191/255, alpha: 1)
     }
 }
 */
