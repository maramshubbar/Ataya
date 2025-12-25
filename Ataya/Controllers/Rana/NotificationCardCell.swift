import UIKit

final class NotificationCardCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    private let yellow = UIColor(hex: "#F7D44C")
    private let borderGray = UIColor(hex: "#B8B8B8")

    // GAP between cards (Figma spacing)
    var cardGap: CGFloat = 12 {
        didSet { bottomConstraint?.constant = -cardGap }
    }

    private var didApplyConstraints = false
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

        // Text styles
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)

        messageLabel.textColor = .black
        messageLabel.font = .systemFont(ofSize: 12, weight: .regular)
        messageLabel.numberOfLines = 2 // ✅ smaller (your screenshot was too tall)

        timeLabel.textColor = borderGray
        timeLabel.font = .systemFont(ofSize: 11, weight: .regular)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyRuntimeConstraintsIfNeeded()
    }

    private func applyRuntimeConstraintsIfNeeded() {
        guard !didApplyConstraints else { return }
        guard let host = cardView.superview else { return } // ✅ real parent in storyboard

        // Remove ALL constraints in the host that touch cardView (fixes the “header inside border” bug)
        let kill = host.constraints.filter {
            ($0.firstItem as? UIView) == cardView || ($0.secondItem as? UIView) == cardView
        }
        NSLayoutConstraint.deactivate(kill)

        cardView.translatesAutoresizingMaskIntoConstraints = false

        let top = cardView.topAnchor.constraint(equalTo: host.topAnchor, constant: 0)
        let leading = cardView.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: 0)
        let trailing = cardView.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: 0)

        // ✅ THIS is the gap between cards
        let bottom = cardView.bottomAnchor.constraint(equalTo: host.bottomAnchor, constant: -cardGap)
        bottomConstraint = bottom

        NSLayoutConstraint.activate([top, leading, trailing, bottom])

        didApplyConstraints = true
    }

    // Hover / press
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        let changes = {
            if highlighted {
                self.cardView.backgroundColor = UIColor(hex: "#FFFBE7")
                self.cardView.layer.borderColor = self.yellow.cgColor
                self.cardView.transform = CGAffineTransform(scaleX: 0.99, y: 0.99)
            } else {
                self.cardView.backgroundColor = .white
                self.cardView.layer.borderColor = self.borderGray.cgColor
                self.cardView.transform = .identity
            }
        }

        if animated {
            UIView.animate(withDuration: 0.12, animations: changes)
        } else {
            changes()
        }
    }

    func configure(title: String, message: String, timeText: String) {
        titleLabel.text = title
        messageLabel.text = message
        timeLabel.text = timeText
    }
}

// MARK: - Hex helper
private extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6 else { self.init(white: 0, alpha: alpha); return }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
