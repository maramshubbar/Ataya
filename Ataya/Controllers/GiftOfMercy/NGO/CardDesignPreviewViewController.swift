//
//  CardDesignPreviewViewController.swift
//  Ataya
//

import UIKit

final class CardDesignPreviewViewController: UIViewController {

    private let design: CardDesign

    // UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let cardView = UIView()
    private let imageView = UIImageView()

    private let nameLabel = UILabel()
    private let statusLabel = UILabel()

    // MARK: - Init

    init(design: CardDesign) {
        self.design = design
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        bind()
    }

    private func setupNav() {
        title = "Preview"
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Card container (shadow works here ✅)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray4.cgColor
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.masksToBounds = false
        contentView.addSubview(cardView)

        // Image inside card
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        cardView.addSubview(imageView)

        // Name label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textAlignment = .center
        contentView.addSubview(nameLabel)

        // Status label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statusLabel.textAlignment = .center
        contentView.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            cardView.heightAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 1.0),

            imageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

            nameLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            statusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            statusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    private func bind() {
        nameLabel.text = design.name

        let placeholder = UIImage(named: design.imageName)

        // ✅ Cloudinary if available, otherwise asset
        if let url = design.imageURL, !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ImageLoader.shared.setImage(on: imageView, from: url, placeholder: placeholder)
        } else {
            imageView.image = placeholder
        }

        if design.isActive {
            statusLabel.text = design.isDefault ? "Active · Default" : "Active"
            statusLabel.textColor = .systemGreen
        } else {
            statusLabel.text = "Inactive"
            statusLabel.textColor = .systemGray
        }
    }
}
