// GiftDesignCell.swift

import UIKit

final class GiftDesignCell: UICollectionViewCell {

    static let reuseId = "GiftDesignCell"

    private let card = UIView()
    private let imageView = UIImageView()
    private let chooseButton = UIButton(type: .system)
    private let zoomButton = UIButton(type: .system)

    var onChooseTapped: (() -> Void)?
    var onZoomTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }

    private func build() {
        contentView.backgroundColor = .clear

        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        card.applyCardShadow()

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 14

        chooseButton.setTitle("Choose this card  ", for: .normal)
        chooseButton.setTitleColor(.systemGreen, for: .normal)
        chooseButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        chooseButton.contentHorizontalAlignment = .leading
        chooseButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        chooseButton.tintColor = .systemGreen
        chooseButton.semanticContentAttribute = .forceRightToLeft
        chooseButton.addTarget(self, action: #selector(chooseTapped), for: .touchUpInside)

        zoomButton.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        zoomButton.layer.cornerRadius = 18
        zoomButton.clipsToBounds = true
        zoomButton.setImage(UIImage(systemName: "plus.magnifyingglass"), for: .normal)
        zoomButton.tintColor = .white
        zoomButton.addTarget(self, action: #selector(zoomTapped), for: .touchUpInside)

        contentView.addSubview(card)
        [imageView, chooseButton, zoomButton].forEach { card.addSubview($0) }

        [card, imageView, chooseButton, zoomButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalToConstant: 210),

            zoomButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 10),
            zoomButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10),
            zoomButton.widthAnchor.constraint(equalToConstant: 36),
            zoomButton.heightAnchor.constraint(equalToConstant: 36),

            chooseButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            chooseButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            chooseButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    func configure(imageName: String) {
        imageView.image = UIImage(named: imageName)
    }

    @objc private func chooseTapped() { onChooseTapped?() }
    @objc private func zoomTapped() { onZoomTapped?() }
}
