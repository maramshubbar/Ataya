//
//  GiftManagementCell.swift
//  Ataya
//

import UIKit

final class GiftManagementCell: UITableViewCell {

    static let reuseID = "GiftManagementCell"

    struct ViewModel {
        let title: String
        let priceLine: String
        let description: String

        // optional (defaults) — so VC can ignore them
        let imageURL: String?
        let placeholderAssetName: String?

        init(
            title: String,
            priceLine: String,
            description: String,
            imageURL: String? = nil,
            placeholderAssetName: String? = nil
        ) {
            self.title = title
            self.priceLine = priceLine
            self.description = description
            self.imageURL = imageURL
            self.placeholderAssetName = placeholderAssetName
        }
    }

    var onEdit: (() -> Void)?

    private let card = UIView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let descLabel = UILabel()
    private let editButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = true

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 2

        priceLabel.font = .systemFont(ofSize: 14, weight: .medium)
        priceLabel.numberOfLines = 1

        descLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descLabel.numberOfLines = 3
        descLabel.textColor = .secondaryLabel

        editButton.setTitle("Edit", for: .normal)
        editButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, priceLabel, descLabel, editButton])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(card)
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
        ])
    }

    @objc private func editTapped() {
        onEdit?()
    }

    func configure(with vm: ViewModel) {
        titleLabel.text = vm.title
        priceLabel.text = vm.priceLine
        descLabel.text = vm.description
        // intentionally ignoring imageURL/placeholder because you said you don't want them
    }
}
