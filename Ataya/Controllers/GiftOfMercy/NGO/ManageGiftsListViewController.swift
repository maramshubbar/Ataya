//
//  ManageGiftsListViewController.swift
//  Ataya
//
//  Created by Maram on 25/12/2025.
//

import UIKit

// MARK: - Model

struct Gift {
    enum Pricing {
        case fixed(amount: Decimal)
        case custom
    }

    var id: String
    var title: String
    var pricing: Pricing
    var description: String
    var imageName: String       // اسم الصورة من الـ Assets
    var isActive: Bool          // نستخدمه في شاشة Add/Edit فقط

    init(id: String = UUID().uuidString,
         title: String,
         pricing: Pricing,
         description: String,
         imageName: String,
         isActive: Bool = true) {
        self.id = id
        self.title = title
        self.pricing = pricing
        self.description = description
        self.imageName = imageName
        self.isActive = isActive
    }
}

// MARK: - VC

final class ManageGiftsListViewController: UIViewController {

    private let addButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)

    // مؤقتاً: داتا تجريبية (لاحقاً من Firestore)
    private var gifts: [Gift] = [
        Gift(
            title: "Water Well",
            pricing: .fixed(amount: 500),
            description: "Provide clean water to communities in need.",
            imageName: "water_well_heart", 
            isActive: true
        ),
        Gift(
            title: "Sadaqah Jariya",
            pricing: .custom,
            description: "Ongoing charity with continuous rewards.",
            imageName: "heart_sadaqah",
            isActive: true
        ),
        Gift(
            title: "Orphan Care",
            pricing: .custom,
            description: "Support orphans with education and essentials.",
            imageName: "heart_orphan_care",
            isActive: false
        )
    ]

    // لكتابة المبلغ بصيغة عملة
    private let amountFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        // لو تبين دايماً BHD:
        f.currencyCode = "BHD"
        return f
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
    }

    // MARK: - Nav

    private func setupNav() {
        title = "Manage Gifts"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
    }

    // MARK: - UI

    private func setupUI() {
        // زر Add Gift
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setTitle("Add Gift", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.backgroundColor = UIColor(atayaHex: "F7D44C")
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        addButton.layer.cornerRadius = 14
        addButton.addTarget(self, action: #selector(addGiftTapped), for: .touchUpInside)

        // الجدول
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
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
        let vc = AddEditGiftViewController(existingGift: nil)

        vc.onSave = { [weak self] newGift in
            guard let self = self else { return }
            self.gifts.append(newGift)
            self.tableView.reloadData()
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    private func handleEdit(_ gift: Gift) {
        let vc = AddEditGiftViewController(existingGift: gift)

        vc.onSave = { [weak self] updated in
            guard let self = self else { return }

            if let idx = self.gifts.firstIndex(where: { $0.id == updated.id }) {
                self.gifts[idx] = updated
                self.tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
            }
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    // يكتب سطر السعر مثل:
    // "BHD 500.00 (Fixed)" أو "Custom amount"
    private func priceLine(for gift: Gift) -> String {
        switch gift.pricing {
        case .custom:
            return "Custom amount"
        case .fixed(let amount):
            let ns = amount as NSDecimalNumber
            let text = amountFormatter.string(from: ns) ?? "BHD \(ns)"
            return "\(text) (Fixed)"
        }
    }
}

// MARK: - Table

extension ManageGiftsListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        gifts.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let gift = gifts[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: GiftManagementCell.reuseID,
            for: indexPath
        ) as! GiftManagementCell

        let vm = GiftManagementCell.ViewModel(
            title: gift.title,
            priceLine: priceLine(for: gift),
            description: gift.description,
            imageName: gift.imageName
        )

        cell.configure(with: vm)

        cell.onEdit = { [weak self] in
            self?.handleEdit(gift)
        }

        return cell
    }
}
