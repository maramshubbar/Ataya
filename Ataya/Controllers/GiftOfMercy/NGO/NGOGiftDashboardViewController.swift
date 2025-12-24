//
//  NGOGiftDashboardViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//


import UIKit

final class NGOGiftDashboardViewController: UIViewController {

    private var pendingCount = 12
    private var approvedTodayCount = 5
    private var sentTodayCount = 8

    private struct RecentRow {
        let title: String
        let subtitle: String
    }

    private var recent: [RecentRow] = [
        .init(title: "Restore Eyesight in Africa", subtitle: "Approved • 10 min ago"),
        .init(title: "Water Well", subtitle: "Sent • 1 hour ago"),
        .init(title: "Orphan Care", subtitle: "Pending • 2 hours ago"),
        .init(title: "Sadaqah Jariya", subtitle: "Returned • Yesterday"),
        .init(title: "Water Well", subtitle: "Approved • Yesterday")
    ]

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStack = UIStackView()

    // Stats row
    private let statsRow = UIStackView()
    private let cardPending = StatCardView()
    private let cardApproved = StatCardView()
    private let cardSent = StatCardView()

    // Actions
    private let actionsStack = UIStackView()
    private let btnPending = UIButton(type: .system)
    private let btnSent = UIButton(type: .system)

    // Recent
    private let recentTitle = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)

    // Colors
    private let accentYellow = UIColor(atayaHex: "F7D44C")
    private let softGreen    = UIColor(atayaHex: "D9F0E4")

    private let cardBorder = UIColor.black.withAlphaComponent(0.06)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        buildUI()
        applyDummyData()
    }

    private func setupNav() {
        title = "Gift of Mercy"
        view.backgroundColor = .systemBackground

        // Back black (إذا تبين كل الشاشات يكون back أسود)
        navigationController?.navigationBar.tintColor = .black
        navigationItem.largeTitleDisplayMode = .never
    }

    private func buildUI() {
        // Scroll
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Main stack
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.alignment = .fill
        mainStack.distribution = .fill

        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        // ✅ 1) Stats Row
        statsRow.axis = .horizontal
        statsRow.spacing = 12
        statsRow.distribution = .fillEqually

        cardPending.configureStatic(title: "Pending", value: "0", accent: .systemGreen)
        cardApproved.configureStatic(title: "Approved Today", value: "0", accent: .systemBlue)
        cardSent.configureStatic(title: "Sent Today", value: "0", accent: .systemOrange)

        [cardPending, cardApproved, cardSent].forEach { card in
            card.layer.borderWidth = 1
            card.layer.borderColor = cardBorder.cgColor
            card.layer.cornerRadius = 16
            card.clipsToBounds = true
            card.backgroundColor = .white
        }

        statsRow.addArrangedSubview(cardPending)
        statsRow.addArrangedSubview(cardApproved)
        statsRow.addArrangedSubview(cardSent)

        // ✅ 2) Actions
        actionsStack.axis = .vertical
        actionsStack.spacing = 12

        styleActionButton(btnPending, title: "View Pending Requests", bg: UIColor.systemGreen.withAlphaComponent(0.12), titleColor: .systemGreen)
        styleActionButton(btnSent, title: "Sent Certificates", bg: accentYellow.withAlphaComponent(0.35), titleColor: .black)

        btnPending.addTarget(self, action: #selector(pendingTapped), for: .touchUpInside)
        btnSent.addTarget(self, action: #selector(sentTapped), for: .touchUpInside)

        actionsStack.addArrangedSubview(btnPending)
        actionsStack.addArrangedSubview(btnSent)

        // ✅ 3) Recent title
        recentTitle.text = "Recent activity"
        recentTitle.font = .systemFont(ofSize: 18, weight: .bold)
        recentTitle.textColor = .label

        // ✅ 4) Table
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = cardBorder.cgColor

        // height ثابت عشان داخل scroll
        let tableHeight: CGFloat = 280
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: tableHeight)
        ])

        // Add to stack
        mainStack.addArrangedSubview(statsRow)
        mainStack.addArrangedSubview(actionsStack)
        mainStack.addArrangedSubview(recentTitle)
        mainStack.addArrangedSubview(tableView)
    }

    private func styleActionButton(_ button: UIButton, title: String, bg: UIColor, titleColor: UIColor) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = bg
        button.setTitleColor(titleColor, for: .normal)
        button.contentHorizontalAlignment = .center
        button.layer.cornerRadius = 16
        var cfg = button.configuration ?? UIButton.Configuration.plain()
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        button.configuration = cfg
    }

    private func applyDummyData() {
        cardPending.updateValue("\(pendingCount)")
        cardApproved.updateValue("\(approvedTodayCount)")
        cardSent.updateValue("\(sentTodayCount)")
        tableView.reloadData()
    }

    // MARK: - Actions (UI only)
    @objc private func pendingTapped() {
        print("Go to Pending Requests (Screen 2)")
        let vc = NGORequestReceivedViewController()
        navigationController?.pushViewController(vc, animated: true)
    }


    @objc private func sentTapped() {
        print("Go to Sent Certificates (Screen 4)")
        navigationController?.pushViewController(NGOGiftTemplatesViewController(), animated: true)

    }
}

// MARK: - UITableView
extension NGOGiftDashboardViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recent.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "recentCell")

        let row = recent[indexPath.row]
        cell.textLabel?.text = row.title
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .semibold)

        cell.detailTextLabel?.text = row.subtitle
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Small Stat Card View
final class StatCardView: UIView {

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let dot = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }

    private func build() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .secondaryLabel

        valueLabel.font = .systemFont(ofSize: 22, weight: .heavy)
        valueLabel.textColor = .label

        dot.layer.cornerRadius = 5
        dot.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 10),
            dot.heightAnchor.constraint(equalToConstant: 10)
        ])

        let topRow = UIStackView(arrangedSubviews: [dot, titleLabel])
        topRow.axis = .horizontal
        topRow.spacing = 8
        topRow.alignment = .center

        stack.addArrangedSubview(topRow)
        stack.addArrangedSubview(valueLabel)

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -14)
        ])
    }

    func configureStatic(title: String, value: String, accent: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        dot.backgroundColor = accent
    }

    func updateValue(_ value: String) {
        valueLabel.text = value
    }
}
