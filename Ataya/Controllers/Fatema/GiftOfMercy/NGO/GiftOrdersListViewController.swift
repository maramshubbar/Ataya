//
//  GiftOrdersListViewController.swift
//  Ataya
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import MessageUI

// MARK: - Model (UNIQUE names to avoid ambiguity)

enum NGOGiftOrderStatus: String {
    case pending
    case sent
    case processing
    case failed
    case cancelled

    var title: String {
        switch self {
        case .pending: return "Pending"
        case .sent: return "Sent"
        case .processing: return "Processing"
        case .failed: return "Failed"
        case .cancelled: return "Cancelled"
        }
    }

    static func fromFirestore(_ value: Any?) -> NGOGiftOrderStatus {
        let raw = (value as? String ?? "pending")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return NGOGiftOrderStatus(rawValue: raw) ?? .pending
    }
}

struct NGOGiftOrder {
    let id: String
    let ngoId: String
    let donorId: String
    let recipientName: String
    let recipientEmail: String
    let personalMessage: String
    let cardId: String
    let status: NGOGiftOrderStatus
    let createdAt: Date

    init?(doc: QueryDocumentSnapshot) {
        let d = doc.data()

        guard
            let ngoId = d["ngoId"] as? String,
            let donorId = d["donorId"] as? String
        else { return nil }

        self.id = doc.documentID
        self.ngoId = ngoId
        self.donorId = donorId

        self.recipientName = d["recipientName"] as? String ?? "—"
        self.recipientEmail = d["recipientEmail"] as? String ?? "—"
        self.personalMessage = d["personalMessage"] as? String ?? ""

        self.cardId = d["cardId"] as? String ?? ""

        self.status = NGOGiftOrderStatus.fromFirestore(d["status"])

        if let ts = d["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = Date()
        }
    }
}

// MARK: - Service (UNIQUE name)

final class NGOGiftOrderService {

    static let shared = NGOGiftOrderService()
    private init() {}

    private let db = Firestore.firestore()

    // ✅ IMPORTANT: must match your Firestore collection name
    private let ordersCollection = "gift_orders"

    // ✅ IMPORTANT: must match your card designs collection name (based on your screenshot)
    private let cardDesignsCollection = "cardDesigns"

    func listenOrdersForNGO(ngoUid: String,
                            completion: @escaping (Result<[NGOGiftOrder], Error>) -> Void) -> ListenerRegistration {

        let q = db.collection(ordersCollection)
            .whereField("ngoId", isEqualTo: ngoUid)
            .order(by: "createdAt", descending: true)

        print("✅ Listening orders for NGO:", ngoUid, "collection:", ordersCollection)

        return q.addSnapshotListener { snap, err in
            if let err = err {
                print("❌ listenOrdersForNGO error:", err.localizedDescription)
                completion(.failure(err))
                return
            }

            let items = snap?.documents.compactMap { NGOGiftOrder(doc: $0) } ?? []
            print("✅ Orders fetched:", items.count)
            completion(.success(items))
        }
    }

    func updateStatus(orderId: String,
                      status: NGOGiftOrderStatus,
                      completion: @escaping (Error?) -> Void) {

        db.collection(ordersCollection).document(orderId).setData([
            "status": status.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true, completion: completion)
    }

    // Fetch card imageURL from cardDesigns/{cardId}
    func fetchCardImageURL(cardId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard !cardId.isEmpty else {
            completion(.failure(NSError(domain: "Card", code: 0, userInfo: [NSLocalizedDescriptionKey: "cardId is empty"])))
            return
        }

        db.collection(cardDesignsCollection).document(cardId).getDocument { snap, err in
            if let err = err {
                completion(.failure(err)); return
            }
            let data = snap?.data() ?? [:]
            if let url = data["imageURL"] as? String, !url.isEmpty {
                completion(.success(url))
            } else {
                completion(.failure(NSError(domain: "Card", code: 0, userInfo: [NSLocalizedDescriptionKey: "imageURL missing in cardDesigns"])))
            }
        }
    }
}

// MARK: - GiftOrdersListViewController

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

    private var listener: ListenerRegistration?

    // Data
    private var allOrders: [NGOGiftOrder] = []
    private var filteredOrders: [NGOGiftOrder] = []

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
        tableView.register(NGOOrderCell.self, forCellReuseIdentifier: NGOOrderCell.reuseID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
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

        guard let ngoUid = Auth.auth().currentUser?.uid else {
            print("❌ NGO not logged in")
            allOrders = []
            applyFilter()
            return
        }

        listener = NGOGiftOrderService.shared.listenOrdersForNGO(ngoUid: ngoUid) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let err):
                print("❌ Orders listen error:", err.localizedDescription)
                self.allOrders = []
                self.applyFilter()
            case .success(let items):
                self.allOrders = items
                self.applyFilter()
            }
        }
    }

    @objc private func filterChanged() {
        applyFilter()
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

    private func openDetails(order: NGOGiftOrder) {
        let vc = NGOGiftOrderDetailsViewController(order: order)
        vc.onStatusUpdated = { [weak self] orderId, newStatus in
            guard let self else { return }
            if let idx = self.allOrders.firstIndex(where: { $0.id == orderId }) {
                var old = self.allOrders[idx]
                old = NGOGiftOrder(
                    id: old.id,
                    ngoId: old.ngoId,
                    donorId: old.donorId,
                    recipientName: old.recipientName,
                    recipientEmail: old.recipientEmail,
                    personalMessage: old.personalMessage,
                    cardId: old.cardId,
                    status: newStatus,
                    createdAt: old.createdAt
                )!
                self.allOrders[idx] = old
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
        let cell = tableView.dequeueReusableCell(withIdentifier: NGOOrderCell.reuseID, for: indexPath) as! NGOOrderCell

        let dateText = order.createdAt.formatted(date: .abbreviated, time: .omitted)

        cell.configure(
            title: order.recipientName,
            subtitle: order.recipientEmail,
            dateText: dateText,
            statusText: order.status.title,
            statusStyle: .init(from: order.status)
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

private final class NGOOrderCell: UITableViewCell {

    static let reuseID = "NGOOrderCell"
    var onViewDetails: (() -> Void)?

    private let card = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let dateLabel = UILabel()

    private let badge = StatusBadgeView()
    private let viewButton = UIButton(type: .system)

    private let brandYellow = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1)

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

        [titleLabel, subtitleLabel, dateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.numberOfLines = 1
        }

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        subtitleLabel.font = .systemFont(ofSize: 13.5)
        subtitleLabel.textColor = .secondaryLabel
        dateLabel.font = .systemFont(ofSize: 13.5)
        dateLabel.textColor = .label

        badge.translatesAutoresizingMaskIntoConstraints = false

        viewButton.translatesAutoresizingMaskIntoConstraints = false
        viewButton.setTitle("View Details", for: .normal)
        viewButton.setTitleColor(.black, for: .normal)
        viewButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        viewButton.layer.cornerRadius = 10
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = brandYellow
            config.baseForegroundColor = .black
            config.cornerStyle = .medium
            config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 22, bottom: 10, trailing: 22)
            viewButton.configuration = config
        } else {
            viewButton.backgroundColor = brandYellow
            viewButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 22, bottom: 10, right: 22)
        }
        viewButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)

        [titleLabel, subtitleLabel, dateLabel, badge, viewButton].forEach(card.addSubview)

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

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            viewButton.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
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

        init(from status: NGOGiftOrderStatus) {
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

    func configure(title: String, subtitle: String, dateText: String, statusText: String, statusStyle: StatusStyle) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        dateLabel.text = dateText
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

// MARK: - Details VC (inside same file, NO other dependencies)

final class NGOGiftOrderDetailsViewController: UIViewController, MFMailComposeViewControllerDelegate {

    private let order: NGOGiftOrder
    var onStatusUpdated: ((String, NGOGiftOrderStatus) -> Void)?

    private let stack = UIStackView()
    private let infoLabel = UILabel()
    private let sendButton = UIButton(type: .system)
    private let markSentButton = UIButton(type: .system)

    private let brandYellow = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1)

    init(order: NGOGiftOrder) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Order Details"
        setupUI()
    }

    private func setupUI() {
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        view.addSubview(stack)

        infoLabel.numberOfLines = 0
        infoLabel.font = .systemFont(ofSize: 15)
        infoLabel.text = """
        Recipient: \(order.recipientName)
        Email: \(order.recipientEmail)
        Status: \(order.status.title)
        Date: \(order.createdAt.formatted(date: .abbreviated, time: .omitted))

        Message:
        \(order.personalMessage.isEmpty ? "—" : order.personalMessage)
        """

        sendButton.setTitle("Send Certificate Email", for: .normal)
        sendButton.setTitleColor(.black, for: .normal)
        sendButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        sendButton.backgroundColor = brandYellow
        sendButton.layer.cornerRadius = 14
        sendButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        sendButton.addTarget(self, action: #selector(sendEmailTapped), for: .touchUpInside)

        markSentButton.setTitle("Mark as Sent", for: .normal)
        markSentButton.setTitleColor(.white, for: .normal)
        markSentButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        markSentButton.backgroundColor = .systemGreen
        markSentButton.layer.cornerRadius = 14
        markSentButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        markSentButton.addTarget(self, action: #selector(markSentTapped), for: .touchUpInside)

        stack.addArrangedSubview(infoLabel)
        stack.addArrangedSubview(sendButton)
        stack.addArrangedSubview(markSentButton)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    @objc private func markSentTapped() {
        NGOGiftOrderService.shared.updateStatus(orderId: order.id, status: .sent) { [weak self] err in
            guard let self else { return }
            if let err = err {
                self.alert("Error", err.localizedDescription)
                return
            }
            self.onStatusUpdated?(self.order.id, .sent)
            self.alert("Done ✅", "Marked as Sent.")
        }
    }

    @objc private func sendEmailTapped() {
        guard MFMailComposeViewController.canSendMail() else {
            alert("Mail not available", "Mail is not configured on this device/simulator.")
            return
        }

        // 1) Get card imageURL from cardDesigns
        NGOGiftOrderService.shared.fetchCardImageURL(cardId: order.cardId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let err):
                DispatchQueue.main.async { self.alert("Card error", err.localizedDescription) }
            case .success(let url):
                self.downloadImage(urlString: url) { imgResult in
                    switch imgResult {
                    case .failure(let err):
                        DispatchQueue.main.async { self.alert("Image error", err.localizedDescription) }
                    case .success(let baseImg):
                        let finalImg = self.drawNameOnCertificate(base: baseImg, name: self.order.recipientName)

                        DispatchQueue.main.async {
                            let mail = MFMailComposeViewController()
                            mail.mailComposeDelegate = self
                            mail.setToRecipients([self.order.recipientEmail])
                            mail.setSubject("Gift of Mercy Certificate ✅")
                            mail.setMessageBody("Hi \(self.order.recipientName),\n\nPlease find your certificate attached.\n\nRegards,\nAtaya", isHTML: false)

                            if let data = finalImg.pngData() {
                                mail.addAttachmentData(data, mimeType: "image/png", fileName: "certificate.png")
                            }
                            self.present(mail, animated: true)
                        }
                    }
                }
            }
        }
    }

    // Put the name on the lines (adjust Y if needed)
    private func drawNameOnCertificate(base: UIImage, name: String) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = base.scale
        let renderer = UIGraphicsImageRenderer(size: base.size, format: format)

        return renderer.image { _ in
            base.draw(in: CGRect(origin: .zero, size: base.size))

            let font = UIFont.systemFont(ofSize: base.size.width * 0.035, weight: .semibold)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.black
            ]

            // ✅ مكان الخطوط (يمّين تحت)
            let x = base.size.width * 0.36
            let w = base.size.width * 0.56
            let h = base.size.height * 0.04
            let y = base.size.height * 0.855  // عدّليها إذا تبينه أعلى/أوطى

            (name as NSString).draw(in: CGRect(x: x, y: y, width: w, height: h), withAttributes: attrs)
        }
    }

    private func downloadImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Bad imageURL"])))
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, err in
            if let err = err { completion(.failure(err)); return }
            guard let data, let img = UIImage(data: data) else {
                completion(.failure(NSError(domain: "IMG", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode image"])))
                return
            }
            completion(.success(img))
        }.resume()
    }

    private func alert(_ title: String, _ msg: String) {
        let ac = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
        alert("Done ✅", "Email screen closed.")
    }
}

// MARK: - Helper init to allow updating in callback (optional)
private extension NGOGiftOrder {
    init?(id: String,
          ngoId: String,
          donorId: String,
          recipientName: String,
          recipientEmail: String,
          personalMessage: String,
          cardId: String,
          status: NGOGiftOrderStatus,
          createdAt: Date) {
        self.id = id
        self.ngoId = ngoId
        self.donorId = donorId
        self.recipientName = recipientName
        self.recipientEmail = recipientEmail
        self.personalMessage = personalMessage
        self.cardId = cardId
        self.status = status
        self.createdAt = createdAt
    }
}
