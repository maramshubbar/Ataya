//
//  RewardTier.swift
//  Ataya
//
//  Created by Maram on 02/01/2026.
//
import Foundation

enum RewardTier {
    case starter, silver, gold, diamond

    static func from(points: Int) -> RewardTier {
        switch points {
        case 0..<500: return .starter
        case 500..<1500: return .silver
        case 1500..<2500: return .gold
        default: return .diamond
        }
    }

    var title: String {
        switch self {
        case .starter: return "Starter"
        case .silver: return "Silver Donor"
        case .gold: return "Gold Donor"
        case .diamond: return "Diamond Donor"
        }
    }

    var medalAssetName: String {
        switch self {
        case .starter: return "tier_starter"
        case .silver:  return "tier_silver"
        case .gold:    return "tier_gold"
        case .diamond: return "tier_diamond"
        }
    }
}
