////
////  RecurringMyAddressListTableViewController.swift
////  Ataya
////
////  Created by Zahraa Ahmed on 02/01/2026.
////
//
//import UIKit
//
//final class RecurringMyAddressListTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//
//    // MARK: - Outlets
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var confirmButton: UIButton!
//    @IBOutlet weak var addNewAddressButton: UIButton!
//
//    // MARK: - Flow Data
//    var draft: DraftDonation?
//
//    // MARK: - Store
//    private let store = AddressRuntimeStore.shared
//
//    // MARK: - Styling
//    private let yellow = UIColor(hex: "#F7D44C")
//    private let yellowBG = UIColor(hex: "#FFFBE7")
//    private let grayBorder = UIColor(hex: "#B8B8B8")
//
//    // MARK: - Storyboard (Recurring Location Flow)
//    private let flowSB = UIStoryboard(name: "Main", bundle: nil)
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        title = "My Address"
//        hidesBottomBarWhenPushed = true
//
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.tableFooterView = UIView()
//        tableView.separatorStyle = .none
//        tableView.backgroundColor = .clear
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 130
//
//        addNewAddressButton.removeTarget(nil, action: nil, for: .allEvents)
//        addNewAddressButton.addTarget(self, action: #selector(addNewProgrammatic), for: .touchUpInside)
//
//        confirmButton.removeTarget(nil, action: nil, for: .allEvents)
//        confirmButton.addTarget(self, action: #selector(confirmTappedProgrammatic), for: .touchUpInside)
//
//        styleAddNewAddressButton()
//        updateButtons()
//        tableView.reloadData()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        updateButtons()
//        tableView.reloadData()
//        tabBarController?.tabBar.isHidden = true
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        tabBarController?.tabBar.isHidden = false
//    }
//
//    // MARK: - UI
//    private func styleAddNewAddressButton() {
//        addNewAddressButton.backgroundColor = .clear
//        addNewAddressButton.setTitleColor(yellow, for: .normal)
//        addNewAddressButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
//        addNewAddressButton.layer.borderWidth = 2
//        addNewAddressButton.layer.borderColor = yellow.cgColor
//        addNewAddressButton.layer.cornerRadius = 8
//        addNewAddressButton.clipsToBounds = true
//    }
//
//    private func updateButtons() {
//        let canAdd = store.canAddNew()
//        addNewAddressButton.isEnabled = canAdd
//        addNewAddressButton.alpha = canAdd ? 1.0 : 0.4
//
//        let canConfirm = (store.selectedIndex != nil) && !store.addresses.isEmpty
//        confirmButton.isEnabled = canConfirm
//        confirmButton.alpha = canConfirm ? 1.0 : 0.4
//    }
//
//    // MARK: - Actions
//    @IBAction func addNewAddressTapped(_ sender: UIButton) {
//        guard store.canAddNew() else {
//            showAlert("Limit Reached", "You can only save 2 addresses.")
//            return
//        }
//        openDetailsForAdd()
//    }
//
//    @objc private func addNewProgrammatic() {
//        addNewAddressTapped(addNewAddressButton)
//    }
//
//    @objc private func confirmTappedProgrammatic() {
//
//        guard let draft = self.draft else {
//            showAlert("Error", "Draft is missing. Go back and try again.")
//            return
//        }
//
//        guard let address = store.selectedAddress() else {
//            showAlert("Select Address", "Please select an address first.")
//            return
//        }
//
//        draft.pickupMethod = "myAddress"
//        draft.pickupAddress = address
//
//        confirmButton.isEnabled = false
//        confirmButton.alpha = 0.5
//
//        // Demo-safe auth gate + save
//        AuthGate.ensureLoggedIn { [weak self] ok in
//            guard let self else { return }
//
//            DonationDraftSaver.shared.saveAfterPickup(draft: draft) { [weak self] error in
//                guard let self else { return }
//
//                self.confirmButton.isEnabled = true
//                self.confirmButton.alpha = 1.0
//
//                // Demo fallback: show popup even if not logged in
//                if !ok {
//                    self.store.confirmedAddress = address
//                    self.presentThankYouPopup()
//                    return
//                }
//
//                if let error {
//                    self.showAlert("Save failed", error.localizedDescription)
//                    return
//                }
//
//                self.store.confirmedAddress = address
//                self.presentThankYouPopup()
//            }
//        }
//    }
//
//    @objc private func editTapped(_ sender: UIButton) {
//        let row = sender.tag - 1000
//        store.selectedIndex = row
//        tableView.reloadData()
//        updateButtons()
//        openDetailsForEdit(row)
//    }
//
//    // MARK: - Navigation (Recurring Flow)
//    private func presentThankYouPopup() {
//        guard let popup = flowSB.instantiateViewController(withIdentifier: "RCL_PopupVC") as? RecurringPopupConfirmPickupViewController else {
//            showAlert("Storyboard Error", "In Main.storyboard set Storyboard ID = RCL_PopupVC")
//            return
//        }
//
//        popup.isModalInPresentation = true
//        popup.modalPresentationStyle = .overFullScreen
//        popup.modalTransitionStyle = .crossDissolve
//        present(popup, animated: true)
//    }
//
//    private func openDetailsForAdd() {
//        guard let vc = flowSB.instantiateViewController(withIdentifier: "RCL_AddressDetailsVC") as? MyAddressDetailsViewController else {
//            showAlert("Storyboard Error", "In Main.storyboard set Storyboard ID = RCL_AddressDetailsVC")
//            return
//        }
//
//        vc.editIndex = nil
//        vc.existingAddress = nil
//
//        vc.onSaveAddress = { [weak self] saved, editIndex in
//            guard let self else { return }
//            self.store.upsert(saved, at: editIndex)
//            self.store.selectedIndex = self.store.addresses.count - 1
//            self.tableView.reloadData()
//            self.updateButtons()
//        }
//
//        navigationController?.pushViewController(vc, animated: true)
//    }
//
//    private func openDetailsForEdit(_ index: Int) {
//        guard index >= 0, index < store.addresses.count else { return }
//
//        guard let vc = flowSB.instantiateViewController(withIdentifier: "RCL_AddressDetailsVC") as? MyAddressDetailsViewController else {
//            showAlert("Storyboard Error", "In RecurringLocation.storyboard set Storyboard ID = RCL_AddressDetailsVC")
//            return
//        }
//
//        vc.editIndex = index
//        vc.existingAddress = store.addresses[index]
//
//        vc.onSaveAddress = { [weak self] saved, editIndex in
//            guard let self else { return }
//            self.store.upsert(saved, at: editIndex)
//            self.store.selectedIndex = index
//            self.tableView.reloadData()
//            self.updateButtons()
//        }
//
//        navigationController?.pushViewController(vc, animated: true)
//    }
//
//    // MARK: - TableView DataSource / Delegate
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        store.addresses.count
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        store.selectedIndex = indexPath.row
//        tableView.reloadData()
//        updateButtons()
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell")
//            ?? UITableViewCell(style: .default, reuseIdentifier: "AddressCell")
//
//        cell.selectionStyle = .none
//        cell.backgroundColor = .clear
//        cell.contentView.backgroundColor = .clear
//
//        cell.contentView.viewWithTag(999)?.removeFromSuperview()
//
//        let item = store.addresses[indexPath.row]
//        let isSelected = (indexPath.row == store.selectedIndex)
//
//        let card = UIView()
//        card.tag = 999
//        card.translatesAutoresizingMaskIntoConstraints = false
//        card.layer.cornerRadius = 12
//        card.layer.masksToBounds = false
//
//        card.layer.borderWidth = 2
//        card.layer.borderColor = (isSelected ? yellow : grayBorder).cgColor
//        card.backgroundColor = (isSelected ? yellowBG : .white)
//
//        card.layer.shadowColor = UIColor.black.cgColor
//        card.layer.shadowOpacity = 0.10
//        card.layer.shadowRadius = 6
//        card.layer.shadowOffset = CGSize(width: 0, height: 2)
//
//        cell.contentView.addSubview(card)
//
//        NSLayoutConstraint.activate([
//            card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 36),
//            card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -36),
//            card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 16),
//            card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -16),
//            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
//        ])
//
//        let titleLabel = UILabel()
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
//        titleLabel.textColor = .black
//        titleLabel.text = item.title
//
//        let detailsLabel = UILabel()
//        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
//        detailsLabel.font = .systemFont(ofSize: 13, weight: .regular)
//        detailsLabel.textColor = .darkGray
//        detailsLabel.numberOfLines = 2
//        detailsLabel.text = item.fullAddress
//
//        let editButton = UIButton(type: .system)
//        editButton.translatesAutoresizingMaskIntoConstraints = false
//        editButton.tag = 1000 + indexPath.row
//        editButton.removeTarget(nil, action: nil, for: .allEvents)
//        editButton.addTarget(self, action: #selector(editTapped(_:)), for: .touchUpInside)
//
//        if #available(iOS 15.0, *) {
//            var config = UIButton.Configuration.filled()
//            config.title = "Edit"
//            config.baseBackgroundColor = yellow
//            config.baseForegroundColor = .black
//            config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 18, bottom: 10, trailing: 18)
//            config.cornerStyle = .medium
//            editButton.configuration = config
//        } else {
//            editButton.setTitle("Edit", for: .normal)
//            editButton.setTitleColor(.black, for: .normal)
//            editButton.backgroundColor = yellow
//            editButton.layer.cornerRadius = 8
//            editButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
//        }
//
//        card.addSubview(titleLabel)
//        card.addSubview(detailsLabel)
//        card.addSubview(editButton)
//
//        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
//            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -16),
//            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
//
//            detailsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            detailsLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
//            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
//
//            editButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            editButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
//        ])
//
//        card.layoutIfNeeded()
//        card.layer.shadowPath = UIBezierPath(roundedRect: card.bounds, cornerRadius: card.layer.cornerRadius).cgPath
//
//        return cell
//    }
//
//    // MARK: - Alerts
//    private func showAlert(_ title: String, _ message: String) {
//        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        a.addAction(UIAlertAction(title: "OK", style: .default))
//        present(a, animated: true)
//    }
//}
//
