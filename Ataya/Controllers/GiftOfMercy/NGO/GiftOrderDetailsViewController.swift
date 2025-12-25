//import UIKit
//
//
//final class GiftOrderDetailsViewController: UIViewController {
//
//    // MARK: - Models
//
//    struct Recipient {
//        let name: String
//        let email: String
//    }
//
//    enum Status {
//        case pending
//        case sent
//
//        var title: String {
//            switch self {
//            case .pending: return "Pending"
//            case .sent:    return "Sent"
//            }
//        }
//    }
//
//    // MARK: - Public
//
//
//    var onStatusChanged: ((GiftOrdersListViewController.GiftOrder) -> Void)?
//
//    // MARK: - UI
// 
//    private let scrollView = UIScrollView()
//    private let contentStack = UIStackView()
//
//    // Section 1: Order Summary
//    private let orderIdLabel = UILabel()
//    private let dateLabel = UILabel()
//    private let amountLabel = UILabel()
//    private let statusBadge = UILabel()
//
//    // Section 2: Gift Info
//    private let giftNameLabel = UILabel()
//    private let giftDescriptionLabel = UILabel()
//
//    // Section 3: Card Design
//    private let cardImageView = UIImageView()
//
//    // Section 4: From + Message
//    private let senderNameLabel = UILabel()
//    private let personalMessageLabel = UILabel()
//
//    // Section 5: Recipients
//    private let recipientsLabel = UILabel()
//
//    // Section 6: Notes
//    private let notesLabel = UILabel()
//
//    // Action
//    private let markSentButton = UIButton(type: .system)
//
//    // MARK: - Helpers
//
//    private let brandYellow = UIColor(atayaHex: "F7D44C")
//    private let statusGreen = UIColor.systemGreen
//
//    private lazy var dateFormatter: DateFormatter = {
//        let f = DateFormatter()
//        f.dateStyle = .medium
//        f.timeStyle = .short
//        return f
//    }()
//
//    private lazy var amountFormatter: NumberFormatter = {
//        let f = NumberFormatter()
//        f.numberStyle = .currency
//        // تقدرون تغيرون الـ locale حسب عملتكم
//        f.locale = Locale.current
//        return f
//    }()
//
//    // MARK: - Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupNav()
//        setupUI()
//        bindData()
//    }
//
//    // MARK: - Setup
//
//    private func setupNav() {
//        view.backgroundColor = .systemBackground
//        title = "Order Details"
//        navigationItem.largeTitleDisplayMode = .never
//    }
//
//    private func setupUI() {
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(scrollView)
//
//        contentStack.axis = .vertical
//        contentStack.spacing = 16
//        contentStack.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.addSubview(contentStack)
//
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//
//            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
//            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
//            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
//            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
//        ])
//
//        // ===== 1) Order Summary =====
//        let (summaryCard, summaryStack) = makeSectionCard(title: "Order Summary")
//
//        orderIdLabel.font = .systemFont(ofSize: 14)
//        orderIdLabel.textColor = .secondaryLabel
//
//        dateLabel.font = .systemFont(ofSize: 14)
//        dateLabel.textColor = .secondaryLabel
//
//        amountLabel.font = .systemFont(ofSize: 16, weight: .semibold)
//        amountLabel.textColor = .label
//
//        statusBadge.font = .systemFont(ofSize: 13, weight: .semibold)
//        statusBadge.textAlignment = .center
//        statusBadge.textColor = .black
//        statusBadge.layer.cornerRadius = 31 / 2
//        statusBadge.clipsToBounds = true
//        statusBadge.translatesAutoresizingMaskIntoConstraints = false
//        statusBadge.heightAnchor.constraint(equalToConstant: 31).isActive = true
//        statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 108).isActive = true
//
//        let topRow = UIStackView(arrangedSubviews: [orderIdLabel, statusBadge])
//        topRow.axis = .horizontal
//        topRow.alignment = .center
//        topRow.distribution = .fill
//        topRow.spacing = 8
//
//        let bottomRow = UIStackView(arrangedSubviews: [dateLabel, amountLabel])
//        bottomRow.axis = .horizontal
//        bottomRow.alignment = .center
//        bottomRow.distribution = .equalSpacing
//
//        summaryStack.addArrangedSubview(topRow)
//        summaryStack.addArrangedSubview(bottomRow)
//
//        contentStack.addArrangedSubview(summaryCard)
//
//        // ===== 2) Gift Info =====
//        let (giftCard, giftStack) = makeSectionCard(title: "Gift Info")
//
//        giftNameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
//        giftDescriptionLabel.font = .systemFont(ofSize: 14)
//        giftDescriptionLabel.textColor = .secondaryLabel
//        giftDescriptionLabel.numberOfLines = 0
//
//        giftStack.addArrangedSubview(giftNameLabel)
//        giftStack.addArrangedSubview(giftDescriptionLabel)
//
//        contentStack.addArrangedSubview(giftCard)
//
//        // ===== 3) Card Design =====
//        let (cardCard, cardStack) = makeSectionCard(title: "Card Design")
//
//        cardImageView.translatesAutoresizingMaskIntoConstraints = false
//        cardImageView.contentMode = .scaleAspectFit
//        cardImageView.clipsToBounds = true
//        cardImageView.layer.cornerRadius = 12
//        cardImageView.backgroundColor = UIColor.systemGray6
//        cardImageView.heightAnchor.constraint(equalToConstant: 180).isActive = true
//        cardStack.addArrangedSubview(cardImageView)
//
//        contentStack.addArrangedSubview(cardCard)
//
//        // ===== 4) From + Message =====
//        let (fromCard, fromStack) = makeSectionCard(title: "From")
//
//        senderNameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
//        personalMessageLabel.font = .systemFont(ofSize: 14)
//        personalMessageLabel.textColor = .secondaryLabel
//        personalMessageLabel.numberOfLines = 0
//
//        fromStack.addArrangedSubview(senderNameLabel)
//        fromStack.addArrangedSubview(personalMessageLabel)
//
//        contentStack.addArrangedSubview(fromCard)
//
//        // ===== 5) Recipients =====
//        let (recCard, recStack) = makeSectionCard(title: "Recipients")
//
//        recipientsLabel.font = .systemFont(ofSize: 14)
//        recipientsLabel.textColor = .secondaryLabel
//        recipientsLabel.numberOfLines = 0
//
//        recStack.addArrangedSubview(recipientsLabel)
//        contentStack.addArrangedSubview(recCard)
//
//        // ===== 6) Notes (optional) =====
//        let (notesCard, notesStack) = makeSectionCard(title: "Notes for NGO")
//        notesLabel.font = .systemFont(ofSize: 14)
//        notesLabel.textColor = .secondaryLabel
//        notesLabel.numberOfLines = 0
//        notesStack.addArrangedSubview(notesLabel)
//        contentStack.addArrangedSubview(notesCard)
//
//        // ===== Action Button =====
//        markSentButton.setTitle("Mark as Sent", for: .normal)
//        markSentButton.backgroundColor = brandYellow
//        markSentButton.setTitleColor(.black, for: .normal)
//        markSentButton.layer.cornerRadius = 12
//        markSentButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        markSentButton.addTarget(self, action: #selector(markSentTapped), for: .touchUpInside)
//
//        contentStack.addArrangedSubview(markSentButton)
//    }
//
//    /// helper: يرجع كرت فيه title و stack داخلي
//    private func makeSectionCard(title: String) -> (UIView, UIStackView) {
//        let card = UIView()
//        card.translatesAutoresizingMaskIntoConstraints = false
//        card.backgroundColor = .secondarySystemGroupedBackground
//        card.layer.cornerRadius = 16
//
//        let titleLabel = UILabel()
//        titleLabel.text = title
//        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
//
//        let innerStack = UIStackView()
//        innerStack.axis = .vertical
//        innerStack.spacing = 8
//        innerStack.translatesAutoresizingMaskIntoConstraints = false
//
//        let container = UIStackView(arrangedSubviews: [titleLabel, innerStack])
//        container.axis = .vertical
//        container.spacing = 8
//        container.translatesAutoresizingMaskIntoConstraints = false
//
//        card.addSubview(container)
//
//        NSLayoutConstraint.activate([
//            container.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
//            container.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
//            container.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
//            container.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
//        ])
//
//        return (card, innerStack)
//    }
//
//    // MARK: - Bind
//
//    private func bindData() {
//        guard let order = order, isViewLoaded else { return }
//
//        // Summary
//        orderIdLabel.text = "Order ID: \(order.id)"
//        dateLabel.text = "Date: " + dateFormatter.string(from: order.date)
//
//        if let amt = order.amount,
//           let ns = amountFormatter.string(from: amt as NSDecimalNumber) {
//            amountLabel.text = ns
//        } else {
//            amountLabel.text = "—"
//        }
//
//        applyStatus(order.status)
//
//        // Gift
//        giftNameLabel.text = order.giftName
//        giftDescriptionLabel.text = order.giftDescription.isEmpty ? "—" : order.giftDescription
//
//        // Card design
//        if let imageName = order.cardDesignImageName,
//           let img = UIImage(named: imageName) {
//            cardImageView.image = img
//        } else {
//            cardImageView.image = nil
//        }
//
//        // From + message
//        senderNameLabel.text = "From: \(order.senderName)"
//        if let msg = order.personalMessage, !msg.isEmpty {
//            personalMessageLabel.text = msg
//        } else {
//            personalMessageLabel.text = "No personal message."
//        }
//
//        // Recipients
//        if order.recipients.isEmpty {
//            recipientsLabel.text = "No recipients."
//        } else {
//            let lines = order.recipients.map { "\($0.name) – \($0.email)" }
//            recipientsLabel.text = lines.joined(separator: "\n")
//        }
//
//        // Notes
//        if let notes = order.notesForNGO, !notes.isEmpty {
//            notesLabel.text = notes
//        } else {
//            notesLabel.text = "—"
//        }
//
//        // Button visibility
//        markSentButton.isHidden = (order.status == .sent)
//    }
//
//    private func applyStatus(_ status: Status) {
//        switch status {
//        case .pending:
//            statusBadge.text = "Pending"
//            statusBadge.backgroundColor = brandYellow.withAlphaComponent(0.35)
//        case .sent:
//            statusBadge.text = "Sent"
//            statusBadge.backgroundColor = statusGreen.withAlphaComponent(0.25)
//        }
//    }
//
//    // MARK: - Actions
//
//    @objc private func markSentTapped() {
//        guard var order = order, order.status == .pending else { return }
//
//        let alert = UIAlertController(
//            title: "Mark as Sent?",
//            message: "This will change the order status to Sent.",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//        alert.addAction(UIAlertAction(title: "Mark as Sent", style: .default, handler: { [weak self] _ in
//            guard let self else { return }
//            order.status = .sent
//            self.order = order         // يحدّث الـ UI
//            self.onStatusChanged?(order)
//        }))
//
//        present(alert, animated: true)
//    }
//}
