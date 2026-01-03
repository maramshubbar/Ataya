////
////  NGOOrdersViewController.swift
////  Ataya
////
//
//import UIKit
//import FirebaseAuth
//import FirebaseFirestore
//import MessageUI
//
//// MARK: - Theme
//// MARK: - Models
//
//enum GiftCertificateOrderStatus: String {
//    case pending
//    case approved
//    case rejected
//    case sent
//
//    static func fromFirestore(_ data: [String: Any]) -> GiftCertificateOrderStatus {
//        // 1) explicit string status
//        if let s = (data["status"] as? String)?.lowercased(),
//           let st = GiftCertificateOrderStatus(rawValue: s) {
//            return st
//        }
//
//        // 2) fallback hints
//        if let isSent = data["isSent"] as? Bool, isSent == true { return .sent }
//        if data["sentAt"] != nil { return .sent }
//
//        if data["approvedAt"] != nil { return .approved }
//        if data["rejectedAt"] != nil { return .rejected }
//
//        return .pending
//    }
//}
//
//struct GiftCertificateRecipient {
//    let name: String
//    let email: String
//
//    static func fromFirestore(_ raw: Any?) -> GiftCertificateRecipient {
//        guard let dict = raw as? [String: Any] else {
//            return GiftCertificateRecipient(name: "", email: "")
//        }
//
//        let name =
//            (dict["name"] as? String) ??
//            (dict["fullName"] as? String) ??
//            (dict["recipientName"] as? String) ?? ""
//
//        let email =
//            (dict["email"] as? String) ??
//            (dict["recipientEmail"] as? String) ?? ""
//
//        return GiftCertificateRecipient(name: name, email: email)
//    }
//}
//
//struct GiftCertificateOrder {
//    let id: String
//
//    let amount: Double
//    let currency: String
//
//    let cardDesignId: String
//    let cardDesignTitle: String
//
//    let createdAt: Timestamp?
//    let createdByUid: String
//
//    let fromName: String
//    let message: String
//
//    let giftId: String
//    let giftTitle: String
//
//    let pricingMode: String
//    let recipient: GiftCertificateRecipient
//
//    let status: GiftCertificateOrderStatus
//
//    static func fromFirestore(docId: String, data: [String: Any]) -> GiftCertificateOrder? {
//
//        let amount: Double = {
//            if let d = data["amount"] as? Double { return d }
//            if let i = data["amount"] as? Int { return Double(i) }
//            if let n = data["amount"] as? NSNumber { return n.doubleValue }
//            return 0
//        }()
//
//        let currency = (data["currency"] as? String) ?? "BHD"
//
//        let cardDesignId = (data["cardDesignId"] as? String) ?? ""
//        let cardDesignTitle = (data["cardDesignTitle"] as? String) ?? ""
//
//        let createdAt = data["createdAt"] as? Timestamp
//        let createdByUid = (data["createdByUid"] as? String) ?? ""
//
//        let fromName = (data["fromName"] as? String) ?? ""
//        let message = (data["message"] as? String) ?? ""
//
//        let giftId = (data["giftId"] as? String) ?? ""
//        let giftTitle = (data["giftTitle"] as? String) ?? ""
//
//        let pricingMode = (data["pricingMode"] as? String) ?? "fixed"
//        let recipient = GiftCertificateRecipient.fromFirestore(data["recipient"])
//
//        let status = GiftCertificateOrderStatus.fromFirestore(data)
//
//        return GiftCertificateOrder(
//            id: docId,
//            amount: amount,
//            currency: currency,
//            cardDesignId: cardDesignId,
//            cardDesignTitle: cardDesignTitle,
//            createdAt: createdAt,
//            createdByUid: createdByUid,
//            fromName: fromName,
//            message: message,
//            giftId: giftId,
//            giftTitle: giftTitle,
//            pricingMode: pricingMode,
//            recipient: recipient,
//            status: status
//        )
//    }
//}
//
//// MARK: - Service
//
//final class GiftCertificatesService {
//
//    static let shared = GiftCertificatesService()
//    private init() {}
//
//    private let db = Firestore.firestore()
//
//    /// Listen to giftCertificates (بدون index requirements). لو عندج ngoId داخل doc تقدرون تسوون فلترة داخل loop.
//    func listenOrders(ngoId: String?, completion: @escaping (Result<[GiftCertificateOrder], Error>) -> Void) -> ListenerRegistration {
//
//        let q: Query = db.collection("giftCertificates")
//            .order(by: "createdAt", descending: true)
//
//        return q.addSnapshotListener { snap, err in
//            if let err { completion(.failure(err)); return }
//            guard let snap else { completion(.success([])); return }
//
//            var items: [GiftCertificateOrder] = []
//            for doc in snap.documents {
//                let data = doc.data()
//
//                // ✅ فلترة اختيارية لو عندج ngoId محفوظ في الدوكيومنت
//                if let ngoId,
//                   let docNgo = data["ngoId"] as? String,
//                   docNgo != ngoId {
//                    continue
//                }
//
//                if let item = GiftCertificateOrder.fromFirestore(docId: doc.documentID, data: data) {
//                    items.append(item)
//                }
//            }
//            completion(.success(items))
//        }
//    }
//
//    func approve(orderId: String, completion: ((Error?) -> Void)? = nil) {
//        db.collection("giftCertificates").document(orderId).setData([
//            "status": GiftCertificateOrderStatus.approved.rawValue,
//            "approvedAt": FieldValue.serverTimestamp(),
//            "updatedAt": FieldValue.serverTimestamp()
//        ], merge: true, completion: completion)
//    }
//
//    func reject(orderId: String, reason: String?, completion: ((Error?) -> Void)? = nil) {
//        var data: [String: Any] = [
//            "status": GiftCertificateOrderStatus.rejected.rawValue,
//            "rejectedAt": FieldValue.serverTimestamp(),
//            "updatedAt": FieldValue.serverTimestamp()
//        ]
//        if let reason, !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            data["rejectedReason"] = reason
//        }
//        db.collection("giftCertificates").document(orderId).setData(data, merge: true, completion: completion)
//    }
//
//    func markSent(orderId: String, completion: ((Error?) -> Void)? = nil) {
//        db.collection("giftCertificates").document(orderId).setData([
//            "status": GiftCertificateOrderStatus.sent.rawValue,
//            "isSent": true,
//            "sentAt": FieldValue.serverTimestamp(),
//            "updatedAt": FieldValue.serverTimestamp()
//        ], merge: true, completion: completion)
//    }
//}
//
//// MARK: - NGOOrdersViewController
//
//final class NGOOrdersViewController: UIViewController {
//
//    private enum Filter: Int {
//        case all = 0
//        case pending = 1
//        case rejected = 2
//        case approved = 3
//    }
//
//    private let searchBar = UISearchBar()
//    private let segmented = UISegmentedControl(items: ["All", "Pending", "Rejected", "Approved"])
//    private let tableView = UITableView(frame: .zero, style: .plain)
//    private let emptyLabel = UILabel()
//
//    private var allOrders: [GiftCertificateOrder] = []
//    private var shownOrders: [GiftCertificateOrder] = []
//    private var listener: ListenerRegistration?
//
//    private let moneyFormatter: NumberFormatter = {
//        let f = NumberFormatter()
//        f.numberStyle = .currency
//        f.maximumFractionDigits = 2
//        f.currencyCode = "BHD"
//        return f
//    }()
//
//    private static let dateFormatter: DateFormatter = {
//        let f = DateFormatter()
//        f.dateStyle = .medium
//        f.timeStyle = .none
//        return f
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupNav()
//        setupUI()
//        startListening()
//    }
//
//    deinit { listener?.remove() }
//
//    private func setupNav() {
//        title = "Orders"
//        navigationItem.largeTitleDisplayMode = .never
//        view.backgroundColor = .atayaBG
//    }
//
//    private func setupUI() {
//        // Search
//        searchBar.translatesAutoresizingMaskIntoConstraints = false
//        searchBar.placeholder = "Search"
//        searchBar.searchBarStyle = .minimal
//        searchBar.backgroundImage = UIImage()
//        searchBar.delegate = self
//        if let tf = searchBar.searchTextField as UITextField? {
//            tf.backgroundColor = .systemBackground
//            tf.layer.cornerRadius = 12
//            tf.clipsToBounds = true
//        }
//
//        // Segmented (pill-ish)
//        segmented.translatesAutoresizingMaskIntoConstraints = false
//        segmented.selectedSegmentIndex = 0
//        segmented.backgroundColor = .systemGray6
//        segmented.selectedSegmentTintColor = .systemBackground
//        segmented.addTarget(self, action: #selector(segChanged), for: .valueChanged)
//        segmented.setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabel], for: .normal)
//        segmented.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .selected)
//
//        // Table
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.backgroundColor = .clear
//        tableView.separatorStyle = .none
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 140
//        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 16, right: 0)
//        tableView.keyboardDismissMode = .onDrag
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.register(NGOOrderCardCell.self, forCellReuseIdentifier: NGOOrderCardCell.reuseID)
//
//        // Empty
//        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
//        emptyLabel.text = "No orders yet."
//        emptyLabel.textColor = .secondaryLabel
//        emptyLabel.font = .systemFont(ofSize: 16, weight: .regular)
//        emptyLabel.textAlignment = .center
//
//        view.addSubview(searchBar)
//        view.addSubview(segmented)
//        view.addSubview(tableView)
//        view.addSubview(emptyLabel)
//
//        NSLayoutConstraint.activate([
//            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
//            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
//            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
//
//            segmented.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
//            segmented.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            segmented.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            segmented.heightAnchor.constraint(equalToConstant: 34),
//
//            tableView.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 8),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//
//            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//
//        updateEmptyState()
//    }
//
//    private func startListening() {
//        listener?.remove()
//
//        let ngoId = Auth.auth().currentUser?.uid
//
//        listener = GiftCertificatesService.shared.listenOrders(ngoId: ngoId) { [weak self] result in
//            guard let self else { return }
//
//            DispatchQueue.main.async {
//                switch result {
//                case .failure(let err):
//                    print("❌ Orders listen error:", err.localizedDescription)
//
//                case .success(let items):
//                    self.allOrders = items.sorted {
//                        ($0.createdAt?.dateValue() ?? .distantPast) >
//                        ($1.createdAt?.dateValue() ?? .distantPast)
//                    }
//                    self.applyFilterAndSearch()
//                }
//            }
//        }
//    }
//
//    @objc private func segChanged() {
//        applyFilterAndSearch()
//    }
//
//    private func applyFilterAndSearch() {
//        let filter = Filter(rawValue: segmented.selectedSegmentIndex) ?? .all
//        let q = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
//
//        var base: [GiftCertificateOrder] = allOrders
//
//        switch filter {
//        case .all:
//            break
//        case .pending:
//            base = base.filter { $0.status == .pending }
//        case .rejected:
//            base = base.filter { $0.status == .rejected }
//        case .approved:
//            // approved تشمل sent بعد
//            base = base.filter { $0.status == .approved || $0.status == .sent }
//        }
//
//        if q.isEmpty {
//            shownOrders = base
//        } else {
//            shownOrders = base.filter { o in
//                let hay = [
//                    o.giftTitle,
//                    o.cardDesignTitle,
//                    o.fromName,
//                    o.recipient.name,
//                    o.recipient.email
//                ].joined(separator: " ").lowercased()
//                return hay.contains(q)
//            }
//        }
//
//        tableView.reloadData()
//        updateEmptyState()
//    }
//
//    private func updateEmptyState() {
//        emptyLabel.isHidden = !shownOrders.isEmpty
//        tableView.isHidden = shownOrders.isEmpty
//    }
//
//    private func moneyText(amount: Double, currency: String) -> String {
//        moneyFormatter.currencyCode = currency
//        return moneyFormatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
//    }
//
//    private func dateText(_ ts: Timestamp?) -> String {
//        guard let ts else { return "" }
//        return Self.dateFormatter.string(from: ts.dateValue())
//    }
//
//    private func openDetails(order: GiftCertificateOrder) {
//        let vc = NGOGiftCertificateOrderDetailsViewController(order: order)
//        navigationController?.pushViewController(vc, animated: true)
//    }
//}
//
//// MARK: - Search
//
//extension NGOOrdersViewController: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        applyFilterAndSearch()
//    }
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//    }
//}
//
//// MARK: - Table
//
//extension NGOOrdersViewController: UITableViewDataSource, UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        shownOrders.count
//    }
//
//    func tableView(_ tableView: UITableView,
//                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let item = shownOrders[indexPath.row]
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: NGOOrderCardCell.reuseID, for: indexPath) as! NGOOrderCardCell
//
//        let amountLine = "\(moneyText(amount: item.amount, currency: item.currency)) • \(item.pricingMode.capitalized)"
//        let fromLine = item.fromName.isEmpty ? "" : item.fromName
//        let subtitle = item.cardDesignTitle.isEmpty
//            ? "\(fromLine) • \(amountLine)"
//            : "\(fromLine) • \(item.cardDesignTitle) • \(amountLine)"
//
//        let recipientLine = item.recipient.name.isEmpty ? "Recipient: -" : "Recipient: \(item.recipient.name)"
//        let dateLine = dateText(item.createdAt)
//
//        cell.configure(
//            title: item.giftTitle.isEmpty ? "Gift Certificate" : item.giftTitle,
//            subtitle: subtitle.replacingOccurrences(of: " •  • ", with: " • "),
//            recipient: recipientLine,
//            dateText: dateLine,
//            status: item.status
//        )
//
//        cell.onTapDetails = { [weak self] in
//            self?.openDetails(order: item)
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        openDetails(order: shownOrders[indexPath.row])
//    }
//}
//
//// MARK: - Cell (Donation Overview style)
//
//final class NGOOrderCardCell: UITableViewCell {
//
//    static let reuseID = "NGOOrderCardCell"
//
//    var onTapDetails: (() -> Void)?
//
//    private let card = UIView()
//    private let iconView = UIImageView()
//
//    private let titleLabel = UILabel()
//    private let subtitleLabel = UILabel()
//    private let recipientLabel = UILabel()
//    private let dateLabel = UILabel()
//
//    private let statusBadge = UILabel()
//    private let detailsButton = UIButton(type: .system)
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setup()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setup()
//    }
//
//    private func setup() {
//        selectionStyle = .none
//        backgroundColor = .clear
//        contentView.backgroundColor = .clear
//
//        card.translatesAutoresizingMaskIntoConstraints = false
//        card.backgroundColor = .systemBackground
//        card.layer.cornerRadius = 16
//        card.layer.shadowColor = UIColor.black.cgColor
//        card.layer.shadowOpacity = 0.06
//        card.layer.shadowRadius = 10
//        card.layer.shadowOffset = CGSize(width: 0, height: 6)
//
//        iconView.translatesAutoresizingMaskIntoConstraints = false
//        iconView.image = UIImage(systemName: "gift.fill")
//        iconView.tintColor = .secondaryLabel
//        iconView.contentMode = .scaleAspectFit
//        iconView.backgroundColor = UIColor.systemGray6
//        iconView.layer.cornerRadius = 12
//        iconView.clipsToBounds = true
//
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
//        titleLabel.textColor = .label
//        titleLabel.numberOfLines = 1
//
//        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        subtitleLabel.font = .systemFont(ofSize: 12.5, weight: .regular)
//        subtitleLabel.textColor = .secondaryLabel
//        subtitleLabel.numberOfLines = 2
//
//        recipientLabel.translatesAutoresizingMaskIntoConstraints = false
//        recipientLabel.font = .systemFont(ofSize: 12.5, weight: .regular)
//        recipientLabel.textColor = .secondaryLabel
//        recipientLabel.numberOfLines = 1
//
//        dateLabel.translatesAutoresizingMaskIntoConstraints = false
//        dateLabel.font = .systemFont(ofSize: 12.5, weight: .regular)
//        dateLabel.textColor = .secondaryLabel
//        dateLabel.numberOfLines = 1
//
//        statusBadge.translatesAutoresizingMaskIntoConstraints = false
//        statusBadge.font = .systemFont(ofSize: 12, weight: .semibold)
//        statusBadge.textAlignment = .center
//        statusBadge.layer.cornerRadius = 10
//        statusBadge.clipsToBounds = true
//
//        detailsButton.translatesAutoresizingMaskIntoConstraints = false
//        detailsButton.setTitle("View Details", for: .normal)
//        detailsButton.setTitleColor(.black, for: .normal)
//        detailsButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
//        detailsButton.backgroundColor = .atayaYellow
//        detailsButton.layer.cornerRadius = 10
//        detailsButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
//        detailsButton.addTarget(self, action: #selector(tapDetails), for: .touchUpInside)
//
//        contentView.addSubview(card)
//        card.addSubview(iconView)
//        card.addSubview(titleLabel)
//        card.addSubview(subtitleLabel)
//        card.addSubview(recipientLabel)
//        card.addSubview(dateLabel)
//        card.addSubview(statusBadge)
//        card.addSubview(detailsButton)
//
//        NSLayoutConstraint.activate([
//            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
//
//            statusBadge.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
//            statusBadge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
//            statusBadge.heightAnchor.constraint(equalToConstant: 22),
//            statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
//
//            iconView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
//            iconView.topAnchor.constraint(equalTo: statusBadge.bottomAnchor, constant: 10),
//            iconView.widthAnchor.constraint(equalToConstant: 64),
//            iconView.heightAnchor.constraint(equalToConstant: 64),
//
//            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
//            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
//            titleLabel.trailingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: -12),
//
//            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
//            subtitleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
//            subtitleLabel.trailingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: -12),
//
//            recipientLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
//            recipientLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
//            recipientLabel.trailingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: -12),
//
//            dateLabel.topAnchor.constraint(equalTo: recipientLabel.bottomAnchor, constant: 6),
//            dateLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
//            dateLabel.trailingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: -12),
//
//            detailsButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
//            detailsButton.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
//            detailsButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
//        ])
//    }
//
//    @objc private func tapDetails() {
//        onTapDetails?()
//    }
//
//    func configure(title: String, subtitle: String, recipient: String, dateText: String, status: GiftCertificateOrderStatus) {
//        titleLabel.text = title
//        subtitleLabel.text = subtitle
//        recipientLabel.text = recipient
//        dateLabel.text = dateText.isEmpty ? "" : dateText
//
//        switch status {
//        case .pending:
//            statusBadge.text = "Pending"
//            statusBadge.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.18)
//            statusBadge.textColor = .systemOrange
//
//        case .approved:
//            statusBadge.text = "Approved"
//            statusBadge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.18)
//            statusBadge.textColor = .systemGreen
//
//        case .rejected:
//            statusBadge.text = "Rejected"
//            statusBadge.backgroundColor = UIColor.systemRed.withAlphaComponent(0.18)
//            statusBadge.textColor = .systemRed
//
//        case .sent:
//            statusBadge.text = "Sent"
//            statusBadge.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.16)
//            statusBadge.textColor = .systemBlue
//        }
//    }
//}
