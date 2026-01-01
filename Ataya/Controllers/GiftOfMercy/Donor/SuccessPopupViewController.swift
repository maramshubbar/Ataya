//
//  SuccessPopupViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 01/01/2026.
//


import UIKit

final class SuccessPopupViewController: UIViewController {

    // MARK: - Public
    var onPrimaryTapped: (() -> Void)?

    // MARK: - Config
    private let titleText: String
    private let messageText: String
    private let buttonTitle: String

    // MARK: - Theme (uses your existing UIColor(atayaHex:))
    private let brandYellow = UIColor(atayaHex: "F7D44C")
    private let softGreen = UIColor(atayaHex: "00A85C", alpha: 0.18)

    // MARK: - UI
    private let dimView = UIView()
    private let cardView = UIView()

    private let closeButton = UIButton(type: .system)
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()

    private let titleLabel = UILabel()
    private let messageLabel = UILabel()

    private let primaryButton = UIButton(type: .system)

    // MARK: - Init
    init(titleText: String, messageText: String, buttonTitle: String) {
        self.titleText = titleText
        self.messageText = messageText
        self.buttonTitle = buttonTitle
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        buildConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateIn()
    }

    // MARK: - UI
    private func buildUI() {
        view.backgroundColor = .clear

        // Dim
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        view.addSubview(dimView)
        dimView.translatesAutoresizingMaskIntoConstraints = false

        let dimTap = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        dimView.addGestureRecognizer(dimTap)

        // Card
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 18
        cardView.clipsToBounds = true
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowRadius = 14
        cardView.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        // Close (X)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .secondaryLabel
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        cardView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        // Icon
        iconContainer.backgroundColor = softGreen
        iconContainer.layer.cornerRadius = 44
        iconContainer.clipsToBounds = true
        cardView.addSubview(iconContainer)
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        iconImageView.image = UIImage(systemName: "checkmark")
        iconImageView.tintColor = UIColor(atayaHex: "00A85C")
        iconImageView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        // Title
        titleLabel.text = titleText
        titleLabel.font = .systemFont(ofSize: 22, weight: .heavy)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        cardView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Message
        messageLabel.text = messageText
        messageLabel.font = .systemFont(ofSize: 15, weight: .regular)
        messageLabel.textAlignment = .center
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        cardView.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        // Button
        var cfg = UIButton.Configuration.filled()
        cfg.title = buttonTitle
        cfg.baseBackgroundColor = brandYellow
        cfg.baseForegroundColor = .black
        cfg.cornerStyle = .large
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)

        primaryButton.configuration = cfg
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        cardView.addSubview(primaryButton)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
    }

    private func buildConstraints() {
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            closeButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 34),
            closeButton.heightAnchor.constraint(equalToConstant: 34),

            iconContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 26),
            iconContainer.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 88),
            iconContainer.heightAnchor.constraint(equalToConstant: 88),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 34),
            iconImageView.heightAnchor.constraint(equalToConstant: 34),

            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 22),
            messageLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -22),

            primaryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 18),
            primaryButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            primaryButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            primaryButton.heightAnchor.constraint(equalToConstant: 52),
            primaryButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18),
        ])
    }

    // MARK: - Animations
    private func animateIn() {
        cardView.alpha = 0
        cardView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)

        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut]) {
            self.cardView.alpha = 1
            self.cardView.transform = .identity
        }
    }

    // MARK: - Actions
    @objc private func primaryTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onPrimaryTapped?()
        }
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
