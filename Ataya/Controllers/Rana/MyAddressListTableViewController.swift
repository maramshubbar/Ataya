//
//  MyAddressListTableViewController.swift
//  Ataya
//
//  Created by BP-36-224-14 on 22/12/2025.
//

import UIKit

final class MyAddressListTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    @IBOutlet weak var tableView: UITableView!
    
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

            // if selectedIndex invalid
            if let idx = selectedIndex, idx >= addresses.count {
                selectedIndex = nil
                AddressStorage.shared.saveSelectedIndex(nil)
            }

            tableView.reloadData()
        }

        private func updateButtons() {
            let canAdd = addresses.count < 2
            addNewAddressButton.isEnabled = canAdd
            addNewAddressButton.alpha = canAdd ? 1.0 : 0.4

            // new user: confirm disabled
            let canConfirm = (selectedIndex != nil) && !addresses.isEmpty
            confirmButton.isEnabled = canConfirm
            confirmButton.alpha = canConfirm ? 1.0 : 0.4
        }

        // MARK: - Actions

        @IBAction func addNewAddressTapped(_ sender: UIButton) {
            if addresses.count >= 2 {
                showAlert("Limit Reached", "You can only save 2 addresses.")
                return
            }
            performSegue(withIdentifier: "toAddressDetails", sender: nil)
        }

        @IBAction func confirmTapped(_ sender: UIButton) {
            guard let idx = selectedIndex, idx < addresses.count else { return }
            showEndPopup(for: addresses[idx])
        }

        @objc private func editTapped(_ sender: UIButton) {
            performSegue(withIdentifier: "toAddressDetails", sender: sender.tag)
        }

        // MARK: - UITableViewDataSource

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return addresses.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath) as? AddressCardCell else {
                return UITableViewCell()
            }

            let item = addresses[indexPath.row]
            cell.titleLabel.text = item.title
            cell.detailsLabel.text = item.fullAddress

            // show checkmark for selected
            cell.accessoryType = (indexPath.row == selectedIndex) ? .checkmark : .none

            // Edit
            cell.editButton.tag = indexPath.row
            cell.editButton.removeTarget(nil, action: nil, for: .allEvents)
            cell.editButton.addTarget(self, action: #selector(editTapped(_:)), for: .touchUpInside)

            return cell
        }

        // MARK: - UITableViewDelegate

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedIndex = indexPath.row
            AddressStorage.shared.saveSelectedIndex(selectedIndex)

            tableView.reloadData()
            updateButtons()

            // Optional: show popup immediately when selecting (if you want)
            // showEndPopup(for: addresses[indexPath.row])
        }

        // MARK: - Navigation

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            guard segue.identifier == "toAddressDetails",
                  let vc = segue.destination as? MyAddressDetailsViewController else { return }

            // editing existing
            if let index = sender as? Int, index < addresses.count {
                vc.editIndex = index
                vc.existingAddress = addresses[index]
            } else {
                vc.editIndex = nil
                vc.existingAddress = nil
            }

            // callback save into storage
            vc.onSaveAddress = { savedAddress, editIndex in
                var list = AddressStorage.shared.loadAddresses()

                if let i = editIndex, i < list.count {
                    list[i] = savedAddress
                } else {
                    guard list.count < 2 else { return } // limit
                    list.append(savedAddress)

                    // if first address and nothing selected, select it
                    if AddressStorage.shared.loadSelectedIndex() == nil {
                        AddressStorage.shared.saveSelectedIndex(0)
                    }
                }

                AddressStorage.shared.saveAddresses(list)
            }
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
