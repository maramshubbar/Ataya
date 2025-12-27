// FILE: ManageGiftsListViewController.swift

import UIKit
import FirebaseFirestore
import FirebaseAuth

final class ManageGiftsListViewController: UIViewController {

    private let addButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)

    private var gifts: [Gift] = []
    private var listener: ListenerRegistration?

    private let amountFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        f.currencyCode = "BHD"
        return f
    }()

    // ✅ NGO id = current Firebase Auth user id
    private var currentNgoId: String? {
        Auth.auth().currentUser?.uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        startListening()
    }

    deinit { listener?.remove() }

    private func setupNav() {
        title = "Manage Gifts"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
    }

    private func setupUI() {
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setTitle("Add Gift", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.backgroundColor = UIColor(atayaHex: "F7D44C")
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        addButton.layer.cornerRadius = 14
        addButton.addTarget(self, action: #selector(addGiftTapped), for: .touchUpInside)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(GiftManagementCell.self, forCellReuseIdentifier: GiftManagementCell.reuseID)

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

    private func startListening() {
        listener?.remove()

        listener = GiftService.shared.listenGifts(ngoId: currentNgoId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let err):
                print("❌ Gifts listen error:", err.localizedDescription)

            case .success(let items):
                self.gifts = items.sorted {
                    ($0.createdAt?.dateValue() ?? .distantPast) > ($1.createdAt?.dateValue() ?? .distantPast)
                }
                self.tableView.reloadData()
            }
        }
    }

    @objc private func addGiftTapped() {
        let vc = AddEditGiftViewController(existingGift: nil)

        vc.onSave = { [weak self] newGift in
            guard let self else { return }

            var g = newGift
            if g.ngoId == nil { g.ngoId = self.currentNgoId }

            GiftService.shared.upsertGift(g) { err in
                if let err { print("❌ Save gift error:", err.localizedDescription) }
            }
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    private func handleEdit(_ gift: Gift) {
        let vc = AddEditGiftViewController(existingGift: gift)

        vc.onSave = { [weak self] updated in
            guard let self else { return }

            var g = updated
            if g.ngoId == nil { g.ngoId = self.currentNgoId }

            GiftService.shared.upsertGift(g) { err in
                if let err { print("❌ Update gift error:", err.localizedDescription) }
            }
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    private func priceLine(for gift: Gift) -> String {
        switch gift.pricingMode {
        case .custom:
            return "Custom amount"
        case .fixed:
            let amount = gift.fixedAmount ?? 0
            let text = amountFormatter.string(from: NSNumber(value: amount)) ?? "BHD \(amount)"
            return "\(text) (Fixed)"
        }
    }
}

extension ManageGiftsListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        gifts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let gift = gifts[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: GiftManagementCell.reuseID,
            for: indexPath
        ) as! GiftManagementCell

        // ✅ imageName now carries the URL (no placeholder)
        let vm = GiftManagementCell.ViewModel(
            title: gift.title,
            priceLine: priceLine(for: gift),
            description: gift.description,
            imageName: gift.displayImageName
        )

        cell.configure(with: vm)

        cell.onEdit = { [weak self] in
            self?.handleEdit(gift)
        }

        return cell
    }
}
