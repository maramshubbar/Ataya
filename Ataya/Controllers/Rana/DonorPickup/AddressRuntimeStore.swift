//
//  AddressRuntimeStore.swift
//  Ataya
//
//  Created by Rana on 01/01/2026.
//


import Foundation

final class AddressRuntimeStore {
    static let shared = AddressRuntimeStore()
    private init() {}

    var addresses: [AddressModel] = []
    var selectedIndex: Int? = nil
    var confirmedAddress: AddressModel? = nil

    func canAddNew() -> Bool {
        return addresses.count < 2
    }

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
