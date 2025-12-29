




import UIKit

final class PickupListCardCell: UITableViewCell {

    private let cardView = UIView()

    private let titleLabel = UILabel()
    private let nameLabel = UILabel()
    private let locationLabel = UILabel()
    private let dateLabel = UILabel()

    private let statusBadgeLabel = UILabel()
    private let itemImageView = UIImageView()
    private let viewDetailsButton = UIButton(type: .system)

    private var onTapDetails: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }

    private func buildUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // CARD
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 10
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.hex("#E6E6E6").cgColor
        cardView.layer.masksToBounds = false

        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)

        contentView.addSubview(cardView)

        // LABELS style
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 1

        [nameLabel, locationLabel, dateLabel].forEach {
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor.darkGray
            $0.numberOfLines = 1
        }

        // BADGE
        statusBadgeLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        statusBadgeLabel.textColor = .black
        statusBadgeLabel.textAlignment = .center
        statusBadgeLabel.layer.cornerRadius = 10
        statusBadgeLabel.layer.masksToBounds = true

        // IMAGE
        itemImageView.contentMode = .scaleAspectFit
        itemImageView.translatesAutoresizingMaskIntoConstraints = false

        // BUTTON (Primary Yellow)
        viewDetailsButton.setTitle("View Details", for: .normal)
        viewDetailsButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        viewDetailsButton.setTitleColor(.black, for: .normal)
        viewDetailsButton.backgroundColor = UIColor.hex("#F7D44C") // your primary yellow
        viewDetailsButton.layer.cornerRadius = 8
        viewDetailsButton.layer.masksToBounds = true
        viewDetailsButton.addTarget(self, action: #selector(detailsTapped), for: .touchUpInside)

        // Add to card
        [titleLabel, nameLabel, locationLabel, dateLabel, statusBadgeLabel, itemImageView, viewDetailsButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }

        // Constraints (THIS IS THE MAGIC – no collapsing)
        NSLayoutConstraint.activate([
            // cardView inside cell
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),

            // badge top right
            statusBadgeLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            statusBadgeLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            statusBadgeLabel.heightAnchor.constraint(equalToConstant: 24),
            statusBadgeLabel.widthAnchor.constraint(equalToConstant: 95),

            // image right
            itemImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            itemImageView.topAnchor.constraint(equalTo: statusBadgeLabel.bottomAnchor, constant: 10),
            itemImageView.widthAnchor.constraint(equalToConstant: 70),
            itemImageView.heightAnchor.constraint(equalToConstant: 70),

            // title left
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusBadgeLabel.leadingAnchor, constant: -10),

            // details labels left
            nameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: itemImageView.leadingAnchor, constant: -12),

            locationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            locationLabel.trailingAnchor.constraint(lessThanOrEqualTo: itemImageView.leadingAnchor, constant: -12),

            dateLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: itemImageView.leadingAnchor, constant: -12),

            // button bottom left
            viewDetailsButton.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            viewDetailsButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            viewDetailsButton.heightAnchor.constraint(equalToConstant: 44),
            viewDetailsButton.widthAnchor.constraint(equalToConstant: 160),
            viewDetailsButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12) // ✅ key
        ])
    }

    func configure(
        title: String,
        donor: String,
        location: String,
        date: String,
        status: String,
        imageName: String?,
        onDetails: @escaping () -> Void
    ) {
        self.onTapDetails = onDetails

        titleLabel.text = title
        nameLabel.text = donor
        locationLabel.text = location
        dateLabel.text = date

        statusBadgeLabel.text = status
        statusBadgeLabel.backgroundColor = badgeColor(for: status)

        if let imageName, !imageName.isEmpty {
            itemImageView.image = UIImage(named: imageName)
        } else {
            itemImageView.image = UIImage(systemName: "photo")
            itemImageView.tintColor = .lightGray
        }
    }

    private func badgeColor(for status: String) -> UIColor {
        switch status {
        case "Pending":   return UIColor.hex("#FEE3BC")
        case "Accepted":  return UIColor.hex("#FFFBCC")
        case "Completed": return UIColor.hex("#D2F2C1")
        default:          return UIColor.hex("#F3F3F3")
        }
    }

    @objc private func detailsTapped() {
        onTapDetails?()
    }
}

extension UIColor {
    static func hex(_ hex: String) -> UIColor {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
