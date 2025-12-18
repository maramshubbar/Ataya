import UIKit

final class BadgeCardCell: UICollectionViewCell {

    static let reuseId = "BadgeCardCell"

    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        styleCard()
    }

    private func styleCard() {
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(white: 0.90, alpha: 1).cgColor
        contentView.clipsToBounds = true

        // ✅ لا تسوي شي إذا outlets مو مربوطة
        guard let titleLabel, let subtitleLabel, let iconImageView else {
            print("❌ BadgeCardCell outlets NOT connected in XIB")
            return
        }

        //titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping

        // يخليها تنزل سطر ثاني بدل ما تنقص
        titleLabel.adjustsFontSizeToFitWidth = false

       /* subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = UIColor(white: 0.55, alpha: 1)
        subtitleLabel.numberOfLines = 2
*/
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor(red: 255/255, green: 216/255, blue: 63/255, alpha: 1)
    }

    func configure(title: String, subtitle: String, icon: UIImage?) {
        titleLabel?.text = title
        subtitleLabel?.text = subtitle
        iconImageView?.image = icon
    }
}

