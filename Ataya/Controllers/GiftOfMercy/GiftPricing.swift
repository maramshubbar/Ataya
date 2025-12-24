//
//  GiftPricing.swift
//  Ataya
//
//  Created by Fatema Maitham on 24/12/2025.
//


// GiftModels.swift

import Foundation

struct GiftItem: Identifiable, Equatable {

    let id: UUID = UUID()
    let title: String
    let imageName: String
    let pricing: Pricing
    let description: String

    enum Pricing: Equatable {
        case fixed(amount: Decimal)
        case custom
    }

    var requiresAmount: Bool {
        if case .custom = pricing { return true }
        return false
    }
}

struct GiftSelection: Equatable {
    let gift: GiftItem
    let amount: Decimal
}
