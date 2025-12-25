//
//  ManageGiftsListViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//

import UIKit

struct GiftDefinition {
    var id: String
    var name: String
    var description: String
    var pricingType: PricingType
    var isActive: Bool

    enum PricingType {
        case fixed(amount: Double)
        case custom
    }
}


final class ManageGiftsListViewController: UIViewController {

    private let addButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)

    private var gifts: [GiftDefinition] = [
        .init(
            id: "g1",
            name: "Water Well",
            description: "Provide clean water to communities in need.",
            pricingType: .fixed(amount: 500),
            isActive: true
        ),
        .init(
            id: "g2",
            name: "Sadaqah Jariya",
            description: "Ongoing charity with continuous rewards.",
            pricingType: .custom,
            isActive: true
        ),
        .init(
            id: "g3",
            name: "Orphan Care",
            description: "Support orphans with education and essentials.",
            pricingType: .custom,
            isActive: false
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
    }

    private func setupNav() {
        title = "Manage Gifts"
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupUI() {
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setTitle("Add Gift", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.backgroundColor = color(hex: "F7D44C")
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        addButton.layer.cornerRadius = 14
        addButton.addTarget(self, action: #selector(addGiftTapped), for: .touchUpInside)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        tableView.register(GiftManagementCell.self,
                           forCellReuseIdentifier: GiftManagementCell.reuseID)

        view.addSubview(addButton)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 50),

            tableView.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Actions

    @objc private func addGiftTapped() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = sb.instantiateViewController(
            withIdentifier: "AddEditGiftViewController"
        ) as? AddEditGiftViewController else {
            assertionFailure("AddEditGiftViewController not found in storyboard")
            return
        }

        // ✅ لو عندك مود داخل AddEditGiftViewController خليه create
        // مثال:
        // vc.mode = .create

        navigationController?.pushViewController(vc, animated: true)
    }

    private func handleEditGift(_ gift: GiftDefinition) {
        let alert = UIAlertController(
            title: "Edit Gift",
            message: "Edit \(gift.name)?",
            preferredStyle: .alert
        )

        let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            guard let self = self else { return }

            let sb = UIStoryboard(name: "Main", bundle: nil)
            guard let vc = sb.instantiateViewController(
                withIdentifier: "AddEditGiftViewController"
            ) as? AddEditGiftViewController else {
                assertionFailure("AddEditGiftViewController not found in storyboard")
                return
            }

            // ✅ مرري البيانات عشان التعديل
            // على حسب البروبرتي اللي عندك هناك:
            // vc.giftToEdit = gift
            // أو:
            // vc.mode = .edit(existing: gift)

            self.navigationController?.pushViewController(vc, animated: true)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(editAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    private func handleViewGift(_ gift: GiftDefinition) {
        let alert = UIAlertController(
            title: gift.name,
            message: gift.description,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }

    private func handleToggleActive(at index: Int, isOn: Bool) {
        gifts[index].isActive = isOn
    }

    // لون hex بسيط
    private func color(hex: String, alpha: CGFloat = 1) -> UIColor {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6 else { return .gray }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}

// MARK: - Table DataSource / Delegate

extension ManageGiftsListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        gifts.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let gift = gifts[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: GiftManagementCell.reuseID,
            for: indexPath
        ) as! GiftManagementCell

        cell.configure(with: gift)

        cell.onEdit = { [weak self] in
            self?.handleEditGift(gift)
        }

        cell.onView = { [weak self] in
            self?.handleViewGift(gift)
        }

        cell.onToggleActive = { [weak self] isOn in
            self?.handleToggleActive(at: indexPath.row, isOn: isOn)
        }

        return cell
    }
}
