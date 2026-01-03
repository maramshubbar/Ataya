//
//  GiftOrdersListViewController.swift
//  Ataya
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class GiftOrdersListViewController: UIViewController {

    // MARK: - Outlets (optional: works with or without storyboard connections)
    @IBOutlet private weak var segmentedOutlet: UISegmentedControl?
    @IBOutlet private weak var tableViewOutlet: UITableView?
    @IBOutlet private weak var emptyLabelOutlet: UILabel?

    // MARK: - UI (real used refs)
    private var segmented: UISegmentedControl!
    private var tableView: UITableView!
    private var emptyLabel: UILabel!

    // MARK: - Data
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private var allOrders: [Order] = []
    private var shownOrders: [Order] = []

    // MARK: - Types (nested => no name conflicts)
    private enum Filter: Int {
        case all = 0
        case pending = 1
        case sent = 2
    }

    fileprivate enum Status: String {
        case pending
        case sent

        static func fromFirestore(_ data: [String: Any]) -> Status {
            if let s = (data["status"] as? String)?.lowercased(),
               let st = Status(rawValue: s) {
                return st
            }
            if let isSent = data["isSent"] as? Bool, isSent { return .sent }
            if data["sentAt"] != nil { return .sent }
            return .pending
        }
    }

    private struct Recipient {
        let name: String
        let email: String

        static func from(_ raw: Any?) -> Recipient {
            guard let dict = raw as? [String: Any] else {
                return Recipient(name: "", email: "")
            }
            let name =
            (dict["name"] as? String) ??
            (dict["fullName"] as? String) ??
            (dict["recipientName"] as? String) ?? ""

            let email =
            (dict["email"] as? String) ??
            (dict["recipientEmail"] as? String) ?? ""

            return Recipient(name: name, email: email)
        }
    }

    private struct Order {
        let id: String
        let amount: Double
        let currency: String

        let giftId: String
        let giftTitle: String

        let cardDesignId: String
        let cardDesignTitle: String

        let createdAt: Timestamp?
        let createdByUid: String

        let fromName: String
        let message: String
        let pricingMode: String

        let recipient: Recipient
        let status: Status

        static func fromFirestore(docId: String, data: [String: Any]) -> Order? {
            let amount: Double = {
                if let d = data["amount"] as? Double { return d }
                if let i = data["amount"] as? Int { return Double(i) }
                if let n = data["amount"] as? NSNumber { return n.doubleValue }
                return 0
            }()

            let currency = (data["currency"] as? String) ?? "BHD"

            let giftId = (data["giftId"] as? String) ?? ""
            let giftTitle = (data["giftTitle"] as? String) ?? "Gift Certificate"

            let cardDesignId = (data["cardDesignId"] as? String) ?? ""
            let cardDesignTitle = (data["cardDesignTitle"] as? String) ?? ""

            let createdAt = data["createdAt"] as? Timestamp
            let createdByUid = (data["createdByUid"] as? String) ?? ""

            let fromName = (data["fromName"] as? String) ?? ""
            let message = (data["message"] as? String) ?? ""
            let pricingMode = (data["pricingMode"] as? String) ?? "fixed"

            let recipient = Recipient.from(data["recipient"])
            let status = Status.fromFirestore(data)

            return Order(
                id: docId,
                amount: amount,
                currency: currency,
                giftId: giftId,
                giftTitle: giftTitle,
                cardDesignId: cardDesignId,
                cardDesignTitle: cardDesignTitle,
                createdAt: createdAt,
                createdByUid: createdByUid,
                fromName: fromName,
                message: message,
                pricingMode: pricingMode,
                recipient: recipient,
                status: status
            )
        }
    }

    // MARK: - Cell (nested => NO conflicts)
    final class OrderCell: UITableViewCell {
        static let reuseID = "GiftOrdersListViewController.OrderCell"

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

        fileprivate func configure(title: String, subtitle: String, recipient: String, status: Status) {
            titleLabel.text = title
            subtitleLabel.text = subtitle
            recipientLabel.text = recipient

            switch status {
            case .pending:
                statusBadge.text = "Pending"
                statusBadge.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.18)
                statusBadge.textColor = .systemOrange
            case .sent:
                statusBadge.text = "Sent"
                statusBadge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.18)
                statusBadge.textColor = .systemGreen
            }
        }
    }

    // MARK: - Formatters
    private let moneyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        f.currencyCode = "BHD"
        return f
    }()

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        startListening()
    }

    deinit { listener?.remove() }

    // MARK: - Setup
    private func setupNav() {
        title = "Orders"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
    }

    private func setupUI() {
        // If you already have UI in storyboard, use it.
        if let seg = segmentedOutlet, let tv = tableViewOutlet {
            segmented = seg
            tableView = tv
            emptyLabel = emptyLabelOutlet ?? UILabel()

            if segmented.numberOfSegments == 0 {
                segmented.insertSegment(withTitle: "All", at: 0, animated: false)
                segmented.insertSegment(withTitle: "Pending", at: 1, animated: false)
                segmented.insertSegment(withTitle: "Sent", at: 2, animated: false)
            }
            if segmented.selectedSegmentIndex < 0 { segmented.selectedSegmentIndex = 0 }
        } else {
            // Build UI programmatically if no storyboard outlets
            segmented = UISegmentedControl(items: ["All", "Pending", "Sent"])
            tableView = UITableView(frame: .zero, style: .plain)
            emptyLabel = UILabel()

            segmented.translatesAutoresizingMaskIntoConstraints = false
            tableView.translatesAutoresizingMaskIntoConstraints = false
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false

            segmented.selectedSegmentIndex = 0
            segmented.backgroundColor = .systemGray6
            segmented.selectedSegmentTintColor = .white

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
        }

        segmented.addTarget(self, action: #selector(segChanged), for: .valueChanged)

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 110
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(OrderCell.self, forCellReuseIdentifier: OrderCell.reuseID)

        updateEmptyState()
    }

    // MARK: - Firestore
    private func startListening() {
        listener?.remove()

        // ✅ your collection is giftCertificates (from your screenshot)
        let q: Query = db.collection("giftCertificates")
            .order(by: "createdAt", descending: true)

        listener = q.addSnapshotListener { [weak self] snap, err in
            guard let self else { return }

            if let err {
                print("❌ Orders listen error:", err.localizedDescription)
                return
            }
            guard let snap else { return }

            print("📌 giftCertificates docs:", snap.documents.count)

            var items: [Order] = []
            for doc in snap.documents {
                let data = doc.data()
                if let order = Order.fromFirestore(docId: doc.documentID, data: data) {
                    items.append(order)
                } else {
                    print("❌ skipped order:", doc.documentID, "keys:", Array(data.keys))
                }
            }

            DispatchQueue.main.async {
                self.allOrders = items
                self.applyFilter()
            }
        }
    }

    // MARK: - Filtering
    @objc private func segChanged() {
        applyFilter()
    }

    private func applyFilter() {
        let f = Filter(rawValue: segmented.selectedSegmentIndex) ?? .all

        switch f {
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
        let isEmpty = shownOrders.isEmpty
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    private func moneyText(amount: Double, currency: String) -> String {
        moneyFormatter.currencyCode = currency
        return moneyFormatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
    }
}

// MARK: - Table
extension GiftOrdersListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shownOrders.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = shownOrders[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: OrderCell.reuseID,
            for: indexPath
        ) as! OrderCell

        let amountLine = "\(moneyText(amount: item.amount, currency: item.currency)) • \(item.pricingMode.capitalized)"
        let subtitle = item.cardDesignTitle.isEmpty ? amountLine : "\(item.cardDesignTitle) • \(amountLine)"

        let recipientName = item.recipient.name.isEmpty ? "-" : item.recipient.name
        let recipientLine = "Recipient: \(recipientName)"

        cell.configure(
            title: item.giftTitle,
            subtitle: subtitle,
            recipient: recipientLine,
            status: item.status
        )

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let order = shownOrders[indexPath.row]
        print("✅ Selected order:", order.id)

        // If you have details VC, push here.
        // let vc = GiftOrderDetailsViewController(orderId: order.id)
        // navigationController?.pushViewController(vc, animated: true)
    }
}
