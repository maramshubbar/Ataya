//
//  GiftCardCell.swift
//  Ataya
//
//  Created by Fatema Maitham on 24/12/2025.
//

import UIKit

final class GiftCardCell: UICollectionViewCell {

    static let reuseID = "GiftCardCell"

    var onChooseTapped: (() -> Void)?
    var onAmountChanged: ((String) -> Void)?

    private let cardView = UIView()
    private let heartImageView = UIImageView()

    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let amountField = UITextField()
    private let descLabel = UILabel()

    private let chooseButton = UIButton(type: .system)
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    private var descTopToPrice: NSLayoutConstraint!
    private var descTopToAmount: NSLayoutConstraint!

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
        heartImageView.image = nil
        amountField.text = nil
        priceLabel.text = nil
        onChooseTapped = nil
        onAmountChanged = nil
    }

    private func buildUI() {
        contentView.backgroundColor = .clear

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
        cardView.clipsToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 6)

        heartImageView.contentMode = .scaleAspectFit

        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 22, weight: .heavy)
        titleLabel.textColor = .label

        priceLabel.font = .systemFont(ofSize: 20, weight: .heavy)

        amountField.placeholder = "Enter donation value"
        amountField.backgroundColor = UIColor.systemGray6
        amountField.layer.cornerRadius = 10
        amountField.clipsToBounds = true
        amountField.font = .systemFont(ofSize: 14, weight: .semibold)
        amountField.textColor = .label
        amountField.keyboardType = .decimalPad
        amountField.setLeftPadding(14)
        amountField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        amountField.addDoneToolbar()

        descLabel.numberOfLines = 0
        descLabel.font = .systemFont(ofSize: 17, weight: .regular)
        descLabel.textColor = UIColor.label.withAlphaComponent(0.7)

        chooseButton.setTitle("Choose Gift", for: .normal)
        chooseButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        chooseButton.contentHorizontalAlignment = .leading
        chooseButton.addTarget(self, action: #selector(chooseTapped), for: .touchUpInside)

        chevron.contentMode = .scaleAspectFit

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

            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            priceLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            amountField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            amountField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            amountField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            amountField.heightAnchor.constraint(equalToConstant: 44),

            descLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            chooseButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),

            chevron.centerYAnchor.constraint(equalTo: chooseButton.centerYAnchor),
            chevron.leadingAnchor.constraint(equalTo: chooseButton.trailingAnchor, constant: 8),
            chevron.widthAnchor.constraint(equalToConstant: 14),
            chevron.heightAnchor.constraint(equalToConstant: 14)
        ])

        descTopToPrice = descLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10)
        descTopToAmount = descLabel.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 12)

        descTopToPrice.isActive = true
        descTopToAmount.isActive = false

        let descBottom = descLabel.bottomAnchor.constraint(lessThanOrEqualTo: chooseButton.topAnchor, constant: -14)
        let chooseBottom = chooseButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18)

        NSLayoutConstraint.activate([descBottom, chooseBottom])
    }

    func configure(item: MercyGift, accent: UIColor, existingAmount: Decimal?) {
        // Image (URL first, then asset)
        if let url = item.imageURL, !url.isEmpty {
            ImageLoader.shared.setImage(on: heartImageView, from: url, placeholder: nil)
        } else if let asset = item.assetName, !asset.isEmpty {
            heartImageView.image = UIImage(named: asset)
        } else {
            heartImageView.image = nil
        }

        titleLabel.text = item.title
        chooseButton.setTitleColor(accent, for: .normal)
        chevron.tintColor = accent
        descLabel.text = item.description

        switch item.pricingMode {
        case .fixed:
            priceLabel.isHidden = false
            amountField.isHidden = true
            priceLabel.textColor = accent
            priceLabel.text = (item.fixedAmount ?? 0).moneyString()

            descTopToPrice.isActive = true
            descTopToAmount.isActive = false

        case .custom:
            priceLabel.isHidden = true
            amountField.isHidden = false

            if let existingAmount {
                amountField.text = existingAmount.plainString()
            } else {
                amountField.text = nil
            }

            descTopToPrice.isActive = false
            descTopToAmount.isActive = true
        }
    }

    @objc private func chooseTapped() {
        onChooseTapped?()
    }

    @objc private func amountChanged() {
        onAmountChanged?(amountField.text ?? "")
    }
}
