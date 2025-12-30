//
//  MySupportTicketsDetailsViewController.swift
//  Ataya
//
//  Created by BP-36-224-14 on 30/12/2025.
//

import UIKit

final class MySupportTicketsDetailsViewController: UIViewController {

    private let ticket: SupportTicket
    private let sidePadding: CGFloat = 36

    private let headerContainer = UIView()
    private let backButton = UIButton(type: .system)
    private let headerTitleLabel = UILabel()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let container = UIView()
    private let idLabel = UILabel()
    private let statusLabel = UILabel()
    private let issueTitle = UILabel()
    private let issueBody = UILabel()
    private let replyTitle = UILabel()
    private let replyBody = UILabel()

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
        setupContainer()
        fill()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func setupHeader() {
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerContainer)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.text = "Ticket Details"
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
            headerTitleLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor)
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

    private func setupContainer() {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(white: 0.88, alpha: 1).cgColor
        contentView.addSubview(container)

        [idLabel, statusLabel, issueTitle, issueBody, replyTitle, replyBody].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.numberOfLines = 0
            container.addSubview($0)
        }

        idLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        statusLabel.font = .systemFont(ofSize: 12, weight: .regular)
        statusLabel.textColor = UIColor(white: 0.35, alpha: 1)

        issueTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        issueTitle.text = "Your Issue"
        issueBody.font = .systemFont(ofSize: 13, weight: .regular)
        issueBody.textColor = UIColor(white: 0.25, alpha: 1)

        replyTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        replyTitle.text = "Admin Reply"
        replyBody.font = .systemFont(ofSize: 13, weight: .regular)
        replyBody.textColor = UIColor(white: 0.25, alpha: 1)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sidePadding),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sidePadding),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            idLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            idLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            idLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),

            statusLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 6),
            statusLabel.leadingAnchor.constraint(equalTo: idLabel.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: idLabel.trailingAnchor),

            issueTitle.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            issueTitle.leadingAnchor.constraint(equalTo: idLabel.leadingAnchor),
            issueTitle.trailingAnchor.constraint(equalTo: idLabel.trailingAnchor),

            issueBody.topAnchor.constraint(equalTo: issueTitle.bottomAnchor, constant: 6),
            issueBody.leadingAnchor.constraint(equalTo: idLabel.leadingAnchor),
            issueBody.trailingAnchor.constraint(equalTo: idLabel.trailingAnchor),

            replyTitle.topAnchor.constraint(equalTo: issueBody.bottomAnchor, constant: 12),
            replyTitle.leadingAnchor.constraint(equalTo: idLabel.leadingAnchor),
            replyTitle.trailingAnchor.constraint(equalTo: idLabel.trailingAnchor),

            replyBody.topAnchor.constraint(equalTo: replyTitle.bottomAnchor, constant: 6),
            replyBody.leadingAnchor.constraint(equalTo: idLabel.leadingAnchor),
            replyBody.trailingAnchor.constraint(equalTo: idLabel.trailingAnchor),
            replyBody.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14)
        ])
    }

    private func fill() {
        idLabel.text = ticket.id
        statusLabel.text = "Status: \(ticket.status.rawValue)"
        issueBody.text = ticket.userIssue
        replyBody.text = ticket.adminReply ?? "No reply yet."
    }
}
