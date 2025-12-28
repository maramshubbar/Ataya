import UIKit

final class PaymentMethodCell: UITableViewCell {

    static let reuseId = "PaymentMethodCell"

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray5.cgColor
        cardView.backgroundColor = .systemBackground
    }

    func configure(title: String, subtitle: String, iconName: String, selected: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle.isEmpty

        if let img = UIImage(named: iconName) {
            iconImageView.image = img
        } else {
            iconImageView.image = UIImage(systemName: iconName)
        }

        if selected {
            cardView.layer.borderColor = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1).cgColor
            cardView.backgroundColor = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1).withAlphaComponent(0.15)
        } else {
            cardView.layer.borderColor = UIColor.systemGray5.cgColor
            cardView.backgroundColor = .systemBackground
        }
    }
}

