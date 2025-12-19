import UIKit

final class BadgeCardCell: UICollectionViewCell {

    static let reuseId = "BadgeCardCell"

    // ✅ خليته Optional عشان ما يكراش لو الربط غلط
    @IBOutlet weak var cardView: UIView?

    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?

    private let corner: CGFloat = 24

    override func awakeFromNib() {
        super.awakeFromNib()
        styleCard()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()

        // ✅ الشادو يلف حول الـcontentView (لأن اللون عليه)
        layer.shadowPath = UIBezierPath(
            roundedRect: contentView.frame,
            cornerRadius: corner
        ).cgPath
    }

    private func styleCard() {

        // ✅ الأساس
        backgroundColor = .clear
        contentView.backgroundColor = .clear  // اللون بينحط من RewardsVC
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = UIColor.clear.cgColor

        // ✅ الروند على contentView (هذا اللي تبينه)
        contentView.layer.cornerRadius = corner
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true

        // ✅ الشادو على cell.layer
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.04
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 3)


        // ✅ مهم: أي View داخل الخلية لا يخرب لون contentView
        cardView?.backgroundColor = .clear
        cardView?.layer.cornerRadius = corner
        cardView?.layer.masksToBounds = true

        // ✅ labels/icons (اختياري)
        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .center
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.adjustsFontSizeToFitWidth = false

        subtitleLabel?.numberOfLines = 2
        subtitleLabel?.textAlignment = .center
        subtitleLabel?.lineBreakMode = .byWordWrapping

        iconImageView?.contentMode = .scaleAspectFit
        iconImageView?.tintColor = UIColor(red: 255/255, green: 216/255, blue: 63/255, alpha: 1)
    }

    func configure(title: String, subtitle: String, icon: UIImage?) {
        titleLabel?.text = title
        subtitleLabel?.text = subtitle
        iconImageView?.image = icon
    }
}
