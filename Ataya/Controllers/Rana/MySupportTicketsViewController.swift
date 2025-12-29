//
//  MySupportTicketsViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 29/12/2025.
//

import UIKit

final class MySupportTicketsViewController: UIViewController {

    // MARK: - Layout
    private let sidePadding: CGFloat = 36
    private let yellow = UIColor(named: "#F7D44C")

    // MARK: - Header
    private let headerContainer = UIView()
    private let backButton = UIButton(type: .system)
    private let headerTitleLabel = UILabel()

    // MARK: - List
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()

    // MARK: - Empty State
    private let emptyContainer = UIView()
    private let emptyIcon = UIImageView()
    private let emptyLabel = UILabel()

    // MARK: - Data (replace later with Firebase)
    // NOTE: "adminReply" nil or empty => no reply yet.
    private var tickets: [SupportTicket] = [
        SupportTicket(
            id: "#12345",
            status: .resolved,
            userIssue: "I scheduled a pickup for October 14, but the collector didn’t arrive at the selected time. Can you please check if it was confirmed correctly?",
            adminReply: "Hello Zahra, thank you for contacting us.\n\nWe’ve checked your report about the pickup delay and found that it was caused by a small system update issue.\n\nYour donation #1001 has now been successfully marked as Collected and is visible in your donation history.\n\nEverything is working fine now.\n\nWe truly appreciate your patience and continued support!",
            updatedAt: Date()
        ),
        SupportTicket(
            id: "#12346",
            status: .pending,
            userIssue: "Notifications are not appearing for donation updates. I tried reinstalling and logging out/in but still nothing.",
            adminReply: nil, // no reply yet
            updatedAt: Date()
        )
    ]

    // If you want to test empty state, set tickets = [] or all adminReply nil.
    // private var tickets: [SupportTicket] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupHeader()
        setupScroll()
        setupStack()
        setupEmptyState()

        refreshUI()
    }

    // Keep system nav hidden (NO double back)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Header
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
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Scroll + Stack
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

    private func setupStack() {
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 18

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sidePadding),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sidePadding),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    // MARK: - Empty State
    private func setupEmptyState() {
        emptyContainer.translatesAutoresizingMaskIntoConstraints = false
        emptyContainer.isHidden = true
        contentView.addSubview(emptyContainer)

        emptyIcon.translatesAutoresizingMaskIntoConstraints = false
        emptyIcon.image = UIImage(systemName: "bubble.left.and.bubble.right.fill")
        emptyIcon.tintColor = yellow
        emptyIcon.contentMode = .scaleAspectFit

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No replies yet.\nOnce the admin responds, your tickets will appear here."
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        emptyLabel.textColor = UIColor(white: 0.35, alpha: 1)

        emptyContainer.addSubview(emptyIcon)
        emptyContainer.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emptyContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -40),
            emptyContainer.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: sidePadding),
            emptyContainer.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -sidePadding),

            emptyIcon.topAnchor.constraint(equalTo: emptyContainer.topAnchor),
            emptyIcon.centerXAnchor.constraint(equalTo: emptyContainer.centerXAnchor),
            emptyIcon.widthAnchor.constraint(equalToConstant: 34),
            emptyIcon.heightAnchor.constraint(equalToConstant: 34),

            emptyLabel.topAnchor.constraint(equalTo: emptyIcon.bottomAnchor, constant: 12),
            emptyLabel.leadingAnchor.constraint(equalTo: emptyContainer.leadingAnchor),
            emptyLabel.trailingAnchor.constraint(equalTo: emptyContainer.trailingAnchor),
            emptyLabel.bottomAnchor.constraint(equalTo: emptyContainer.bottomAnchor)
        ])
    }

    // MARK: - UI Refresh
    private func refreshUI() {
        // Show only tickets that have admin reply (as you requested)
        let replied = tickets.filter { ($0.adminReply?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) }

        // Clear old cards
        stack.arrangedSubviews.forEach { v in
            stack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        if replied.isEmpty {
            emptyContainer.isHidden = false
        } else {
            emptyContainer.isHidden = true
            replied.forEach { ticket in
                let card = SupportTicketCardView(ticket: ticket)
                card.onViewDetails = { [weak self] in
                    guard let self else { return }
                    let vc = SupportTicketDetailsViewController(ticket: ticket)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                stack.addArrangedSubview(card)
            }
        }
    }
}
