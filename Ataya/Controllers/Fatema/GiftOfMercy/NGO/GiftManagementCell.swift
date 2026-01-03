//
//  GiftManagementCell.swift
//  Ataya
//

import UIKit

final class GiftManagementCell: UITableViewCell {

    static let reuseID = "GiftManagementCell"

    // MARK: - Callback
    var onEdit: (() -> Void)?

    // MARK: - UI
    private let cardView = UIView()

    // use a container so the image does NOT get cut
    private let thumbContainer = UIView()
    private let thumbImageView = UIImageView()

    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let descriptionLabel = UILabel()

    private let buttonsStack = UIStackView()
    private let editButton = UIButton(type: .system)

    private let accentYellow = UIColor(atayaHex: "F7D44C")

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbImageView.image = nil
        thumbImageView.accessibilityIdentifier = nil
        onEdit = nil
    }

    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Outer card
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 18
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        // ✅ Thumbnail container (rounded + bg)
        thumbContainer.translatesAutoresizingMaskIntoConstraints = false
        thumbContainer.backgroundColor = .clear
        thumbContainer.layer.cornerRadius = 0
        thumbContainer.clipsToBounds = false

        NSLayoutConstraint.activate([
            thumbContainer.widthAnchor.constraint(equalToConstant: 80),
            thumbContainer.heightAnchor.constraint(equalToConstant: 80)
        ])

        // ✅ Image inside (no cropping)
        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbImageView.contentMode = .scaleAspectFit
        thumbImageView.backgroundColor = .clear
        thumbImageView.clipsToBounds = false

        thumbContainer.addSubview(thumbImageView)

        NSLayoutConstraint.activate([
            thumbImageView.topAnchor.constraint(equalTo: thumbContainer.topAnchor, constant: 0),
            thumbImageView.leadingAnchor.constraint(equalTo: thumbContainer.leadingAnchor, constant: 0),
            thumbImageView.trailingAnchor.constraint(equalTo: thumbContainer.trailingAnchor, constant: 0),
            thumbImageView.bottomAnchor.constraint(equalTo: thumbContainer.bottomAnchor, constant: 0),
        ])

        // Labels
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.numberOfLines = 2

        priceLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        priceLabel.textColor = .black
        priceLabel.numberOfLines = 1

        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2

        let textStack = UIStackView(arrangedSubviews: [titleLabel, priceLabel, descriptionLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let topRow = UIStackView(arrangedSubviews: [thumbContainer, textStack])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 12
        topRow.translatesAutoresizingMaskIntoConstraints = false

        // Buttons row
        buttonsStack.axis = .horizontal
        buttonsStack.alignment = .center
        buttonsStack.spacing = 0
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        styleYellowButton(editButton, title: "Edit")
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)

        let spacer = UIView()
        buttonsStack.addArrangedSubview(editButton)
        buttonsStack.addArrangedSubview(spacer)

        // Main stack inside card
        let mainStack = UIStackView(arrangedSubviews: [topRow, buttonsStack])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

            editButton.heightAnchor.constraint(equalToConstant: 44),
            editButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 110)
        ])
    }

    private func styleYellowButton(_ button: UIButton, title: String) {
        button.configuration = nil
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = accentYellow
        button.layer.cornerRadius = 8

        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
            button.configuration = config
        } else {
            button.contentEdgeInsets = .zero
        }
    }

    // MARK: - ViewModel
    struct ViewModel {
        let title: String
        let priceLine: String
        let description: String
        let imageURL: String?   // ✅ Cloudinary URL
    }

    func configure(with model: ViewModel) {
        titleLabel.text = model.title
        priceLabel.text = model.priceLine
        descriptionLabel.text = model.description

        thumbImageView.setRemoteImage(model.imageURL, placeholder: nil)
    }

    // MARK: - Actions
    @objc private func editTapped() {
        onEdit?()
    }
}

extension UIImageView {
    func setRemoteImage(_ urlString: String?, placeholder: UIImage? = nil) {
        ImageLoader.shared.setImage(on: self, from: urlString, placeholder: placeholder)
    }
}
