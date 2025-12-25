//
//  CardDesignManagementCell.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//

import UIKit

final class CardDesignManagementCell: UITableViewCell {

    static let reuseID = "CardDesignManagementCell"

    // MARK: - Callbacks
    var onEdit: (() -> Void)?
    var onPreview: (() -> Void)?
    var onToggleActive: ((Bool) -> Void)?

    // MARK: - UI
    private let card = UIView()
    private let previewImageView = UIImageView()
    private let nameLabel = UILabel()
    private let activeSwitch = UISwitch()
    private let activeLabel = UILabel()
    private let previewButton = UIButton(type: .system)
    private let editButton = UIButton(type: .system)

    private let yellow = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1)

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup UI
    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Card container
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.addSubview(card)

        // Preview image
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        previewImageView.layer.cornerRadius = 10
        previewImageView.backgroundColor = .systemGray6
        card.addSubview(previewImageView)

        // Name label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.numberOfLines = 2
        card.addSubview(nameLabel)

        // Switch + label
        activeSwitch.translatesAutoresizingMaskIntoConstraints = false
        activeSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        card.addSubview(activeSwitch)

        activeLabel.translatesAutoresizingMaskIntoConstraints = false
        activeLabel.font = .systemFont(ofSize: 12)
        activeLabel.textColor = .secondaryLabel
        activeLabel.text = "Active"
        card.addSubview(activeLabel)

        // Buttons
        previewButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false

        previewButton.setTitle("Preview", for: .normal)
        previewButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        previewButton.setTitleColor(.black, for: .normal)
        previewButton.backgroundColor = yellow
        previewButton.layer.cornerRadius = 12
        previewButton.addTarget(self, action: #selector(previewTapped), for: .touchUpInside)

        editButton.setTitle("Edit", for: .normal)
        editButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        editButton.setTitleColor(yellow, for: .normal)
        editButton.layer.cornerRadius = 12
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = yellow.cgColor
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)

        card.addSubview(previewButton)
        card.addSubview(editButton)

        // MARK: Constraints
        NSLayoutConstraint.activate([
            // card in contentView
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // preview image
            previewImageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            previewImageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            previewImageView.widthAnchor.constraint(equalToConstant: 70),
            previewImageView.heightAnchor.constraint(equalToConstant: 70),

            // name
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: previewImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: activeSwitch.leadingAnchor, constant: -8),

            // switch
            activeSwitch.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            activeSwitch.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            activeLabel.topAnchor.constraint(equalTo: activeSwitch.bottomAnchor, constant: 2),
            activeLabel.centerXAnchor.constraint(equalTo: activeSwitch.centerXAnchor),

            // buttons
            editButton.leadingAnchor.constraint(equalTo: previewImageView.leadingAnchor),
            editButton.topAnchor.constraint(equalTo: previewImageView.bottomAnchor, constant: 10),
            editButton.widthAnchor.constraint(equalToConstant: 80),
            editButton.heightAnchor.constraint(equalToConstant: 34),
            editButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),

            previewButton.leadingAnchor.constraint(equalTo: editButton.trailingAnchor, constant: 12),
            previewButton.centerYAnchor.constraint(equalTo: editButton.centerYAnchor),
            previewButton.widthAnchor.constraint(equalToConstant: 100),
            previewButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    // MARK: - Public configure

    func configure(with design: CardDesign) {
        nameLabel.text = design.name
        activeSwitch.isOn = design.isActive
        activeLabel.text = design.isActive ? "Active" : "Inactive"

        previewImageView.image = UIImage(named: design.imageName)
    }

    // MARK: - Actions
    @objc private func switchChanged(_ sender: UISwitch) {
        activeLabel.text = sender.isOn ? "Active" : "Inactive"
        onToggleActive?(sender.isOn)
    }

    @objc private func previewTapped() {
        onPreview?()
    }

    @objc private func editTapped() {
        onEdit?()
    }
}
