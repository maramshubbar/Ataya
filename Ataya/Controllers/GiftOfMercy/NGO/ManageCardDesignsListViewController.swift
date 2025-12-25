//
//  ManageCardDesignsListViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//

import UIKit

// MARK: - VC

final class ManageCardDesignsListViewController: UIViewController {

    private let addButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)

    // مبدئياً: داتا ثابتة
    private var designs: [CardDesign] = [
        CardDesign(id: "d1", name: "Kaaba",             imageName: "c1", isActive: true,  isDefault: true),
        CardDesign(id: "d2", name: "Palestine Al Aqsa", imageName: "c2", isActive: true,  isDefault: false),
        CardDesign(id: "d3", name: "Floral",            imageName: "c3", isActive: false, isDefault: false),
        CardDesign(id: "d4", name: "Water",             imageName: "c4", isActive: true,  isDefault: false)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
    }

    private func setupNav() {
        title = "Card Designs"
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupUI() {
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setTitle("Add Design", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.backgroundColor = color(hex: "F7D44C")
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        addButton.layer.cornerRadius = 14
        addButton.addTarget(self, action: #selector(addDesignTapped), for: .touchUpInside)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        tableView.register(CardDesignManagementCell.self,
                           forCellReuseIdentifier: CardDesignManagementCell.reuseID)

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

    @objc private func addDesignTapped() {
        // ✅ نفتح شاشة Add/Edit الصحيحة (مو AddEditGiftViewController)
        let vc = AddEditCardDesignViewController(existingDesign: nil)

        vc.onSave = { [weak self] newDesign in
            guard let self = self else { return }
            self.designs.append(newDesign)
            self.tableView.reloadData()
            // بعدين: هنا تسوين save في Firestore
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    private func handleEdit(at index: Int) {
        let design = designs[index]

        let vc = AddEditCardDesignViewController(existingDesign: design)

        vc.onSave = { [weak self] updated in
            guard let self = self else { return }
            self.designs[index] = updated
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            // بعدين: update Firestore
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    private func handlePreview(at index: Int) {
        let design = designs[index]
        let vc = CardDesignPreviewViewController(design: design)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func handleToggleActive(at index: Int, isOn: Bool) {
        designs[index].isActive = isOn
        // بعدين: update Firestore
    }

    // نفس الهيلبر المعتاد
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

// MARK: - Table

extension ManageCardDesignsListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        designs.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let design = designs[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CardDesignManagementCell.reuseID,
            for: indexPath
        ) as! CardDesignManagementCell

        cell.configure(with: design)

        cell.onEdit = { [weak self] in
            self?.handleEdit(at: indexPath.row)
        }
        cell.onPreview = { [weak self] in
            self?.handlePreview(at: indexPath.row)
        }

        return cell
    }
}
