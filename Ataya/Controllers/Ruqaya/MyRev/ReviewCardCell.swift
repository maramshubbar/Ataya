import UIKit

final class ReviewCardCell: UITableViewCell {

    static let reuseId = "ReviewCardCell"

    // MARK: - UI
    private let cardView = UIView()

    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let timeLabel = UILabel()

    private let ratingLabel = UILabel()
    private let starsStack = UIStackView()

    private let divider = UIView()
    private let bodyLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("Use programmatic UI")
    }

    private func setupUI() {
        // Card
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = false

        // Shadow (مثل الصورة)
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowOffset = CGSize(width: 0, height: 6)
        cardView.layer.shadowRadius = 10

        contentView.addSubview(cardView)

        // Avatar
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = UIColor.systemGray5
        cardView.addSubview(avatarImageView)

        // Labels
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .black
        cardView.addSubview(nameLabel)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 12, weight: .regular)
        timeLabel.textColor = .systemGray
        cardView.addSubview(timeLabel)

        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        ratingLabel.textColor = .black
        cardView.addSubview(ratingLabel)

        // Stars
        starsStack.translatesAutoresizingMaskIntoConstraints = false
        starsStack.axis = .horizontal
        starsStack.spacing = 3
        starsStack.alignment = .center
        cardView.addSubview(starsStack)

        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.5)
        cardView.addSubview(divider)

        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = .black
        bodyLabel.numberOfLines = 0
        cardView.addSubview(bodyLabel)
    }

    private func setupConstraints() {
        // Card width: design 375 — we make it responsive with margins
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.heightAnchor.constraint(equalToConstant: 215),

            avatarImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            avatarImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -16),

            timeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -16),

            ratingLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            ratingLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),

            starsStack.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor),
            starsStack.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 8),
            starsStack.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -16),

            divider.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 12),
            divider.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            divider.heightAnchor.constraint(equalToConstant: 1),

            bodyLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 12),
            bodyLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            bodyLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // make avatar circular after layout
        avatarImageView.layer.cornerRadius = 22
    }

    func configure(with item: ReviewItem) {
        nameLabel.text = item.name
        timeLabel.text = item.minutesOrDaysAgo
        ratingLabel.text = String(format: "%.1f", item.rating)
        bodyLabel.text = item.text

        if let imgName = item.avatarImageName, let img = UIImage(named: imgName) {
            avatarImageView.image = img
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .systemGray3
        }

        buildStars(rating: item.rating)
    }

    private func buildStars(rating: Double) {
        starsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 5 stars, half supported
        let full = Int(rating)
        let hasHalf = (rating - Double(full)) >= 0.5

        for i in 0..<5 {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFit

            let imageName: String
            if i < full {
                imageName = "star.fill"
            } else if i == full && hasHalf {
                imageName = "star.leadinghalf.filled"
            } else {
                imageName = "star"
            }

            iv.image = UIImage(systemName: imageName)
            iv.tintColor = UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 1) // Ataya Yellow
            iv.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iv.widthAnchor.constraint(equalToConstant: 16),
                iv.heightAnchor.constraint(equalToConstant: 16)
            ])

            starsStack.addArrangedSubview(iv)
        }
    }
}
