import UIKit

final class NotificationCardCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    private let borderGray = AppColors.grayBorder


    // spacing below card (gap between cards)
    private var bottomConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        clipsToBounds = false

        // Card style
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 8
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = borderGray.cgColor
        cardView.layer.masksToBounds = true

        // Text
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)

        messageLabel.textColor = .black
        messageLabel.font = .systemFont(ofSize: 12, weight: .regular)
        messageLabel.numberOfLines = 2

        timeLabel.textColor = borderGray
        timeLabel.font = .systemFont(ofSize: 11, weight: .regular)


        pinCardToContent(gap: 12)
    }

    private func pinCardToContent(gap: CGFloat) {
        guard let cardView else { return }
        cardView.translatesAutoresizingMaskIntoConstraints = false

        // remove existing if any (safe)
        NSLayoutConstraint.deactivate(cardView.constraints)

        // pin to contentView
        let top = cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0)
        let leading = cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0)
        let trailing = cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0)
        let bottom = cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -gap)
        bottomConstraint = bottom

        NSLayoutConstraint.activate([top, leading, trailing, bottom])
    }

    func configure(title: String, message: String, timeText: String) {
        titleLabel.text = title
        messageLabel.text = message
        timeLabel.text = timeText
    }
}

// MARK: - Hex helper
//private extension UIColor {
//    convenience init(hex: String, alpha: CGFloat = 1.0) {
//        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//        if h.hasPrefix("#") { h.removeFirst() }
//        guard h.count == 6 else { self.init(white: 0, alpha: alpha); return }
//
//        var rgb: UInt64 = 0
//        Scanner(string: h).scanHexInt64(&rgb)
//
//        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//        let b = CGFloat(rgb & 0x0000FF) / 255.0
//
//        self.init(red: r, green: g, blue: b, alpha: alpha)
//    }
//}
