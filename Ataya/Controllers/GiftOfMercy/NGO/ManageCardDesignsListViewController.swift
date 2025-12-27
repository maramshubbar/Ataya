import UIKit
import FirebaseFirestore

final class ManageCardDesignsListViewController: UIViewController {

    private let addButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)

    private var designs: [CardDesign] = []
    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        startListening()
    }

    deinit { listener?.remove() }

    private func setupNav() {
        title = "Card Designs"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
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

    private func startListening() {
        listener?.remove()

        // إذا تبين تربطينها بـ NGO معيّن لاحقًا: مرري ngoId
        listener = CardDesignService.shared.listenDesigns(ngoId: nil) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let err):
                print("❌ Card designs listen error:", err.localizedDescription)
            case .success(let items):
                self.designs = items
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Actions

    @objc private func addDesignTapped() {
        let vc = AddEditCardDesignViewController(existingDesign: nil)

        vc.onSave = { newDesign in
            CardDesignService.shared.upsertDesign(newDesign) { err in
                if let err { print("❌ Save design error:", err.localizedDescription); return }

                // إذا المستخدم اختار Default = true
                if newDesign.isDefault {
                    CardDesignService.shared.setDefault(designId: newDesign.id) { err in
                        if let err { print("❌ Set default error:", err.localizedDescription) }
                    }
                }
            }
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    private func handleEdit(at index: Int) {
        let design = designs[index]
        let vc = AddEditCardDesignViewController(existingDesign: design)

        vc.onSave = { updated in
            CardDesignService.shared.upsertDesign(updated) { err in
                if let err { print("❌ Update design error:", err.localizedDescription); return }

                if updated.isDefault {
                    CardDesignService.shared.setDefault(designId: updated.id) { err in
                        if let err { print("❌ Set default error:", err.localizedDescription) }
                    }
                }
            }
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    private func handlePreview(at index: Int) {
        let design = designs[index]
        let vc = CardDesignPreviewViewController(design: design)
        navigationController?.pushViewController(vc, animated: true)
    }

    // helper
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
