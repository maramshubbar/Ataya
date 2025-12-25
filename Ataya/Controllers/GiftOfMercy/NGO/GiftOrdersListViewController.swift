//
//  GiftOrdersListViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//

import UIKit

final class GiftOrdersListViewController: UIViewController {

    // MARK: - Model
    enum OrderStatus: String, CaseIterable {
        case pending = "Pending"
        case processing = "Processing"
        case sent = "Sent"
        case failed = "Failed"
        case cancelled = "Cancelled"
    }

    struct GiftOrder {
        let id: String
        let giftName: String
        let donorName: String
        let amount: Double?
        let date: Date
        let status: OrderStatus
        let cardDesignName: String
        let recipientsCount: Int
    }

    // MARK: - UI
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

    // MARK: - Data
    private var allOrders: [GiftOrder] = []
    private var filteredOrders: [GiftOrder] = []

    // Brand yellow (F7D44C)
    private let brandYellow = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        setupActions()
        loadMockData()
        applyFilter()
    }

    private func setupNav() {
        view.backgroundColor = .systemBackground
        title = "Orders"
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupUI() {
        // Filter
        filterControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterControl)

        // Table
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

        // Empty state
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
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
    }

    private func setupActions() {
        filterControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
    }

    @objc private func filterChanged() {
        applyFilter()
    }

    @objc private func handleRefresh() {
        // لاحقاً: نعمل fetch من Firestore
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
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
        default: // All
            filteredOrders = allOrders
        }

        emptyStateLabel.isHidden = !filteredOrders.isEmpty
        tableView.reloadData()
    }

    private func loadMockData() {
        allOrders = [
            .init(id: "ORD-1A2B3C",
                  giftName: "WATER WELL",
                  donorName: "Maram",
                  amount: 500,
                  date: Date(),
                  status: .pending,
                  cardDesignName: "Kaaba",
                  recipientsCount: 2),

            .init(id: "ORD-7X9P2Q",
                  giftName: "SADAQAH JARIYA",
                  donorName: "Fatema",
                  amount: 20,
                  date: Date().addingTimeInterval(-86400 * 2),
                  status: .sent,
                  cardDesignName: "Floral",
                  recipientsCount: 1),

            .init(id: "ORD-ZZ5521",
                  giftName: "Orphan Care",
                  donorName: "Ahmed",
                  amount: 15,
                  date: Date().addingTimeInterval(-86400 * 6),
                  status: .processing,
                  cardDesignName: "Palestine Al Aqsa",
                  recipientsCount: 3),
        ]
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

        let amountText = order.amount.map { String(format: "$%.2f", $0) } ?? "—"
        let dateText = order.date.formatted(date: .abbreviated, time: .omitted)

        cell.configure(
            giftName: order.giftName,
            donorName: order.donorName,
            amountText: amountText,
            dateText: dateText,
            statusText: order.status.rawValue,
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

    private func openDetails(order: GiftOrder) {
        let vc = GiftOrderDetailsViewController()
        vc.order = order
        navigationController?.pushViewController(vc, animated: true)
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

    private let brandYellow = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1)

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

        // Card مثل التصميم (بدون شادو قوي)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.systemGray4.cgColor

        contentView.addSubview(card)

        // Labels
        [titleLabel, donorLabel, amountLabel, dateLabel, designLabel, recipientsLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.numberOfLines = 1
        }

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        donorLabel.font = .systemFont(ofSize: 13.5, weight: .regular)
        donorLabel.textColor = .label   // أغمق

        amountLabel.font = .systemFont(ofSize: 13.5, weight: .regular)
        amountLabel.textColor = .label

        dateLabel.font = .systemFont(ofSize: 13.5, weight: .regular)
        dateLabel.textColor = .label

        designLabel.font = .systemFont(ofSize: 13.5, weight: .regular)
        designLabel.textColor = .label

        recipientsLabel.font = .systemFont(ofSize: 13, weight: .regular)
        recipientsLabel.textColor = .secondaryLabel // رمادي فاتح

        badge.translatesAutoresizingMaskIntoConstraints = false

        viewButton.translatesAutoresizingMaskIntoConstraints = false
        viewButton.setTitle("View Details", for: .normal)
        viewButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        viewButton.setTitleColor(.black, for: .normal)
        viewButton.backgroundColor = brandYellow
        viewButton.layer.cornerRadius = 10
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = brandYellow    // اللون الأصفر
            config.baseForegroundColor = .black         // لون النص
            config.cornerStyle = .medium                // تقريباً radius = 10
            config.contentInsets = NSDirectionalEdgeInsets(top: 10,
                                                           leading: 22,
                                                           bottom: 10,
                                                           trailing: 22)
            viewButton.configuration = config
        } else {
            viewButton.backgroundColor = brandYellow
            viewButton.setTitleColor(.black, for: .normal)
            viewButton.layer.cornerRadius = 10
            viewButton.contentEdgeInsets = UIEdgeInsets(top: 10,
                                                        left: 22,
                                                        bottom: 10,
                                                        right: 22)
        }
        viewButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)

        card.addSubview(titleLabel)
        card.addSubview(donorLabel)
        card.addSubview(amountLabel)
        card.addSubview(dateLabel)
        card.addSubview(designLabel)
        card.addSubview(recipientsLabel)
        card.addSubview(badge)
        card.addSubview(viewButton)

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

        init(from status: GiftOrdersListViewController.OrderStatus) {
            let pendingBg   = UIColor(red: 1.0, green: 0.95, blue: 0.70, alpha: 1)  // أصفر فاتح
            let approvedBg  = UIColor(red: 0.82, green: 0.95, blue: 0.80, alpha: 1) // أخضر فاتح
            let blueBg      = UIColor(red: 0.82, green: 0.90, blue: 1.0, alpha: 1)  // أزرق فاتح
            let redBg       = UIColor(red: 1.0, green: 0.85, blue: 0.85, alpha: 1)  // أحمر فاتح
            let grayBg      = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1) // رمادي فاتح

            switch status {
            case .pending:
                bg = pendingBg
                text = .black
            case .sent:
                bg = approvedBg
                text = .black
            case .processing:
                bg = blueBg
                text = .black
            case .failed:
                bg = redBg
                text = .black
            case .cancelled:
                bg = grayBg
                text = .black
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

// MARK: - Badge View
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
        clipsToBounds = true   // بدون border

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
