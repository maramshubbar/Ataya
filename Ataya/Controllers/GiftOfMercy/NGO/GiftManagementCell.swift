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

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // الكرت
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

        // الصورة
        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.clipsToBounds = true
        thumbImageView.layer.cornerRadius = 10

        NSLayoutConstraint.activate([
            thumbImageView.widthAnchor.constraint(equalToConstant: 80),
            thumbImageView.heightAnchor.constraint(equalToConstant: 80)
        ])

        // النصوص
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 2

        priceLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        priceLabel.textColor = accentYellow
        priceLabel.numberOfLines = 1

        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2

        let textStack = UIStackView(arrangedSubviews: [titleLabel, priceLabel, descriptionLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        // الصف العلوي: صورة + نص
        let topRow = UIStackView(arrangedSubviews: [thumbImageView, textStack])
        topRow.axis = .horizontal
        topRow.alignment = .top
        topRow.spacing = 12
        topRow.translatesAutoresizingMaskIntoConstraints = false

        // زر Edit فقط (نفس ستايل View الأصفر)
        buttonsStack.axis = .horizontal
        buttonsStack.alignment = .center
        buttonsStack.spacing = 0
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        styleFilledButton(editButton, title: "Edit")
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)

        // نخلي الزر على اليسار وفضاء على اليمين
        let spacer = UIView()
        buttonsStack.addArrangedSubview(editButton)
        buttonsStack.addArrangedSubview(spacer)

        // الـ Stack الأساسي داخل الكرت
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

            editButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func styleFilledButton(_ button: UIButton, title: String) {
        var config = button.configuration ?? .filled()

        config.title = title
        config.baseBackgroundColor = accentYellow
        config.baseForegroundColor = .black
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 15, weight: .semibold)
            return outgoing
        }

        config.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )

        button.configuration = config

        // لو تبين نفس الستايل حق الزوايا
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
    }


    // MARK: - ViewModel

    struct ViewModel {
        let title: String
        let priceLine: String
        let description: String
        let imageName: String
    }

    func configure(with model: ViewModel) {
        titleLabel.text = model.title
        priceLabel.text = model.priceLine
        descriptionLabel.text = model.description
        thumbImageView.image = UIImage(named: model.imageName)
    }

    // MARK: - Actions

    @objc private func editTapped() {
        onEdit?()
    }
}
