//
//  MyAddressListTableViewController.swift
//  Ataya
//
//  Created by BP-36-224-14 on 22/12/2025.
//

import UIKit

final class MyAddressListTableViewController: UIViewController {

    @IBOutlet weak var tabelView: UITableView!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var addNewAddressButton: UIButton!
    
        private var addresses: [AddressModel] = []
        private var selectedIndex: Int? = nil

        override func viewDidLoad() {
            super.viewDidLoad()

            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()

            reloadFromStorage()
            updateButtons()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            reloadFromStorage()
            updateButtons()
        }

        private func reloadFromStorage() {
            addresses = AddressStorage.shared.loadAddresses()
            selectedIndex = AddressStorage.shared.loadSelectedIndex()

            if let idx = selectedIndex, idx >= addresses.count {
                selectedIndex = nil
                AddressStorage.shared.saveSelectedIndex(nil)
            }

            tableView.reloadData()
        }

        private func updateButtons() {
            let canAdd = addresses.count < 2
            addNewAddressButton.isEnabled = canAdd
            addNewAddressButton.alpha = canAdd ? 1 : 0.4

            let canConfirm = (selectedIndex != nil) && !addresses.isEmpty
            confirmButton.isEnabled = canConfirm
            confirmButton.alpha = canConfirm ? 1 : 0.4
        }

        @IBAction func addNewAddressTapped(_ sender: UIButton) {
            guard addresses.count < 2 else { return }
            performSegue(withIdentifier: "toAddressDetails", sender: nil)
        }

        @IBAction func confirmTapped(_ sender: UIButton) {
            guard let idx = selectedIndex, idx < addresses.count else { return }
            // TODO: popup later
            print("Confirmed address:", addresses[idx])
        }

        @objc private func editTapped(_ sender: UIButton) {
            let index = sender.tag
            performSegue(withIdentifier: "toAddressDetails", sender: index)
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            guard segue.identifier == "toAddressDetails" else { return }
            guard let vc = segue.destination as? MyAddressDetailsViewController else { return }

            // EDIT
            if let index = sender as? Int, index < addresses.count {
                vc.editIndex = index
                vc.existingAddress = addresses[index]
            } else {
                // ADD
                vc.editIndex = nil
                vc.existingAddress = nil
            }

            vc.onSaveAddress = { savedAddress, editIndex in
                var list = AddressStorage.shared.loadAddresses()

                if let i = editIndex, i < list.count {
                    list[i] = savedAddress
                } else {
                    guard list.count < 2 else { return }
                    list.append(savedAddress)
                    if AddressStorage.shared.loadSelectedIndex() == nil {
                        AddressStorage.shared.saveSelectedIndex(0)
                    }
                }

                AddressStorage.shared.saveAddresses(list)
            }
        }
    }

    extension MyAddressListTableViewController: UITableViewDataSource, UITableViewDelegate {

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return addresses.count
        }

        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "AddressCell",
                for: indexPath
            ) as? AddressCardCell else {
                return UITableViewCell()
            }

            let item = addresses[indexPath.row]
            cell.titleLabel.text = item.title
            cell.detailsLabel.text = item.fullAddress

            cell.accessoryType = (indexPath.row == selectedIndex) ? .checkmark : .none

            cell.editButton.tag = indexPath.row
            cell.editButton.removeTarget(nil, action: nil, for: .allEvents)
            cell.editButton.addTarget(self, action: #selector(editTapped(_:)), for: .touchUpInside)

            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedIndex = indexPath.row
            AddressStorage.shared.saveSelectedIndex(selectedIndex)
            tableView.reloadData()
            updateButtons()
        }
    }

