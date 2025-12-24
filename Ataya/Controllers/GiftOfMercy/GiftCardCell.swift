//
//  GiftCardCell.swift
//  Ataya
//
//  Created by Fatema Maitham on 24/12/2025.
//


import UIKit

final class GiftCardCell: UICollectionViewCell {

    static let reuseID = "GiftCardCell"

    // Callbacks
    var onChooseTapped: (() -> Void)?
    var onAmountChanged: ((String) -> Void)?

    // UI
    private let cardView = UIView()
    private let heartImageView = UIImageView()

    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let amountField = UITextField()
    private let descLabel = UILabel()

    private let chooseButton = UIButton(type: .system)
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
        buildConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
        buildConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        amountField.text = nil
        priceLabel.text = nil
        onChooseTapped = nil
        onAmountChanged = nil
    }

    private func buildUI() {
        contentView.backgroundColor = .clear

        // Card
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
        cardView.clipsToBounds = true

        // Shadow like screenshot
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 6)

        // Image
        heartImageView.contentMode = .scaleAspectFit

        // Title
        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 22, weight: .heavy)
        titleLabel.textColor = .label

        // Price
        priceLabel.font = .systemFont(ofSize: 20, weight: .heavy)

        // Amount Field
        amountField.placeholder = "Enter donation value"
        amountField.backgroundColor = UIColor.systemGray6
        amountField.layer.cornerRadius = 10
        amountField.clipsToBounds = true
        amountField.font = .systemFont(ofSize: 16, weight: .semibold)
        amountField.textColor = .label
        amountField.keyboardType = .decimalPad
        amountField.setLeftPadding(14)
        amountField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        amountField.addDoneToolbar()

        // Description
        descLabel.numberOfLines = 0
        descLabel.font = .systemFont(ofSize: 17, weight: .regular)
        descLabel.textColor = UIColor.label.withAlphaComponent(0.7)

        // Choose button (text + chevron)
        chooseButton.setTitle("Choose Gift", for: .normal)
        chooseButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        chooseButton.contentHorizontalAlignment = .leading
        chooseButton.addTarget(self, action: #selector(chooseTapped), for: .touchUpInside)

        chevron.contentMode = .scaleAspectFit
        chevron.tintColor = .systemGreen

        contentView.addSubview(cardView)
        [heartImageView, titleLabel, priceLabel, amountField, descLabel, chooseButton, chevron].forEach {
            cardView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        cardView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func buildConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            heartImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            heartImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            heartImageView.heightAnchor.constraint(equalToConstant: 118),
            heartImageView.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.55),

            titleLabel.topAnchor.constraint(equalTo: heartImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            // Price / Field area (same place)
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            priceLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            amountField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            amountField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            amountField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            amountField.heightAnchor.constraint(equalToConstant: 44),

            descLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
            descLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            // Choose button bottom
            chooseButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            chooseButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14),

            chevron.centerYAnchor.constraint(equalTo: chooseButton.centerYAnchor),
            chevron.leadingAnchor.constraint(equalTo: chooseButton.trailingAnchor, constant: 8),
            chevron.widthAnchor.constraint(equalToConstant: 14),
            chevron.heightAnchor.constraint(equalToConstant: 14),

            // Description must not overlap button
            descLabel.bottomAnchor.constraint(lessThanOrEqualTo: chooseButton.topAnchor, constant: -14)
        ])
    }

    func configure(item: GiftItem, accent: UIColor, existingAmount: Decimal?) {
        heartImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        descLabel.text = item.description

        switch item.pricing {
        case .fixed(let amount):
            priceLabel.isHidden = false
            amountField.isHidden = true
            priceLabel.textColor = accent
            priceLabel.text = amount.moneyString

        case .custom:
            priceLabel.isHidden = true
            amountField.isHidden = false
            amountField.text = existingAmount?.moneyString ?? ""
        }
    }


    @objc private func chooseTapped() {
        onChooseTapped?()
    }

    @objc private func amountChanged() {
        onAmountChanged?(amountField.text ?? "")
    }
}
