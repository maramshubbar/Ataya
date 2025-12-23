import UIKit

// MARK: - In-memory ONLY store (resets when app closes)
final class AddressRuntimeStore {
    var confirmedAddress: AddressModel? = nil
    static let shared = AddressRuntimeStore()
    private init() {}

    var addresses: [AddressModel] = []
    var selectedIndex: Int? = nil

    func canAddNew() -> Bool { addresses.count < 2 }

    func upsert(_ address: AddressModel, at index: Int?) {
        if let i = index, i >= 0, i < addresses.count {
            addresses[i] = address
        } else {
            guard addresses.count < 2 else { return }
            addresses.append(address)
        }
    }
    
    func selectedAddress() -> AddressModel? {
        guard let idx = selectedIndex, idx >= 0, idx < addresses.count else { return nil }
        return addresses[idx]
    }
}

// MARK: - Model (no extra file)
struct AddressModel {
    var title: String
    var fullAddress: String
    var latitude: Double
    var longitude: Double
}

final class MyAddressListTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var addNewAddressButton: UIButton!

    private let store = AddressRuntimeStore.shared
    private let yellow = UIColor(hex: "#FEC400")
    private let yellowBG = UIColor(hex: "#FFFBE7")

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "My Address"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 130

        // ✅ FORCE Add New Address button to work even if storyboard IBAction not connected
        addNewAddressButton.removeTarget(nil, action: nil, for: .touchUpInside)
        addNewAddressButton.addTarget(self, action: #selector(addNewProgrammatic), for: .touchUpInside)

        // ✅ Figma style: rounded yellow border around Add New Address
        styleAddNewAddressButton()

        updateButtons()
        tableView.reloadData()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateButtons()
        tableView.reloadData()
    }

    private func styleAddNewAddressButton() {
        addNewAddressButton.backgroundColor = .clear
        addNewAddressButton.setTitleColor(yellow, for: .normal)
        addNewAddressButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)

        addNewAddressButton.layer.borderWidth = 2
        addNewAddressButton.layer.borderColor = yellow.cgColor
        addNewAddressButton.layer.cornerRadius = 8   // ✅ FIXED: radius = 8
        addNewAddressButton.clipsToBounds = true
    }

    private func updateButtons() {
        let canAdd = store.canAddNew()
        addNewAddressButton.isEnabled = canAdd
        addNewAddressButton.alpha = canAdd ? 1.0 : 0.4

        let canConfirm = (store.selectedIndex != nil) && !store.addresses.isEmpty
        confirmButton.isEnabled = canConfirm
        confirmButton.alpha = canConfirm ? 1.0 : 0.4
    }

    // MARK: - Actions

    @IBAction func confirmTapped(_ sender: UIButton) {
        guard let address = store.selectedAddress() else {
            showAlert("Select Address", "Please select an address first.")
            return
        }

        // ✅ Save confirmed address for END flow
        store.confirmedAddress = address

        // ✅ Go back to previous screen (Pickup Location screen)
        navigationController?.popViewController(animated: true)
    }


    @IBAction func addNewAddressTapped(_ sender: UIButton) {
        guard store.canAddNew() else {
            showAlert("Limit Reached", "You can only save 2 addresses.")
            return
        }
        openDetailsForAdd()
    }

    @objc private func addNewProgrammatic() {
        addNewAddressTapped(addNewAddressButton)
    }

    @objc private func editTapped(_ sender: UIButton) {
        let row = sender.tag - 1000

        // ✅ Select it first (so highlight updates)
        store.selectedIndex = row
        tableView.reloadData()
        updateButtons()

        openDetailsForEdit(row)
    }

    // MARK: - Open Details (NO SEGUES — always works)

    private func openDetailsForAdd() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "MyAddressDetailsViewController") as? MyAddressDetailsViewController else {
            showAlert("Storyboard Error", "Set Details Storyboard ID = MyAddressDetailsViewController")
            return
        }

        vc.editIndex = nil
        vc.existingAddress = nil

        vc.onSaveAddress = { [weak self] saved, editIndex in
            guard let self else { return }
            self.store.upsert(saved, at: editIndex)
            self.store.selectedIndex = self.store.addresses.count - 1
            self.tableView.reloadData()
            self.updateButtons()
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    private func openDetailsForEdit(_ index: Int) {
        guard index >= 0, index < store.addresses.count else { return }

        guard let vc = storyboard?.instantiateViewController(withIdentifier: "MyAddressDetailsViewController") as? MyAddressDetailsViewController else {
            showAlert("Storyboard Error", "Set Details Storyboard ID = MyAddressDetailsViewController")
            return
        }

        vc.editIndex = index
        vc.existingAddress = store.addresses[index]

        vc.onSaveAddress = { [weak self] saved, editIndex in
            guard let self else { return }
            self.store.upsert(saved, at: editIndex)
            self.store.selectedIndex = index
            self.tableView.reloadData()
            self.updateButtons()
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        store.addresses.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        store.selectedIndex = indexPath.row
        tableView.reloadData()
        updateButtons()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "AddressCell")

        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear

        // remove old card view
        cell.contentView.viewWithTag(999)?.removeFromSuperview()

        let item = store.addresses[indexPath.row]
        let isSelected = (indexPath.row == store.selectedIndex)

        // Card container
        let card = UIView()
        card.tag = 999
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 2
        card.layer.borderColor = yellow.cgColor
        card.backgroundColor = isSelected ? yellowBG : .white

        cell.contentView.addSubview(card)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 36),
            card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -36),
            card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 16),
            card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -16),
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])

        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.text = item.title

        // Details
        let detailsLabel = UILabel()
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = .systemFont(ofSize: 13, weight: .regular)
        detailsLabel.textColor = .darkGray
        detailsLabel.numberOfLines = 2
        detailsLabel.text = item.fullAddress

        // Edit Button
        let editButton = UIButton(type: .system)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.tag = 1000 + indexPath.row
        editButton.removeTarget(nil, action: nil, for: .allEvents)
        editButton.addTarget(self, action: #selector(editTapped(_:)), for: .touchUpInside)

        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = "Edit"
            config.baseBackgroundColor = yellow
            config.baseForegroundColor = .black
            config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 18, bottom: 10, trailing: 18)
            config.cornerStyle = .medium
            editButton.configuration = config
        } else {
            editButton.setTitle("Edit", for: .normal)
            editButton.setTitleColor(.black, for: .normal)
            editButton.backgroundColor = yellow
            editButton.layer.cornerRadius = 8
            editButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
        }

        card.addSubview(titleLabel)
        card.addSubview(detailsLabel)
        card.addSubview(editButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),

            detailsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailsLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),

            editButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            editButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])

        return cell
    }

    // MARK: - Popup

    private func showEndPopup(for address: AddressModel) {
        let alert = UIAlertController(
            title: "Pickup Location Confirmed ✅",
            message: "\(address.title)\n\(address.fullAddress)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Done", style: .default))
        present(alert, animated: true)
    }

    private func showAlert(_ title: String, _ message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - UIColor HEX helper
private extension UIColor {
    convenience init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&rgb)
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}

