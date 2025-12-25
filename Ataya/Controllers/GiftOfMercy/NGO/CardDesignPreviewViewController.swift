//
//  CardDesignPreviewViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//


//
//  CardDesignPreviewViewController.swift
//  Ataya
//
//  Created by ChatGPT on 25/12/2025.
//

import UIKit

final class CardDesignPreviewViewController: UIViewController {

    private let design: CardDesign

    // UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let statusLabel = UILabel()

    private let accentYellow = UIColor(atayaHex: "F7D44C")

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

        // Image view (الكرت)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.15
        imageView.layer.shadowRadius = 10
        imageView.layer.shadowOffset = CGSize(width: 0, height: 4)

        contentView.addSubview(imageView)

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
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
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
        imageView.image = UIImage(named: design.imageName)

        if design.isActive {
            statusLabel.text = design.isDefault ? "Active · Default" : "Active"
            statusLabel.textColor = UIColor.systemGreen
        } else {
            statusLabel.text = "Inactive"
            statusLabel.textColor = UIColor.systemGray
        }
    }
}
