//
//  MySupportTicketsViewController.swift
//  Ataya
//
//  Created by BP-36-224-14 on 30/12/2025.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

final class MySupportTicketsViewController: UIViewController {

    private let sidePadding: CGFloat = 36
    private let yellow = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1) // #F7D44C


    private let headerContainer = UIView()
    private let backButton = UIButton(type: .system)
    private let headerTitleLabel = UILabel()

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()

    private let emptyContainer = UIView()
    private let emptyIcon = UIImageView()
    private let emptyLabel = UILabel()

    private var tickets: [SupportTicket] = []
    private var listener: ListenerRegistration?

    private let includeOnlyReplied = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupHeader()
        setupScroll()
        setupStack()
        setupEmptyState()
        refreshUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        startListening()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        listener?.remove()
        listener = nil
    }

    private func startListening() {
        listener?.remove()
        listener = nil

        // ✅ No login blocking here.
        // Service will use Firebase Auth user if exists, otherwise DEMO_USER.
        listener = SupportTicketService.shared.listenMyTickets(includeOnlyReplied: includeOnlyReplied) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.tickets = items
                    self.refreshUI()

                case .failure(let error):
                    self.tickets = []
                    self.refreshUI()
                    self.showInfoAlert(title: "Load Failed", message: error.localizedDescription)
                }
            }
        }
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

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            // ✅ FIX: make contentView at least screen height so empty state centers correctly
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor)
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

    private func setupEmptyState() {
        emptyContainer.translatesAutoresizingMaskIntoConstraints = false
        emptyContainer.isHidden = true
        contentView.addSubview(emptyContainer)

        emptyIcon.translatesAutoresizingMaskIntoConstraints = false
        emptyIcon.image = UIImage(systemName: "bubble.left.and.bubble.right.fill")
        emptyIcon.tintColor = yellow
        emptyIcon.contentMode = .scaleAspectFit

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No tickets yet.\nSubmit a ticket and it will appear here."
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        emptyLabel.textColor = UIColor(white: 0.35, alpha: 1)

        emptyContainer.addSubview(emptyIcon)
        emptyContainer.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emptyContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor), // ✅ now true center
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

    private func refreshUI() {
        stack.arrangedSubviews.forEach { v in
            stack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        if tickets.isEmpty {
            emptyContainer.isHidden = false
            return
        }

        emptyContainer.isHidden = true

        tickets.forEach { ticket in
            let card = TicketCard(ticket: ticket, yellow: yellow)
            card.onViewDetails = { [weak self] in
                guard let self else { return }
                let vc = MySupportTicketsDetailsViewController(ticket: ticket)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            stack.addArrangedSubview(card)
        }
    }

    private func showInfoAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

private final class TicketCard: UIView {

    var onViewDetails: (() -> Void)?
    private let yellow: UIColor
    private let ticket: SupportTicket

    private let titleLabel = UILabel()
    private let idLabel = UILabel()
    private let statusPill = UILabel()

    private let metaLabel = UILabel()

    private let issueTitle = UILabel()
    private let issueBody = UILabel()

    private let replyBox = UIView()
    private let replyTitle = UILabel()
    private let replyBody = UILabel()

    private let viewButton = UIButton(type: .system)

    init(ticket: SupportTicket, yellow: UIColor) {
        self.ticket = ticket
        self.yellow = yellow
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        fill()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.88, alpha: 1).cgColor

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 2)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 1

        idLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        idLabel.textColor = UIColor(white: 0.35, alpha: 1)

        statusPill.translatesAutoresizingMaskIntoConstraints = false
        statusPill.font = .systemFont(ofSize: 12, weight: .semibold)
        statusPill.textAlignment = .center
        statusPill.layer.cornerRadius = 10
        statusPill.clipsToBounds = true

        metaLabel.translatesAutoresizingMaskIntoConstraints = false
        metaLabel.font = .systemFont(ofSize: 12, weight: .regular)
        metaLabel.textColor = UIColor(white: 0.40, alpha: 1)
        metaLabel.numberOfLines = 1

        issueTitle.translatesAutoresizingMaskIntoConstraints = false
        issueTitle.text = "Your Issue"
        issueTitle.font = .systemFont(ofSize: 12, weight: .semibold)
        issueTitle.textColor = UIColor(white: 0.2, alpha: 1)

        issueBody.translatesAutoresizingMaskIntoConstraints = false
        issueBody.font = .systemFont(ofSize: 13, weight: .regular)
        issueBody.textColor = UIColor(white: 0.22, alpha: 1)
        issueBody.numberOfLines = 2

        replyBox.translatesAutoresizingMaskIntoConstraints = false
        replyBox.backgroundColor = UIColor(white: 0.97, alpha: 1)
        replyBox.layer.cornerRadius = 10
        replyBox.layer.borderWidth = 1
        replyBox.layer.borderColor = UIColor(white: 0.90, alpha: 1).cgColor

        replyTitle.translatesAutoresizingMaskIntoConstraints = false
        replyTitle.text = "Admin Reply"
        replyTitle.font = .systemFont(ofSize: 12, weight: .semibold)
        replyTitle.textColor = UIColor(white: 0.2, alpha: 1)

        replyBody.translatesAutoresizingMaskIntoConstraints = false
        replyBody.font = .systemFont(ofSize: 13, weight: .regular)
        replyBody.textColor = UIColor(white: 0.25, alpha: 1)
        replyBody.numberOfLines = 3

        replyBox.addSubview(replyTitle)
        replyBox.addSubview(replyBody)

        viewButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 15.0, *) { viewButton.configuration = nil }
        viewButton.setTitle("View Details", for: .normal)
        viewButton.setTitleColor(.black, for: .normal)
        viewButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        viewButton.backgroundColor = yellow
        viewButton.layer.cornerRadius = 8
        viewButton.clipsToBounds = true
        viewButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        viewButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)

        addSubview(titleLabel)
        addSubview(statusPill)
        addSubview(idLabel)
        addSubview(metaLabel)
        addSubview(issueTitle)
        addSubview(issueBody)
        addSubview(replyBox)
        addSubview(viewButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusPill.leadingAnchor, constant: -10),

            statusPill.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusPill.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            idLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            idLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            idLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            metaLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 6),
            metaLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            metaLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            issueTitle.topAnchor.constraint(equalTo: metaLabel.bottomAnchor, constant: 12),
            issueTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            issueTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            issueBody.topAnchor.constraint(equalTo: issueTitle.bottomAnchor, constant: 6),
            issueBody.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            issueBody.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            replyBox.topAnchor.constraint(equalTo: issueBody.bottomAnchor, constant: 12),
            replyBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            replyBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            replyTitle.topAnchor.constraint(equalTo: replyBox.topAnchor, constant: 10),
            replyTitle.leadingAnchor.constraint(equalTo: replyBox.leadingAnchor, constant: 12),
            replyTitle.trailingAnchor.constraint(equalTo: replyBox.trailingAnchor, constant: -12),

            replyBody.topAnchor.constraint(equalTo: replyTitle.bottomAnchor, constant: 6),
            replyBody.leadingAnchor.constraint(equalTo: replyBox.leadingAnchor, constant: 12),
            replyBody.trailingAnchor.constraint(equalTo: replyBox.trailingAnchor, constant: -12),
            replyBody.bottomAnchor.constraint(equalTo: replyBox.bottomAnchor, constant: -10),

            viewButton.topAnchor.constraint(equalTo: replyBox.bottomAnchor, constant: 12),
            viewButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            viewButton.heightAnchor.constraint(equalToConstant: 30),
            viewButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }

    private func fill() {
        titleLabel.text = ticket.titleSafe
        idLabel.text = ticket.displayId

        let resolved = (ticket.status == .resolved)

        statusPill.text = " \(ticket.status.rawValue) "
        statusPill.textColor = UIColor(white: 0.15, alpha: 1)

        // بديل hex → RGB (عشان يختفي Ambiguous init)
        let resolvedBG = UIColor(
            red: 234/255,
            green: 248/255,
            blue: 239/255,
            alpha: 1
        ) // #EAF8EF

        let pendingBG = UIColor(
            red: 255/255,
            green: 246/255,
            blue: 221/255,
            alpha: 1
        ) // #FFF6DD

        statusPill.backgroundColor = resolved ? resolvedBG : pendingBG

        metaLabel.text = "Category: \(ticket.category)"
        issueBody.text = ticket.userIssue
        replyBody.text = ticket.adminReply ?? "No reply yet."
    }

    @objc private func viewTapped() {
        onViewDetails?()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
}
