//
//  NGOGiftCertificateOrderDetailsViewController.swift
//  Ataya
//

import UIKit
import FirebaseFirestore
import MessageUI

// MARK: - Small UI helpers

final class InsetsLabel: UILabel {
    var insets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(
            width: s.width + insets.left + insets.right,
            height: s.height + insets.top + insets.bottom
        )
    }
}

private final class CardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 6)
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }
}

// MARK: - Details VC (Approve / Reject / Send Email)

final class NGOGiftCertificateOrderDetailsViewController: UIViewController, MFMailComposeViewControllerDelegate {

    private var order: GiftCertificateOrder

    // Firestore
    private let db = Firestore.firestore()
    private let col = "giftCertificates"

    // UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let headerCard = CardView()
    private let messageCard = CardView()
    private let actionsCard = CardView()

    private let titleLabel = UILabel()
    private let subLabel = UILabel()
    private let statusPill = InsetsLabel()

    private let infoStack = UIStackView()
    private let messageTitle = UILabel()
    private let messageLabel = UILabel()

    private let approveButton = UIButton(type: .system)
    private let rejectButton = UIButton(type: .system)
    private let sendEmailButton = UIButton(type: .system)

    private let spinner = UIActivityIndicatorView(style: .medium)

    private let moneyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        f.currencyCode = "BHD"
        return f
    }()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    init(order: GiftCertificateOrder) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Order Details"
        navigationItem.largeTitleDisplayMode = .never
        setupUI()
        render()
    }

    // MARK: UI setup

    private func setupUI() {
        // Scroll + Stack
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 12

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 14),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),

            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])

        // Header Card
        let headerInner = UIStackView()
        headerInner.axis = .vertical
        headerInner.spacing = 10
        headerInner.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.numberOfLines = 2

        subLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subLabel.textColor = .secondaryLabel
        subLabel.numberOfLines = 2

        statusPill.font = .systemFont(ofSize: 12, weight: .semibold)
        statusPill.textAlignment = .center
        statusPill.layer.cornerRadius = 10
        statusPill.clipsToBounds = true

        let topRow = UIView()
        topRow.translatesAutoresizingMaskIntoConstraints = false
        topRow.addSubview(titleLabel)
        topRow.addSubview(statusPill)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        statusPill.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topRow.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: topRow.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusPill.leadingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: topRow.bottomAnchor),

            statusPill.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusPill.trailingAnchor.constraint(equalTo: topRow.trailingAnchor)
        ])

        infoStack.axis = .vertical
        infoStack.spacing = 6
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        headerInner.addArrangedSubview(topRow)
        headerInner.addArrangedSubview(subLabel)
        headerInner.addArrangedSubview(infoStack)

        headerCard.addSubview(headerInner)
        headerInner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerInner.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 14),
            headerInner.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 14),
            headerInner.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -14),
            headerInner.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -14)
        ])

        // Message Card
        let msgInner = UIStackView()
        msgInner.axis = .vertical
        msgInner.spacing = 8
        msgInner.translatesAutoresizingMaskIntoConstraints = false

        messageTitle.font = .systemFont(ofSize: 15, weight: .semibold)
        messageTitle.text = "Message"

        messageLabel.font = .systemFont(ofSize: 14, weight: .regular)
        messageLabel.textColor = .label
        messageLabel.numberOfLines = 0

        msgInner.addArrangedSubview(messageTitle)
        msgInner.addArrangedSubview(messageLabel)

        messageCard.addSubview(msgInner)
        NSLayoutConstraint.activate([
            msgInner.topAnchor.constraint(equalTo: messageCard.topAnchor, constant: 14),
            msgInner.leadingAnchor.constraint(equalTo: messageCard.leadingAnchor, constant: 14),
            msgInner.trailingAnchor.constraint(equalTo: messageCard.trailingAnchor, constant: -14),
            msgInner.bottomAnchor.constraint(equalTo: messageCard.bottomAnchor, constant: -14)
        ])

        // Actions Card
        let btnStack = UIStackView()
        btnStack.axis = .vertical
        btnStack.spacing = 10
        btnStack.translatesAutoresizingMaskIntoConstraints = false

        styleApprove(approveButton)
        styleReject(rejectButton)
        stylePrimary(sendEmailButton)

        approveButton.setTitle("Approve", for: .normal)
        rejectButton.setTitle("Reject", for: .normal)
        sendEmailButton.setTitle("Send Email", for: .normal)

        approveButton.addTarget(self, action: #selector(tapApprove), for: .touchUpInside)
        rejectButton.addTarget(self, action: #selector(tapReject), for: .touchUpInside)
        sendEmailButton.addTarget(self, action: #selector(tapSendEmail), for: .touchUpInside)

        spinner.hidesWhenStopped = true

        btnStack.addArrangedSubview(approveButton)
        btnStack.addArrangedSubview(rejectButton)
        btnStack.addArrangedSubview(sendEmailButton)
        btnStack.addArrangedSubview(spinner)

        actionsCard.addSubview(btnStack)
        NSLayoutConstraint.activate([
            btnStack.topAnchor.constraint(equalTo: actionsCard.topAnchor, constant: 14),
            btnStack.leadingAnchor.constraint(equalTo: actionsCard.leadingAnchor, constant: 14),
            btnStack.trailingAnchor.constraint(equalTo: actionsCard.trailingAnchor, constant: -14),
            btnStack.bottomAnchor.constraint(equalTo: actionsCard.bottomAnchor, constant: -14)
        ])

        // Add cards
        contentStack.addArrangedSubview(headerCard)
        contentStack.addArrangedSubview(messageCard)
        contentStack.addArrangedSubview(actionsCard)
    }

    private func stylePrimary(_ b: UIButton) {
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1) // Ataya Yellow
        b.setTitleColor(.black, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        b.layer.cornerRadius = 12
        b.contentEdgeInsets = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
    }

    private func styleApprove(_ b: UIButton) {
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.14)
        b.setTitleColor(.systemGreen, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        b.layer.cornerRadius = 12
        b.contentEdgeInsets = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
    }

    private func styleReject(_ b: UIButton) {
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = UIColor.systemRed.withAlphaComponent(0.14)
        b.setTitleColor(.systemRed, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        b.layer.cornerRadius = 12
        b.contentEdgeInsets = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
    }

    private func makeInfoRow(_ title: String, _ value: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .firstBaseline
        row.distribution = .fill
        row.spacing = 8

        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .secondaryLabel
        l.text = title
        l.setContentHuggingPriority(.required, for: .horizontal)

        let v = UILabel()
        v.font = .systemFont(ofSize: 13, weight: .regular)
        v.textColor = .label
        v.numberOfLines = 2
        v.text = value.isEmpty ? "-" : value

        row.addArrangedSubview(l)
        row.addArrangedSubview(v)
        return row
    }

    // MARK: Render

    private func render() {
        titleLabel.text = order.giftTitle.isEmpty ? "Gift Certificate" : order.giftTitle

        let amountText = moneyText(amount: order.amount, currency: order.currency)
        let mode = order.pricingMode.capitalized
        let created = order.createdAt.map { Self.dateFormatter.string(from: $0.dateValue()) } ?? "-"

        let fromName = order.fromName.isEmpty ? "-" : order.fromName
        let card = order.cardDesignTitle.isEmpty ? "-" : order.cardDesignTitle
        let recipient = order.recipient.name.isEmpty ? "-" : order.recipient.name
        let recipientEmail = order.recipient.email.isEmpty ? "-" : order.recipient.email

        subLabel.text = "\(card) • \(amountText) • \(mode)"

        infoStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        infoStack.addArrangedSubview(makeInfoRow("From:", fromName))
        infoStack.addArrangedSubview(makeInfoRow("Recipient:", recipient))
        infoStack.addArrangedSubview(makeInfoRow("Email:", recipientEmail))
        infoStack.addArrangedSubview(makeInfoRow("Date:", created))

        messageLabel.text = order.message.isEmpty ? "-" : order.message

        switch order.status {
        case .pending:
            setPill(text: "Pending",
                    bg: UIColor.systemOrange.withAlphaComponent(0.18),
                    fg: .systemOrange)
            approveButton.isHidden = false
            rejectButton.isHidden = false
            sendEmailButton.isHidden = true

        case .rejected:
            setPill(text: "Rejected",
                    bg: UIColor.systemRed.withAlphaComponent(0.18),
                    fg: .systemRed)
            approveButton.isHidden = true
            rejectButton.isHidden = true
            sendEmailButton.isHidden = true

        case .approved:
            setPill(text: "Approved",
                    bg: UIColor.systemGreen.withAlphaComponent(0.18),
                    fg: .systemGreen)
            approveButton.isHidden = true
            rejectButton.isHidden = true
            sendEmailButton.isHidden = false

        case .sent:
            setPill(text: "Sent",
                    bg: UIColor.systemBlue.withAlphaComponent(0.16),
                    fg: .systemBlue)
            approveButton.isHidden = true
            rejectButton.isHidden = true
            sendEmailButton.isHidden = true
        }
    }

    private func setPill(text: String, bg: UIColor, fg: UIColor) {
        statusPill.text = text
        statusPill.backgroundColor = bg
        statusPill.textColor = fg
    }

    private func setLoading(_ on: Bool) {
        if on {
            spinner.startAnimating()
            approveButton.isEnabled = false
            rejectButton.isEnabled = false
            sendEmailButton.isEnabled = false
        } else {
            spinner.stopAnimating()
            approveButton.isEnabled = true
            rejectButton.isEnabled = true
            sendEmailButton.isEnabled = true
        }
    }

    private func moneyText(amount: Double, currency: String) -> String {
        moneyFormatter.currencyCode = currency.isEmpty ? "BHD" : currency
        return moneyFormatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
    }

    // MARK: Firestore Actions (NO Service needed)

    private func approveInFirestore(orderId: String, completion: @escaping (Error?) -> Void) {
        db.collection(col).document(orderId).setData([
            "status": GiftCertificateOrderStatus.approved.rawValue,
            "approvedAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true, completion: completion)
    }

    private func rejectInFirestore(orderId: String, reason: String?, completion: @escaping (Error?) -> Void) {
        var payload: [String: Any] = [
            "status": GiftCertificateOrderStatus.rejected.rawValue,
            "rejectedAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        let r = (reason ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !r.isEmpty { payload["rejectedReason"] = r }

        db.collection(col).document(orderId).setData(payload, merge: true, completion: completion)
    }

    private func markSentInFirestore(orderId: String, completion: @escaping (Error?) -> Void) {
        db.collection(col).document(orderId).setData([
            "status": GiftCertificateOrderStatus.sent.rawValue,
            "isSent": true,
            "sentAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true, completion: completion)
    }

    // MARK: Actions

    @objc private func tapApprove() {
        setLoading(true)

        approveInFirestore(orderId: order.id) { [weak self] (err: Error?) in
            DispatchQueue.main.async {
                guard let self else { return }
                self.setLoading(false)

                if let err {
                    self.alert("Approve failed", err.localizedDescription)
                    return
                }

                self.order = GiftCertificateOrder(
                    id: self.order.id,
                    amount: self.order.amount,
                    currency: self.order.currency,
                    cardDesignId: self.order.cardDesignId,
                    cardDesignTitle: self.order.cardDesignTitle,
                    createdAt: self.order.createdAt,
                    createdByUid: self.order.createdByUid,
                    fromName: self.order.fromName,
                    message: self.order.message,
                    giftId: self.order.giftId,
                    giftTitle: self.order.giftTitle,
                    pricingMode: self.order.pricingMode,
                    recipient: self.order.recipient,
                    status: .approved
                )

                self.render()
            }
        }
    }

    @objc private func tapReject() {
        let ac = UIAlertController(
            title: "Reject Order",
            message: "Optional: add a reason",
            preferredStyle: .alert
        )
        ac.addTextField { $0.placeholder = "Reason (optional)" }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        ac.addAction(UIAlertAction(title: "Reject", style: .destructive) { [weak self] _ in
            guard let self else { return }
            let reason = ac.textFields?.first?.text
            self.setLoading(true)

            self.rejectInFirestore(orderId: self.order.id, reason: reason) { (err: Error?) in
                DispatchQueue.main.async {
                    self.setLoading(false)
                    if let err {
                        self.alert("Reject failed", err.localizedDescription)
                        return
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })

        present(ac, animated: true)
    }

    @objc private func tapSendEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            alert("Mail not available", "Sign in to Mail app (best test on real device).")
            return
        }

        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self

        let to = order.recipient.email
        if !to.isEmpty { mail.setToRecipients([to]) }

        mail.setSubject("Gift of Mercy Certificate ✅")

        let amountText = moneyText(amount: order.amount, currency: order.currency)

        let body =
        """
        Hi \(order.recipient.name.isEmpty ? "there" : order.recipient.name),

        You received a Gift of Mercy:
        - Gift: \(order.giftTitle)
        - Amount: \(amountText) (\(order.pricingMode.capitalized))
        - From: \(order.fromName)

        Message:
        \(order.message.isEmpty ? "-" : order.message)

        Regards,
        Ataya
        """

        mail.setMessageBody(body, isHTML: false)
        present(mail, animated: true)
    }

    // MARK: Mail delegate

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {

        controller.dismiss(animated: true) { [weak self] in
            guard let self else { return }

            if let error {
                self.alert("Mail error", error.localizedDescription)
                return
            }

            if result == .sent {
                self.setLoading(true)
                self.markSentInFirestore(orderId: self.order.id) { (err: Error?) in
                    DispatchQueue.main.async {
                        self.setLoading(false)
                        if let err {
                            self.alert("Update failed", err.localizedDescription)
                            return
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }

    // MARK: Alerts

    private func alert(_ title: String, _ msg: String) {
        let ac = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
