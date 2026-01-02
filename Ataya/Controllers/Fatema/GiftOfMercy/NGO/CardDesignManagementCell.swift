//
//  CardDesignManagementCell.swift
//  Ataya
//

import UIKit

final class CardDesignManagementCell: UITableViewCell {

    static let reuseID = "CardDesignManagementCell"

    // MARK: - Callbacks
    var onEdit: (() -> Void)?
    var onPreview: (() -> Void)?

    // MARK: - UI

    private let cardView = UIView()

    private let thumbImageView = UIImageView()
    private let nameLabel = UILabel()
    private let statusLabel = UILabel()

    private let buttonsStack = UIStackView()
    private let editButton = UIButton(type: .system)
    private let previewButton = UIButton(type: .system)

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
        nameLabel.text = nil
        statusLabel.text = nil
    }

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // card
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

        // thumbnail
        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.clipsToBounds = true
        thumbImageView.layer.cornerRadius = 8
        thumbImageView.backgroundColor = .systemGray5

        // labels
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        statusLabel.font = .systemFont(ofSize: 13, weight: .medium)

        // buttons stack
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 16
        buttonsStack.alignment = .center
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        // Edit outlined
        styleOutlinedButton(editButton, title: "Edit")
        // Preview filled
        styleFilledButton(previewButton, title: "Preview")

        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        previewButton.addTarget(self, action: #selector(previewTapped), for: .touchUpInside)

        buttonsStack.addArrangedSubview(editButton)
        buttonsStack.addArrangedSubview(previewButton)

        // vertical stack
        let textStack = UIStackView(arrangedSubviews: [nameLabel, statusLabel, buttonsStack])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(thumbImageView)
        cardView.addSubview(textStack)

        NSLayoutConstraint.activate([
            thumbImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            thumbImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            thumbImageView.widthAnchor.constraint(equalToConstant: 80),
            thumbImageView.heightAnchor.constraint(equalToConstant: 80),

            textStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            textStack.leadingAnchor.constraint(equalTo: thumbImageView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            textStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

            editButton.heightAnchor.constraint(equalToConstant: 44),
            previewButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Button Styles

    private func styleOutlinedButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(accentYellow, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1.2
        button.layer.borderColor = accentYellow.cgColor

        if #available(iOS 15.0, *) {
            var config = button.configuration ?? .plain()
            config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
            button.configuration = config
        } else {
            button.contentEdgeInsets = .zero
        }
    }

    private func styleFilledButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = accentYellow
        button.layer.cornerRadius = 8

        if #available(iOS 15.0, *) {
            var config = button.configuration ?? .plain()
            config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
            button.configuration = config
        } else {
            button.contentEdgeInsets = .zero
        }
    }

    // MARK: - Configure

    func configure(with design: CardDesign) {
        nameLabel.text = design.name

        // ✅ placeholder = asset imageName (fallback)
        let placeholder = UIImage(named: design.imageName)

        // ✅ Cloudinary if available, otherwise asset
        if let url = design.imageURL, !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ImageLoader.shared.setImage(on: thumbImageView, from: url, placeholder: placeholder)
        } else {
            thumbImageView.image = placeholder
        }

        if design.isActive {
            statusLabel.text = design.isDefault ? "Active · Default" : "Active"
            statusLabel.textColor = .systemGreen
        } else {
            statusLabel.text = "Inactive"
            statusLabel.textColor = .systemGray
        }
    }

    // MARK: - Actions

    @objc private func editTapped() { onEdit?() }
    @objc private func previewTapped() { onPreview?() }
}
