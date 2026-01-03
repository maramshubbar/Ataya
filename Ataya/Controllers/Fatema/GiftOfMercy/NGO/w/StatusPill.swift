//
//  StatusPill.swift
//  Ataya
//
//  Created by Fatema Maitham on 03/01/2026.
//

import SwiftUI

// ✅ Local theme داخل نفس الملف (حل مشكلة: Cannot find AtayaTheme in scope)
//private enum AtayaTheme {
//    static let yellow = Color(red: 0xF7/255.0, green: 0xD4/255.0, blue: 0x4C/255.0)
//    static let card   = Color(.systemBackground)
//    static let border = Color(.systemGray5)
//    static let bg     = Color(.systemGroupedBackground)
//}

struct StatusPill: View {
    let status: GiftCertificateOrderStatus

    var body: some View {
        Text(label)
            .font(.system(size: 12, weight: .semibold))
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(bg)
            .foregroundColor(fg)
            .clipShape(Capsule())
    }

    private var label: String {
        switch status {
        case .pending: return "Pending"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        case .sent: return "Sent"
        }
    }

    private var bg: Color {
        switch status {
        case .pending: return Color.orange.opacity(0.18)
        case .approved: return Color.green.opacity(0.18)
        case .rejected: return Color.red.opacity(0.18)
        case .sent: return Color.blue.opacity(0.16)
        }
    }

    private var fg: Color {
        switch status {
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        case .sent: return .blue
        }
    }
}

struct YellowButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AtayaTheme.yellow)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

struct OrderCardView: View {

    let order: GiftCertificateOrder
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AtayaTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AtayaTheme.border, lineWidth: 1)
                    )

                HStack(alignment: .top, spacing: 12) {

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            Text(order.giftTitle.isEmpty ? "Gift Certificate" : order.giftTitle)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(1)

                            Spacer()

                            StatusPill(status: order.status)
                        }

                        Text(subtitle)
                            .font(.system(size: 12.5))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)

                        Text(recipientLine)
                            .font(.system(size: 12.5))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)

                        Text(dateLine)
                            .font(.system(size: 12.5))
                            .foregroundStyle(.secondary)

                        YellowButton(title: "View Details", action: onTap)
                            .padding(.top, 6)
                    }

                    Image(systemName: "gift.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 64, height: 64)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(14)
            }
        }
        .buttonStyle(.plain)
    }

    private var subtitle: String {
        let amount = Money.format(order.amount, currency: order.currency)
        let mode = order.pricingMode.capitalized
        let card = order.cardDesignTitle.isEmpty ? "Gift" : order.cardDesignTitle
        return "\(card) • \(amount) • \(mode)"
    }

    private var recipientLine: String {
        order.recipient.name.isEmpty ? "Recipient: -" : "Recipient: \(order.recipient.name)"
    }

    private var dateLine: String {
        guard let ts = order.createdAt else { return "-" }
        return DateFormatter.atayaMedium.string(from: ts.dateValue())
    }
}

enum Money {
    static func format(_ amount: Double, currency: String) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        f.currencyCode = currency
        return f.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
    }
}

extension DateFormatter {
    static let atayaMedium: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
}
