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

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 18
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)

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
        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        statusLabel.font = .systemFont(ofSize: 12, weight: .medium)

        // buttons
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 12
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        styleOutlinedButton(editButton, title: "Edit")
        styleFilledButton(previewButton, title: "Preview")

        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        previewButton.addTarget(self, action: #selector(previewTapped), for: .touchUpInside)

        buttonsStack.addArrangedSubview(editButton)
        buttonsStack.addArrangedSubview(previewButton)

        // vertical stack (name + status + buttons)
        let textStack = UIStackView(arrangedSubviews: [nameLabel, statusLabel, buttonsStack])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(thumbImageView)
        cardView.addSubview(textStack)

        NSLayoutConstraint.activate([
            thumbImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            thumbImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            thumbImageView.widthAnchor.constraint(equalToConstant: 72),
            thumbImageView.heightAnchor.constraint(equalToConstant: 72),

            textStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            textStack.leadingAnchor.constraint(equalTo: thumbImageView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            textStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
        ])
    }

    private func styleOutlinedButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .white
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = accentYellow.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
    }

    private func styleFilledButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = accentYellow
        button.layer.cornerRadius = 14
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
    }

    // MARK: - Configure

    func configure(with design: CardDesign) {
        nameLabel.text = design.name
        thumbImageView.image = UIImage(named: design.imageName)

        if design.isActive {
            statusLabel.text = design.isDefault ? "Active · Default" : "Active"
            statusLabel.textColor = UIColor.systemGreen
        } else {
            statusLabel.text = "Inactive"
            statusLabel.textColor = UIColor.systemGray
        }
    }

    // MARK: - Actions

    @objc private func editTapped() {
        onEdit?()
    }

    @objc private func previewTapped() {
        onPreview?()
    }
}
