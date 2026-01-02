import UIKit

final class NotificationCardCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    private let borderGray = UIColor(hex: "#B8B8B8")

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 8
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = borderGray.cgColor
        cardView.layer.masksToBounds = true

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        messageLabel.font = .systemFont(ofSize: 12, weight: .regular)
        messageLabel.numberOfLines = 2
        timeLabel.font = .systemFont(ofSize: 11, weight: .regular)
        timeLabel.textColor = borderGray
    }

    func configure(title: String, message: String, timeText: String) {
        titleLabel.text = title
        messageLabel.text = message
        timeLabel.text = timeText
    }
}

private extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6 else { self.init(white: 0, alpha: alpha); return }

        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

