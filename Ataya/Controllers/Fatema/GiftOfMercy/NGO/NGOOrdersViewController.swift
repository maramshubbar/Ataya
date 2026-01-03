//
//  NGOOrdersViewController.swift
//  Ataya
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - Models

enum GiftCertificateOrderStatus: String {
    case pending
    case sent

    static func fromFirestore(_ data: [String: Any]) -> GiftCertificateOrderStatus {
        // 1) explicit string status
        if let s = (data["status"] as? String)?.lowercased(),
           let st = GiftCertificateOrderStatus(rawValue: s) {
            return st
        }

        // 2) boolean / timestamp hints (optional)
        if let isSent = data["isSent"] as? Bool, isSent == true { return .sent }
        if data["sentAt"] != nil { return .sent }

        // default
        return .pending
    }
}

struct GiftCertificateRecipient {
    let name: String
    let email: String

    static func fromFirestore(_ raw: Any?) -> GiftCertificateRecipient {
        guard let dict = raw as? [String: Any] else {
            return GiftCertificateRecipient(name: "", email: "")
        }

        let name =
        (dict["name"] as? String) ??
        (dict["fullName"] as? String) ??
        (dict["recipientName"] as? String) ?? ""

        let email =
        (dict["email"] as? String) ??
        (dict["recipientEmail"] as? String) ?? ""

        return GiftCertificateRecipient(name: name, email: email)
    }
}

struct GiftCertificateOrder {
    let id: String

    let amount: Double
    let currency: String

    let cardDesignId: String
    let cardDesignTitle: String

    let createdAt: Timestamp?
    let createdByUid: String

    let fromName: String
    let message: String

    let giftId: String
    let giftTitle: String

    let pricingMode: String
    let recipient: GiftCertificateRecipient

    let status: GiftCertificateOrderStatus

    static func fromFirestore(docId: String, data: [String: Any]) -> GiftCertificateOrder? {

        // amount can be Int or Double
        let amount: Double = {
            if let d = data["amount"] as? Double { return d }
            if let i = data["amount"] as? Int { return Double(i) }
            if let n = data["amount"] as? NSNumber { return n.doubleValue }
            return 0
        }()

        let currency = (data["currency"] as? String) ?? "BHD"

        let cardDesignId = (data["cardDesignId"] as? String) ?? ""
        let cardDesignTitle = (data["cardDesignTitle"] as? String) ?? ""

        let createdAt = data["createdAt"] as? Timestamp
        let createdByUid = (data["createdByUid"] as? String) ?? ""

        let fromName = (data["fromName"] as? String) ?? ""
        let message = (data["message"] as? String) ?? ""

        let giftId = (data["giftId"] as? String) ?? ""
        let giftTitle = (data["giftTitle"] as? String) ?? ""

        let pricingMode = (data["pricingMode"] as? String) ?? "fixed"
        let recipient = GiftCertificateRecipient.fromFirestore(data["recipient"])

        let status = GiftCertificateOrderStatus.fromFirestore(data)

        return GiftCertificateOrder(
            id: docId,
            amount: amount,
            currency: currency,
            cardDesignId: cardDesignId,
            cardDesignTitle: cardDesignTitle,
            createdAt: createdAt,
            createdByUid: createdByUid,
            fromName: fromName,
            message: message,
            giftId: giftId,
            giftTitle: giftTitle,
            pricingMode: pricingMode,
            recipient: recipient,
            status: status
        )
    }
}

// MARK: - Service

final class GiftCertificatesService {

    static let shared = GiftCertificatesService()
    private init() {}

    private let db = Firestore.firestore()

    /// Listens to giftCertificates
    func listenOrders(completion: @escaping (Result<[GiftCertificateOrder], Error>) -> Void) -> ListenerRegistration {

        // ✅ If you saved ngoId inside giftCertificates documents, you can filter like this:
        // let ngoId = Auth.auth().currentUser?.uid ?? ""
        // var q: Query = db.collection("giftCertificates").whereField("ngoId", isEqualTo: ngoId)

        let q: Query = db.collection("giftCertificates")
            .order(by: "createdAt", descending: true)

        return q.addSnapshotListener { snap, err in
            if let err { completion(.failure(err)); return }
            guard let snap else { completion(.success([])); return }

            // Debug (helps you see if Firestore is returning docs)
            print("📌 giftCertificates docs:", snap.documents.count)

            var items: [GiftCertificateOrder] = []
            for doc in snap.documents {
                let data = doc.data()
                if let item = GiftCertificateOrder.fromFirestore(docId: doc.documentID, data: data) {
                    items.append(item)
                } else {
                    print("❌ skipped order doc:", doc.documentID, "keys:", Array(data.keys))
                }
            }

            completion(.success(items))
        }
    }

    /// Optional: update status to sent/pending
    func updateOrderStatus(orderId: String, status: GiftCertificateOrderStatus, completion: ((Error?) -> Void)? = nil) {
        db.collection("giftCertificates")
            .document(orderId)
            .setData([
                "status": status.rawValue,
                "updatedAt": FieldValue.serverTimestamp(),
                "sentAt": status == .sent ? FieldValue.serverTimestamp() : NSNull()
            ], merge: true) { err in
                completion?(err)
            }
    }
}

// MARK: - NGOOrdersViewController

final class NGOOrdersViewController: UIViewController {

    private enum Filter: Int {
        case all = 0
        case pending = 1
        case sent = 2
    }

    private let segmented = UISegmentedControl(items: ["All", "Pending", "Sent"])
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()

    private var allOrders: [GiftCertificateOrder] = []
    private var shownOrders: [GiftCertificateOrder] = []
    private var listener: ListenerRegistration?

    private let moneyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        f.currencyCode = "BHD"
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        startListening()
    }

    deinit { listener?.remove() }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // optional: keep it listening if you want, or stop when leaving:
        // listener?.remove()
        // listener = nil
    }

    private func setupNav() {
        title = "Orders"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
    }

    private func setupUI() {
        // Segmented
        segmented.translatesAutoresizingMaskIntoConstraints = false
        segmented.selectedSegmentIndex = 0
        segmented.backgroundColor = .systemGray6
        segmented.selectedSegmentTintColor = .white
        segmented.addTarget(self, action: #selector(segChanged), for: .valueChanged)

        segmented.setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabel], for: .normal)
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .selected)

        // Table
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 110
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NGOOrderCell.self, forCellReuseIdentifier: NGOOrderCell.reuseID)

        // Empty label
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No orders yet."
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .systemFont(ofSize: 16, weight: .regular)
        emptyLabel.textAlignment = .center

        view.addSubview(segmented)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            segmented.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmented.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmented.heightAnchor.constraint(equalToConstant: 32),

            tableView.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        updateEmptyState()
    }

    private func startListening() {
        listener?.remove()

        listener = GiftCertificatesService.shared.listenOrders { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    print("❌ Orders listen error:", err.localizedDescription)

                case .success(let items):
                    self.allOrders = items.sorted {
                        ($0.createdAt?.dateValue() ?? .distantPast) >
                        ($1.createdAt?.dateValue() ?? .distantPast)
                    }
                    self.applyFilter()
                }
            }
        }
    }

    @objc private func segChanged() {
        applyFilter()
    }

    private func applyFilter() {
        let filter = Filter(rawValue: segmented.selectedSegmentIndex) ?? .all

        switch filter {
        case .all:
            shownOrders = allOrders

        case .pending:
            shownOrders = allOrders.filter { $0.status == .pending }

        case .sent:
            shownOrders = allOrders.filter { $0.status == .sent }
        }

        tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        emptyLabel.isHidden = !shownOrders.isEmpty
        tableView.isHidden = shownOrders.isEmpty
    }

    private func moneyText(amount: Double, currency: String) -> String {
        moneyFormatter.currencyCode = currency
        return moneyFormatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
    }
}

// MARK: - Table

extension NGOOrdersViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shownOrders.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = shownOrders[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: NGOOrderCell.reuseID,
            for: indexPath
        ) as! NGOOrderCell

        let amountLine = "\(moneyText(amount: item.amount, currency: item.currency)) • \(item.pricingMode.capitalized)"
        let recipientLine = item.recipient.name.isEmpty ? "Recipient: -" : "Recipient: \(item.recipient.name)"

        cell.configure(
            title: item.giftTitle.isEmpty ? "Gift Certificate" : item.giftTitle,
            subtitle: item.cardDesignTitle.isEmpty ? amountLine : "\(item.cardDesignTitle) • \(amountLine)",
            recipient: recipientLine,
            status: item.status
        )

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let order = shownOrders[indexPath.row]
        print("✅ Open order:", order.id)

        // If you already have a details VC, push it here:
        // let vc = GiftOrderDetailsViewController(order: order)
        // navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Cell

final class NGOOrderCell: UITableViewCell {

    static let reuseID = "NGOOrderCell"

    private let card = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let recipientLabel = UILabel()
    private let statusBadge = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 16

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2

        recipientLabel.translatesAutoresizingMaskIntoConstraints = false
        recipientLabel.font = .systemFont(ofSize: 13, weight: .regular)
        recipientLabel.textColor = .secondaryLabel
        recipientLabel.numberOfLines = 1

        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        statusBadge.font = .systemFont(ofSize: 12, weight: .semibold)
        statusBadge.textAlignment = .center
        statusBadge.layer.cornerRadius = 10
        statusBadge.clipsToBounds = true

        contentView.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)
        card.addSubview(recipientLabel)
        card.addSubview(statusBadge)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusBadge.leadingAnchor, constant: -10),

            statusBadge.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusBadge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            statusBadge.widthAnchor.constraint(equalToConstant: 72),
            statusBadge.heightAnchor.constraint(equalToConstant: 20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            subtitleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            recipientLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
            recipientLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            recipientLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            recipientLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
    }

    func configure(title: String, subtitle: String, recipient: String, status: GiftCertificateOrderStatus) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        recipientLabel.text = recipient

        switch status {
        case .pending:
            statusBadge.text = "Pending"
            statusBadge.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
            statusBadge.textColor = .systemOrange
        case .sent:
            statusBadge.text = "Sent"
            statusBadge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            statusBadge.textColor = .systemGreen
        }
    }
}
