//
//  GiftManagementCell.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//


import UIKit

final class GiftManagementCell: UITableViewCell {

    static let reuseID = "GiftManagementCell"

    // MARK: - Callbacks
    var onEdit: (() -> Void)?
    var onView: (() -> Void)?
    var onToggleActive: ((Bool) -> Void)?

    // MARK: - UI
    private let card = UIView()
    private let giftNameLabel = UILabel()
    private let pricingLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let statusSwitch = UISwitch()
    private let activeLabel = UILabel()

    private let editButton = UIButton(type: .system)
    private let viewButton = UIButton(type: .system)

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

    // MARK: - Setup
    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Card
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.addSubview(card)

        // Labels
        giftNameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        giftNameLabel.numberOfLines = 2

        pricingLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        pricingLabel.textColor = .systemYellow

        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2

        [giftNameLabel, pricingLabel, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview($0)
        }

        // Switch
        statusSwitch.translatesAutoresizingMaskIntoConstraints = false
        statusSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        card.addSubview(statusSwitch)

        activeLabel.translatesAutoresizingMaskIntoConstraints = false
        activeLabel.font = .systemFont(ofSize: 12)
        activeLabel.textColor = .secondaryLabel
        activeLabel.text = "Active"
        card.addSubview(activeLabel)

        // Buttons
        editButton.translatesAutoresizingMaskIntoConstraints = false
        viewButton.translatesAutoresizingMaskIntoConstraints = false

        editButton.setTitle("Edit", for: .normal)
        editButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        editButton.setTitleColor(yellow, for: .normal)
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = yellow.cgColor
        editButton.layer.cornerRadius = 12
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)

        viewButton.setTitle("View", for: .normal)
        viewButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        viewButton.setTitleColor(.black, for: .normal)
        viewButton.backgroundColor = yellow
        viewButton.layer.cornerRadius = 12
        viewButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)

        card.addSubview(editButton)
        card.addSubview(viewButton)

        // Constraints
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            giftNameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            giftNameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            giftNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusSwitch.leadingAnchor, constant: -8),

            statusSwitch.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            statusSwitch.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            activeLabel.topAnchor.constraint(equalTo: statusSwitch.bottomAnchor, constant: 2),
            activeLabel.centerXAnchor.constraint(equalTo: statusSwitch.centerXAnchor),

            pricingLabel.topAnchor.constraint(equalTo: giftNameLabel.bottomAnchor, constant: 4),
            pricingLabel.leadingAnchor.constraint(equalTo: giftNameLabel.leadingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: pricingLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: giftNameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            editButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            editButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            editButton.widthAnchor.constraint(equalToConstant: 80),
            editButton.heightAnchor.constraint(equalToConstant: 34),
            editButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),

            viewButton.centerYAnchor.constraint(equalTo: editButton.centerYAnchor),
            viewButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            viewButton.widthAnchor.constraint(equalToConstant: 80),
            viewButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    // MARK: - Public
    func configure(with gift: GiftDefinition) {
        giftNameLabel.text = gift.name
        descriptionLabel.text = gift.description

        switch gift.pricingType {
        case .fixed(let amount):
            pricingLabel.text = String(format: "$%.2f (Fixed)", amount)
        case .custom:
            pricingLabel.text = "Custom amount"
        }

        statusSwitch.isOn = gift.isActive
        activeLabel.text = gift.isActive ? "Active" : "Inactive"
    }

    // MARK: - Actions
    @objc private func switchChanged(_ sender: UISwitch) {
        activeLabel.text = sender.isOn ? "Active" : "Inactive"
        onToggleActive?(sender.isOn)
    }

    @objc private func editTapped() {
        onEdit?()
    }

    @objc private func viewTapped() {
        onView?()
    }
}
