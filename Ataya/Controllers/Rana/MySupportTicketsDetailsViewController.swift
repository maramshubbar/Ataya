//
//  MySupportTicketsDetailsViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 29/12/2025.
//

import UIKit

final class SupportTicketDetailsViewController: UIViewController {

    private let ticket: SupportTicket

    // MARK: - Layout
    private let sidePadding: CGFloat = 36

    // Header
    private let headerContainer = UIView()
    private let backButton = UIButton(type: .system)
    private let headerTitleLabel = UILabel()

    // Scroll
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let cardView = UIView()

    private let idLabel = UILabel()
    private let statusLabel = UILabel()

    private let replyTitle = UILabel()
    private let replyBody = UILabel()

    private let divider = UIView()

    private let issueTitle = UILabel()
    private let issueBody = UILabel()

    init(ticket: SupportTicket) {
        self.ticket = ticket
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupHeader()
        setupScroll()
        setupCard()
        fill()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupHeader() {
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerContainer)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.text = "My Support Tickets"
        headerTitleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        headerTitleLabel.textAlignment = .center
        headerTitleLabel.textColor = .black

        headerContainer.addSubview(backButton)
        headerContainer.addSubview(headerTitleLabel)

        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 44),

            backButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            headerTitleLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            headerTitleLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            headerTitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8),
            headerTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: headerContainer.trailingAnchor, constant: -16)
        ])
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupCard() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(white: 0.87, alpha: 1).cgColor
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)

        contentView.addSubview(cardView)

        idLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        idLabel.textColor = .black

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 13, weight: .regular)
        statusLabel.textColor = UIColor(white: 0.25, alpha: 1)

        replyTitle.translatesAutoresizingMaskIntoConstraints = false
        replyTitle.text = "Admin Reply:"
        replyTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        replyTitle.textColor = .black

        replyBody.translatesAutoresizingMaskIntoConstraints = false
        replyBody.font = .systemFont(ofSize: 14, weight: .regular)
        replyBody.textColor = UIColor(white: 0.22, alpha: 1)
        replyBody.numberOfLines = 0

        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor(white: 0.90, alpha: 1)

        issueTitle.translatesAutoresizingMaskIntoConstraints = false
        issueTitle.text = "Your Issue:"
        issueTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        issueTitle.textColor = .black

        issueBody.translatesAutoresizingMaskIntoConstraints = false
        issueBody.font = .systemFont(ofSize: 14, weight: .regular)
        issueBody.textColor = UIColor(white: 0.22, alpha: 1)
        issueBody.numberOfLines = 0

        cardView.addSubview(idLabel)
        cardView.addSubview(statusLabel)
        cardView.addSubview(replyTitle)
        cardView.addSubview(replyBody)
        cardView.addSubview(divider)
        cardView.addSubview(issueTitle)
        cardView.addSubview(issueBody)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sidePadding),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sidePadding),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            idLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            idLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            idLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -14),

            statusLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 6),
            statusLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -14),

            replyTitle.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            replyTitle.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            replyTitle.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            replyBody.topAnchor.constraint(equalTo: replyTitle.bottomAnchor, constant: 6),
            replyBody.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            replyBody.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            divider.topAnchor.constraint(equalTo: replyBody.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            divider.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            divider.heightAnchor.constraint(equalToConstant: 1),

            issueTitle.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 14),
            issueTitle.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            issueTitle.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            issueBody.topAnchor.constraint(equalTo: issueTitle.bottomAnchor, constant: 6),
            issueBody.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            issueBody.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            issueBody.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }

    private func fill() {
        idLabel.text = ticket.id
        statusLabel.text = "Status: \(ticket.status.rawValue)"
        replyBody.text = ticket.adminReply ?? "No reply yet."
        issueBody.text = ticket.userIssue
    }
}
