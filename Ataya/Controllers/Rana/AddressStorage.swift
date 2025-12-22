//
//  AddressStorage.swift
//  Ataya
//
//  Created by BP-36-224-14 on 22/12/2025.
//


import Foundation

final class AddressStorage {

    static let shared = AddressStorage()

    private init() {}

    private let addressesKey = "saved_addresses"
    private let selectedIndexKey = "selected_address_index"

    // MARK: - Addresses

    func loadAddresses() -> [AddressModel] {
        guard
            let data = UserDefaults.standard.data(forKey: addressesKey),
            let list = try? JSONDecoder().decode([AddressModel].self, from: data)
        else {
            return []
        }
        return list
    }

    func saveAddresses(_ addresses: [AddressModel]) {
        if let data = try? JSONEncoder().encode(addresses) {
            UserDefaults.standard.set(data, forKey: addressesKey)
        }
    }

    // MARK: - Selected Index

    func loadSelectedIndex() -> Int? {
        let value = UserDefaults.standard.integer(forKey: selectedIndexKey)
        return UserDefaults.standard.object(forKey: selectedIndexKey) == nil ? nil : value
    }

    func saveSelectedIndex(_ index: Int?) {
        if let index = index {
            UserDefaults.standard.set(index, forKey: selectedIndexKey)
        } else {
            UserDefaults.standard.removeObject(forKey: selectedIndexKey)
        }
    }
}
