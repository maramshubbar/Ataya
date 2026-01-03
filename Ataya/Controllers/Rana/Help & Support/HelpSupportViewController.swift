//
//  HelpSupportViewViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 29/12/2025.
//
import UIKit

final class HelpSupportViewController: UIViewController {

    // MARK: - UI

    private let headerContainer = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    private let contentStack = UIStackView()

    private let supportCard = InfoCardView(
        title: "Support Email",
        body: "For technical issues, bugs, or app-related questions.",
        email: "support@atayaapp.com"
    )

    private let adminCard = InfoCardView(
        title: "Admin Contact",
        body: "For account access, verification, or system management inquiries.",
        email: "abdullaYusuf@gmail.com"
    )

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true

        // ✅ REMOVE NAVIGATION CONTROLLER TITLE/BAR (fix double title)
        navigationItem.title = ""
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.backgroundColor = .white

        setupHeader()
        setupLayout()
    }

    // If you want the nav bar to come back when leaving this screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Header (Custom like Figma)

    private func setupHeader() {
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerContainer)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.contentHorizontalAlignment = .leading
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Help & Support"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center

        headerContainer.addSubview(backButton)
        headerContainer.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 44),

            backButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: headerContainer.trailingAnchor, constant: -16)
        ])
    }

    @objc private func backTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Content

    private func setupLayout() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.distribution = .fill

        view.addSubview(contentStack)
        contentStack.addArrangedSubview(supportCard)
        contentStack.addArrangedSubview(adminCard)

        NSLayoutConstraint.activate([
            // spacing below header
            contentStack.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 28),

            // ✅ left/right = 36
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),

            // keep safe bottom so stack doesn't vanish / layout warnings
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
}

// MARK: - Card View (Reusable)

private final class InfoCardView: UIView {

    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()

    private let emailRow = UIStackView()
    private let emailIcon = UIImageView()
    private let emailLabel = UILabel()

    init(title: String, body: String, email: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        configure(title: title, body: body, email: email)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.88, alpha: 1).cgColor

        // subtle shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])

        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 1

        bodyLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        bodyLabel.textColor = UIColor(white: 0.25, alpha: 1)
        bodyLabel.numberOfLines = 0

        emailRow.axis = .horizontal
        emailRow.spacing = 8
        emailRow.alignment = .center

        emailIcon.image = UIImage(systemName: "envelope.fill")
        emailIcon.tintColor = UIColor(red: 0.98, green: 0.77, blue: 0.00, alpha: 1) // yellow-ish
        emailIcon.contentMode = .scaleAspectFit
        emailIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailIcon.widthAnchor.constraint(equalToConstant: 16),
            emailIcon.heightAnchor.constraint(equalToConstant: 16)
        ])

        emailLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        emailLabel.textColor = UIColor(white: 0.30, alpha: 1)
        emailLabel.numberOfLines = 1

        emailRow.addArrangedSubview(emailIcon)
        emailRow.addArrangedSubview(emailLabel)

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(bodyLabel)
        stack.addArrangedSubview(emailRow)
    }

    private func configure(title: String, body: String, email: String) {
        titleLabel.text = title
        bodyLabel.text = body
        emailLabel.text = email
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
}
