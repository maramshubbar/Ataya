//
//  GiftOrderDetailsViewController.swift
//  Ataya
//

import UIKit

final class GiftOrderDetailsViewController: UIViewController {

    // ✅ callback (optional)
    var onStatusUpdated: ((String, GiftOrderStatus) -> Void)?

    private var order: GiftOrder

    // UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let orderIdLabel = UILabel()
    private let dateLabel = UILabel()
    private let amountLabel = UILabel()
    private let statusBadge = UILabel()

    private let giftNameLabel = UILabel()
    private let designLabel = UILabel()
    private let donorLabel = UILabel()
    private let recipientsLabel = UILabel()

    private let messageLabel = UILabel()
    private let notesLabel = UILabel()

    private let markSentButton = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .medium)

    private let brandYellow = UIColor(atayaHex: "F7D44C")

    private lazy var amountFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        return f
    }()

    init(order: GiftOrder) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Use init(order:) instead.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        bind()
    }

    private func setupNav() {
        view.backgroundColor = .systemBackground
        title = "Order Details"
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])

        let (summaryCard, summaryStack) = makeSectionCard(title: "Order Summary")

        orderIdLabel.font = .systemFont(ofSize: 14)
        orderIdLabel.textColor = .secondaryLabel

        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .secondaryLabel

        amountLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        statusBadge.font = .systemFont(ofSize: 13, weight: .semibold)
        statusBadge.textAlignment = .center
        statusBadge.textColor = .black
        statusBadge.layer.cornerRadius = 31 / 2
        statusBadge.clipsToBounds = true
        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        statusBadge.heightAnchor.constraint(equalToConstant: 31).isActive = true
        statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 108).isActive = true

        let topRow = UIStackView(arrangedSubviews: [orderIdLabel, statusBadge])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 8

        let bottomRow = UIStackView(arrangedSubviews: [dateLabel, amountLabel])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.distribution = .equalSpacing

        summaryStack.addArrangedSubview(topRow)
        summaryStack.addArrangedSubview(bottomRow)
        contentStack.addArrangedSubview(summaryCard)

        let (infoCard, infoStack) = makeSectionCard(title: "Info")
        giftNameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        donorLabel.font = .systemFont(ofSize: 14)
        designLabel.font = .systemFont(ofSize: 14)
        recipientsLabel.font = .systemFont(ofSize: 14)
        recipientsLabel.textColor = .secondaryLabel

        infoStack.addArrangedSubview(giftNameLabel)
        infoStack.addArrangedSubview(donorLabel)
        infoStack.addArrangedSubview(designLabel)
        infoStack.addArrangedSubview(recipientsLabel)
        contentStack.addArrangedSubview(infoCard)

        let (msgCard, msgStack) = makeSectionCard(title: "Message")
        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        msgStack.addArrangedSubview(messageLabel)
        contentStack.addArrangedSubview(msgCard)

        let (notesCard, notesStack) = makeSectionCard(title: "Notes for NGO")
        notesLabel.font = .systemFont(ofSize: 14)
        notesLabel.textColor = .secondaryLabel
        notesLabel.numberOfLines = 0
        notesStack.addArrangedSubview(notesLabel)
        contentStack.addArrangedSubview(notesCard)

        // Action button
        markSentButton.setTitle("Mark as Sent", for: .normal)
        markSentButton.backgroundColor = brandYellow
        markSentButton.setTitleColor(.black, for: .normal)
        markSentButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        markSentButton.layer.cornerRadius = 12
        markSentButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        markSentButton.addTarget(self, action: #selector(markSentTapped), for: .touchUpInside)

        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        markSentButton.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerYAnchor.constraint(equalTo: markSentButton.centerYAnchor),
            spinner.trailingAnchor.constraint(equalTo: markSentButton.trailingAnchor, constant: -16)
        ])

        contentStack.addArrangedSubview(markSentButton)
    }

    private func makeSectionCard(title: String) -> (UIView, UIStackView) {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 16

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)

        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.spacing = 8
        innerStack.translatesAutoresizingMaskIntoConstraints = false

        let container = UIStackView(arrangedSubviews: [titleLabel, innerStack])
        container.axis = .vertical
        container.spacing = 8
        container.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            container.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            container.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            container.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])

        return (card, innerStack)
    }

    private func bind() {
        orderIdLabel.text = "Order ID: \(order.id)"
        dateLabel.text = "Date: " + order.createdAt.formatted(date: .abbreviated, time: .shortened)

        if let amt = order.amount {
            amountFormatter.currencyCode = order.currency
            amountLabel.text = amountFormatter.string(from: NSNumber(value: amt)) ?? "\(order.currency) \(amt)"
        } else {
            amountLabel.text = "—"
        }

        applyStatus(order.status)

        giftNameLabel.text = order.giftName
        donorLabel.text = "Donor: \(order.donorName)"
        designLabel.text = "Card Design: \(order.cardDesignName)"
        recipientsLabel.text = "Recipients: \(order.recipientsCount)"

        messageLabel.text = (order.message?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
        ? order.message
        : "No message."

        notesLabel.text = (order.notesForNGO?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
        ? order.notesForNGO
        : "—"

        // only show button when pending/processing (your choice)
        markSentButton.isHidden = !(order.status == .pending || order.status == .processing)
    }

    private func applyStatus(_ status: GiftOrderStatus) {
        statusBadge.text = status.title

        switch status {
        case .pending:
            statusBadge.backgroundColor = brandYellow.withAlphaComponent(0.35)
        case .processing:
            statusBadge.backgroundColor = UIColor(red: 0.82, green: 0.90, blue: 1.0, alpha: 1)
        case .sent:
            statusBadge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.25)
        case .failed:
            statusBadge.backgroundColor = UIColor.systemRed.withAlphaComponent(0.20)
        case .cancelled:
            statusBadge.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.60)
        }
    }

    private func setSaving(_ saving: Bool) {
        markSentButton.isEnabled = !saving
        saving ? spinner.startAnimating() : spinner.stopAnimating()
        markSentButton.alpha = saving ? 0.85 : 1.0
    }

    @objc private func markSentTapped() {
        let alert = UIAlertController(
            title: "Mark as Sent?",
            message: "This will change the order status to Sent.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Mark as Sent", style: .default) { [weak self] _ in
            guard let self else { return }
            self.setSaving(true)

            GiftOrderService.shared.updateStatus(orderId: self.order.id, status: .sent) { err in
                DispatchQueue.main.async {
                    self.setSaving(false)
                    if let err {
                        print("❌ update status error:", err.localizedDescription)
                        return
                    }
                    self.order = GiftOrder(
                        id: self.order.id,
                        ngoId: self.order.ngoId,
                        giftName: self.order.giftName,
                        donorName: self.order.donorName,
                        amount: self.order.amount,
                        currency: self.order.currency,
                        createdAt: self.order.createdAt,
                        status: .sent,
                        cardDesignName: self.order.cardDesignName,
                        recipientsCount: self.order.recipientsCount,
                        message: self.order.message,
                        notesForNGO: self.order.notesForNGO
                    )
                    self.onStatusUpdated?(self.order.id, .sent)
                    self.bind()
                }
            }
        })
        present(alert, animated: true)
    }
}
