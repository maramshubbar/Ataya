//
//  NGOPendingRequestsViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//


import UIKit

final class NGORequestReceivedViewController: UIViewController {

    // MARK: - Local color helper (بدون UIColor(hex:))
    private func color(hex: String, alpha: CGFloat = 1) -> UIColor {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6 else { return .systemYellow.withAlphaComponent(alpha) }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }

    private lazy var accentYellow = color(hex: "F7D44C")

    // MARK: - Dummy Data (UI only)
    private var allItems: [PendingRequest] = [
        .init(id: "REQ-1001", giftName: "Restore Eyesight in Africa", amountText: "$20",  fromName: "Maram",  toEmail: "user1@mail.com", timeText: "10 min ago", cardDesign: "Kaaba"),
        .init(id: "REQ-1002", giftName: "Water Well",                  amountText: "$500", fromName: "Fatema", toEmail: "user2@mail.com", timeText: "25 min ago", cardDesign: "Palestine Al Aqsa"),
        .init(id: "REQ-1003", giftName: "Orphan Care",                 amountText: "$15",  fromName: "Noor",   toEmail: "user3@mail.com", timeText: "1 hour ago",  cardDesign: "Floral"),
        .init(id: "REQ-1004", giftName: "Sadaqah Jariya",              amountText: "$10",  fromName: "Aisha",  toEmail: "user4@mail.com", timeText: "2 hours ago", cardDesign: "Water")
    ]

    private var filtered: [PendingRequest] = []

    // MARK: - UI
    private let searchBar = UISearchBar()
    private let countLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        buildUI()
        applyData()
    }

    private func setupNav() {
        title = "Pending requests"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .black
        navigationItem.largeTitleDisplayMode = .never
    }

    private func buildUI() {
        // Search
        searchBar.placeholder = "Search gift / name / email"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self

        // Count
        countLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        countLabel.textColor = .secondaryLabel

        // Table
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 118
        tableView.register(PendingRequestCell.self, forCellReuseIdentifier: PendingRequestCell.reuseID)

        let topStack = UIStackView(arrangedSubviews: [searchBar, countLabel])
        topStack.axis = .vertical
        topStack.spacing = 8

        view.addSubview(topStack)
        view.addSubview(tableView)
        topStack.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor) // ✅ ما يضغط تحت
        ])
    }

    private func applyData() {
        filtered = allItems
        countLabel.text = "\(filtered.count) request(s)"
        tableView.reloadData()
    }

    private func applySearch(_ text: String) {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty {
            filtered = allItems
        } else {
            filtered = allItems.filter {
                $0.giftName.lowercased().contains(q) ||
                $0.fromName.lowercased().contains(q) ||
                $0.toEmail.lowercased().contains(q) ||
                $0.id.lowercased().contains(q) ||
                $0.cardDesign.lowercased().contains(q)
            }
        }
        countLabel.text = "\(filtered.count) request(s)"
        tableView.reloadData()
    }

    private func openDetails(_ item: PendingRequest) {
        let vc = NGOPendingRequestDetailsViewController(request: item)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Table
extension NGORequestReceivedViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { filtered.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PendingRequestCell.reuseID, for: indexPath) as! PendingRequestCell
        let item = filtered[indexPath.row]
        cell.configure(item: item, accent: accentYellow)

        cell.onOpenTapped = { [weak self] in
            self?.openDetails(item)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openDetails(filtered[indexPath.row])
    }
}

// MARK: - Search
extension NGORequestReceivedViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applySearch(searchText)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

// MARK: - Cell
final class PendingRequestCell: UITableViewCell {

    static let reuseID = "PendingRequestCell"

    var onOpenTapped: (() -> Void)?

    private let card = UIView()
    private let titleLabel = UILabel()
    private let subLabel = UILabel()
    private let metaLabel = UILabel()

    private let openButton = UIButton(type: .system)
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        build()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }

    private func build() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
        card.clipsToBounds = true

        // shadow
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 10
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        card.layer.masksToBounds = false

        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2

        subLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subLabel.textColor = .secondaryLabel
        subLabel.numberOfLines = 2

        metaLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        metaLabel.textColor = .secondaryLabel
        metaLabel.numberOfLines = 1

        openButton.setTitle("Open request", for: .normal)
        openButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        openButton.contentHorizontalAlignment = .leading
        openButton.addTarget(self, action: #selector(openTapped), for: .touchUpInside)

        chevron.contentMode = .scaleAspectFit

        contentView.addSubview(card)
        [titleLabel, subLabel, metaLabel, openButton, chevron].forEach {
            card.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        card.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            subLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            subLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            metaLabel.topAnchor.constraint(equalTo: subLabel.bottomAnchor, constant: 8),
            metaLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            metaLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            openButton.topAnchor.constraint(equalTo: metaLabel.bottomAnchor, constant: 12),
            openButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            openButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),

            chevron.centerYAnchor.constraint(equalTo: openButton.centerYAnchor),
            chevron.leadingAnchor.constraint(equalTo: openButton.trailingAnchor, constant: 8),
            chevron.widthAnchor.constraint(equalToConstant: 14),
            chevron.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    func configure(item: PendingRequest, accent: UIColor) {
        titleLabel.text = "\(item.giftName) \(item.amountText)"
        subLabel.text = "From: \(item.fromName)\nTo: \(item.toEmail)"
        metaLabel.text = "\(item.id) • \(item.cardDesign) • \(item.timeText)"

        openButton.setTitleColor(accent, for: .normal)
        chevron.tintColor = accent
    }

    @objc private func openTapped() { onOpenTapped?() }
}
