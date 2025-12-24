//
//  CardChoiceCell.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//

import UIKit

final class CardChoiceCell: UICollectionViewCell {

    static let reuseID = "CardChoiceCell"

    var onChooseTapped: (() -> Void)?
    var onZoomTapped: (() -> Void)?

    private let cardView = UIView()
    private let imageView = UIImageView()

    private let zoomButton = UIButton(type: .system)

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
        imageView.image = nil
        onChooseTapped = nil
        onZoomTapped = nil
    }

    private func buildUI() {
        contentView.backgroundColor = .clear

        // Card container
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
        cardView.clipsToBounds = true

        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 6)

        // Image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12

        // Zoom button (top-right)
        zoomButton.setImage(UIImage(systemName: "plus.magnifyingglass"), for: .normal)
        zoomButton.tintColor = .white
        zoomButton.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        zoomButton.layer.cornerRadius = 20
        zoomButton.clipsToBounds = true
        zoomButton.addTarget(self, action: #selector(zoomTapped), for: .touchUpInside)

        // Choose
        chooseButton.setTitle("Choose this card", for: .normal)
        chooseButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        chooseButton.contentHorizontalAlignment = .leading
        chooseButton.addTarget(self, action: #selector(chooseTapped), for: .touchUpInside)

        chevron.contentMode = .scaleAspectFit

        contentView.addSubview(cardView)
        [imageView, zoomButton, chooseButton, chevron].forEach {
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

            imageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalToConstant: 240),

            zoomButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 10),
            zoomButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10),
            zoomButton.widthAnchor.constraint(equalToConstant: 40),
            zoomButton.heightAnchor.constraint(equalToConstant: 40),

            chooseButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            chooseButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 14),
            chooseButton.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -14),

            chevron.centerYAnchor.constraint(equalTo: chooseButton.centerYAnchor),
            chevron.leadingAnchor.constraint(equalTo: chooseButton.trailingAnchor, constant: 8),
            chevron.widthAnchor.constraint(equalToConstant: 14),
            chevron.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    func configure(image: UIImage?, accent: UIColor) {
        imageView.image = image
        chooseButton.setTitleColor(accent, for: .normal)
        chevron.tintColor = accent
    }



    @objc private func chooseTapped() {
        onChooseTapped?()
    }

    @objc private func zoomTapped() {
        onZoomTapped?()
    }
}
