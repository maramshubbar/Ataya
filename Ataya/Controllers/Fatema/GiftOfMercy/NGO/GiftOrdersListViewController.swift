//
//  GiftOrdersListViewController.swift
//  Ataya
//

import UIKit
import FirebaseAuth
import Foundation
import FirebaseFirestore

enum GiftOrderStatus: String, CaseIterable {
    case pending
    case processing
    case sent
    case failed
    case cancelled

    var title: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .sent: return "Sent"
        case .failed: return "Failed"
        case .cancelled: return "Cancelled"
        }
    }

    static func fromFirestore(_ value: String) -> GiftOrderStatus {
        let v = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return GiftOrderStatus(rawValue: v) ?? .pending
    }
}

struct GiftOrder {
    let id: String
    let ngoId: String
    let giftName: String
    let donorName: String
    let amount: Double?
    let currency: String
    let createdAt: Date
    let status: GiftOrderStatus
    let cardDesignName: String
    let recipientsCount: Int

    // Optional details
    let message: String?
    let notesForNGO: String?

    // ✅ ADD THIS initializer (fixes your error)
    init(
        id: String,
        ngoId: String,
        giftName: String,
        donorName: String,
        amount: Double?,
        currency: String,
        createdAt: Date,
        status: GiftOrderStatus,
        cardDesignName: String,
        recipientsCount: Int,
        message: String?,
        notesForNGO: String?
    ) {
        self.id = id
        self.ngoId = ngoId
        self.giftName = giftName
        self.donorName = donorName
        self.amount = amount
        self.currency = currency
        self.createdAt = createdAt
        self.status = status
        self.cardDesignName = cardDesignName
        self.recipientsCount = recipientsCount
        self.message = message
        self.notesForNGO = notesForNGO
    }

    // ✅ Firestore init
    init?(doc: DocumentSnapshot) {
        let d = doc.data() ?? [:]

        guard
            let ngoId = d["ngoId"] as? String,
            let giftName = d["giftName"] as? String
        else { return nil }

        self.id = doc.documentID
        self.ngoId = ngoId
        self.giftName = giftName

        self.donorName = d["donorName"] as? String ?? "—"

        if let v = d["amount"] as? Double { self.amount = v }
        else if let v = d["amount"] as? Int { self.amount = Double(v) }
        else { self.amount = nil }

        self.currency = d["currency"] as? String ?? "BHD"

        if let ts = d["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = Date()
        }

        let statusRaw = d["status"] as? String ?? "pending"
        self.status = GiftOrderStatus.fromFirestore(statusRaw)

        self.cardDesignName = d["cardDesignName"] as? String ?? "—"

        if let v = d["recipientsCount"] as? Int { self.recipientsCount = v }
        else if let v = d["recipientsCount"] as? Double { self.recipientsCount = Int(v) }
        else { self.recipientsCount = 0 }

        self.message = d["message"] as? String
        self.notesForNGO = d["notesForNGO"] as? String
    }
}


// MARK: - Service (Firestore)

final class GiftOrderService {

    static let shared = GiftOrderService()
    private init() {}

    private let db = Firestore.firestore()

    // ✅ change if your collection name is different
    private var ordersRef: CollectionReference { db.collection("giftOrders") }

    func listenOrders(ngoId: String, completion: @escaping (Result<[GiftOrder], Error>) -> Void) -> ListenerRegistration {
        return ordersRef
            .whereField("ngoId", isEqualTo: ngoId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snap, err in
                if let err { completion(.failure(err)); return }
                let items = snap?.documents.compactMap { GiftOrder(doc: $0) } ?? []
                completion(.success(items))
            }
    }

    func updateStatus(orderId: String, status: GiftOrderStatus, completion: @escaping (Error?) -> Void) {
        ordersRef.document(orderId).setData([
            "status": status.rawValue, // store as "pending" etc
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true, completion: completion)
    }
}

// MARK: - VC

final class GiftOrdersListViewController: UIViewController {

    // UI
    private let filterControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["All", "Pending", "Sent"])
        sc.selectedSegmentIndex = 0
        return sc
    }()

    private let tableView = UITableView(frame: .zero, style: .plain)

    private let emptyStateLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "No orders yet."
        lbl.textAlignment = .center
        lbl.textColor = .secondaryLabel
        lbl.numberOfLines = 0
        lbl.isHidden = true
        return lbl
    }()

    private let refresh = UIRefreshControl()
    private var listener: ListenerRegistration?

    // Data
    private var allOrders: [GiftOrder] = []
    private var filteredOrders: [GiftOrder] = []

    private let amountFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        f.currencyCode = "BHD"
        return f
    }()

    private let brandYellow = UIColor(atayaHex: "F7D44C")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        setupActions()
        startListening()
    }

    deinit { listener?.remove() }

    private func setupNav() {
        view.backgroundColor = .systemBackground
        title = "Orders"
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupUI() {
        filterControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterControl)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(GiftOrderCell.self, forCellReuseIdentifier: GiftOrderCell.reuseID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 170

        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refresh

        view.addSubview(tableView)

        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            filterControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            filterControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: filterControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func setupActions() {
        filterControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
    }

    private func startListening() {
        listener?.remove()

        guard let ngoId = Auth.auth().currentUser?.uid else {
            // not logged in -> show empty
            allOrders = []
            applyFilter()
            return
        }

        listener = GiftOrderService.shared.listenOrders(ngoId: ngoId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let err):
                print("❌ orders listen error:", err.localizedDescription)
            case .success(let items):
                self.allOrders = items
                self.applyFilter()
            }
        }
    }

    @objc private func filterChanged() {
        applyFilter()
    }

    @objc private func handleRefresh() {
        // listening already updates automatically
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.refresh.endRefreshing()
            self.applyFilter()
        }
    }

    private func applyFilter() {
        switch filterControl.selectedSegmentIndex {
        case 1: // Pending
            filteredOrders = allOrders.filter { $0.status == .pending }
        case 2: // Sent
            filteredOrders = allOrders.filter { $0.status == .sent }
        default:
            filteredOrders = allOrders
        }

        emptyStateLabel.isHidden = !filteredOrders.isEmpty
        tableView.reloadData()
    }

    private func openDetails(order: GiftOrder) {
        let vc = GiftOrderDetailsViewController(order: order)
        vc.onStatusUpdated = { [weak self] orderId, newStatus in
            // optional: refresh filter immediately
            guard let self else { return }
            if let idx = self.allOrders.firstIndex(where: { $0.id == orderId }) {
                let old = self.allOrders[idx]
                self.allOrders[idx] = GiftOrder(
                    id: old.id,
                    ngoId: old.ngoId,
                    giftName: old.giftName,
                    donorName: old.donorName,
                    amount: old.amount,
                    currency: old.currency,
                    createdAt: old.createdAt,
                    status: newStatus,
                    cardDesignName: old.cardDesignName,
                    recipientsCount: old.recipientsCount,
                    message: old.message,
                    notesForNGO: old.notesForNGO
                )
                self.applyFilter()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Table

extension GiftOrdersListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredOrders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let order = filteredOrders[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: GiftOrderCell.reuseID, for: indexPath) as! GiftOrderCell

        let amountText: String = {
            guard let amount = order.amount else { return "—" }
            amountFormatter.currencyCode = order.currency
            return amountFormatter.string(from: NSNumber(value: amount)) ?? "\(order.currency) \(amount)"
        }()

        let dateText = order.createdAt.formatted(date: .abbreviated, time: .omitted)

        cell.configure(
            giftName: order.giftName,
            donorName: order.donorName,
            amountText: amountText,
            dateText: dateText,
            statusText: order.status.title,
            statusStyle: .init(from: order.status),
            designName: order.cardDesignName,
            recipientsText: "\(order.recipientsCount) recipient(s)"
        )

        cell.onViewDetails = { [weak self] in
            self?.openDetails(order: order)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openDetails(order: filteredOrders[indexPath.row])
    }
}

// MARK: - Cell

private final class GiftOrderCell: UITableViewCell {

    static let reuseID = "GiftOrderCell"
    var onViewDetails: (() -> Void)?

    private let card = UIView()

    private let titleLabel = UILabel()
    private let donorLabel = UILabel()
    private let amountLabel = UILabel()
    private let dateLabel = UILabel()
    private let designLabel = UILabel()
    private let recipientsLabel = UILabel()

    private let badge = StatusBadgeView()
    private let viewButton = UIButton(type: .system)

    private let brandYellow = UIColor(atayaHex: "F7D44C")

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onViewDetails = nil
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.addSubview(card)

        [titleLabel, donorLabel, amountLabel, dateLabel, designLabel, recipientsLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.numberOfLines = 1
        }

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        donorLabel.font = .systemFont(ofSize: 13.5)
        donorLabel.textColor = .label

        amountLabel.font = .systemFont(ofSize: 13.5)
        amountLabel.textColor = .label

        dateLabel.font = .systemFont(ofSize: 13.5)
        dateLabel.textColor = .label

        designLabel.font = .systemFont(ofSize: 13.5)
        designLabel.textColor = .label

        recipientsLabel.font = .systemFont(ofSize: 13)
        recipientsLabel.textColor = .secondaryLabel

        badge.translatesAutoresizingMaskIntoConstraints = false

        viewButton.translatesAutoresizingMaskIntoConstraints = false
        viewButton.setTitle("View Details", for: .normal)
        viewButton.setTitleColor(.black, for: .normal)
        viewButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        viewButton.backgroundColor = brandYellow
        viewButton.layer.cornerRadius = 10
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = brandYellow
            config.baseForegroundColor = .black
            config.cornerStyle = .medium
            config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 22, bottom: 10, trailing: 22)
            viewButton.configuration = config
        } else {
            viewButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 22, bottom: 10, right: 22)
        }
        viewButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)

        [titleLabel, donorLabel, amountLabel, dateLabel, designLabel, recipientsLabel, badge, viewButton].forEach(card.addSubview)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            badge.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            badge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            badge.heightAnchor.constraint(equalToConstant: 31),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: badge.leadingAnchor, constant: -10),

            donorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            donorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            donorLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            amountLabel.topAnchor.constraint(equalTo: donorLabel.bottomAnchor, constant: 4),
            amountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            designLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            designLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            designLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            recipientsLabel.topAnchor.constraint(equalTo: designLabel.bottomAnchor, constant: 4),
            recipientsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            recipientsLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            viewButton.topAnchor.constraint(equalTo: recipientsLabel.bottomAnchor, constant: 12),
            viewButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            viewButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
    }

    @objc private func viewTapped() {
        onViewDetails?()
    }

    struct StatusStyle {
        let bg: UIColor
        let text: UIColor

        init(from status: GiftOrderStatus) {
            let pendingBg   = UIColor(red: 1.0, green: 0.95, blue: 0.70, alpha: 1)
            let approvedBg  = UIColor(red: 0.82, green: 0.95, blue: 0.80, alpha: 1)
            let blueBg      = UIColor(red: 0.82, green: 0.90, blue: 1.0, alpha: 1)
            let redBg       = UIColor(red: 1.0, green: 0.85, blue: 0.85, alpha: 1)
            let grayBg      = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1)

            switch status {
            case .pending: bg = pendingBg; text = .black
            case .sent: bg = approvedBg; text = .black
            case .processing: bg = blueBg; text = .black
            case .failed: bg = redBg; text = .black
            case .cancelled: bg = grayBg; text = .black
            }
        }
    }

    func configure(
        giftName: String,
        donorName: String,
        amountText: String,
        dateText: String,
        statusText: String,
        statusStyle: StatusStyle,
        designName: String,
        recipientsText: String
    ) {
        titleLabel.text = giftName
        donorLabel.text = "Donor: \(donorName)"
        amountLabel.text = "Amount: \(amountText)"
        dateLabel.text = dateText
        designLabel.text = "Card Design: \(designName)"
        recipientsLabel.text = recipientsText
        badge.apply(text: statusText, bg: statusStyle.bg, textColor: statusStyle.text)
    }
}

private final class StatusBadgeView: UIView {

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        layer.cornerRadius = 15.5
        clipsToBounds = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    func apply(text: String, bg: UIColor, textColor: UIColor) {
        label.text = text
        label.textColor = textColor
        backgroundColor = bg
    }
}
