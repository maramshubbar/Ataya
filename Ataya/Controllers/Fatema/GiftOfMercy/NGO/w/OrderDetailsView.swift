//
//  OrderDetailsView.swift
//  Ataya
//
//  Created by Fatema Maitham on 03/01/2026.
//


import SwiftUI
import MessageUI

struct OrderDetailsView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: GiftCertificatesOrdersStore

    let order: GiftCertificateOrder

    @State private var showRejectAlert = false
    @State private var rejectReason = ""

    @State private var showMail = false
    @State private var mailPayload: MailView.Payload?
    @State private var mailErrorText: String?
    @State private var showErrorAlert = false
    @State private var loading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {

                // Header card
                card {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(order.giftTitle.isEmpty ? "Gift Certificate" : order.giftTitle)
                                .font(.system(size: 18, weight: .bold))

                            Text(subtitle)
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        StatusPill(status: order.status)
                    }

                    Divider().padding(.vertical, 6)

                    infoRow("From:", order.fromName.isEmpty ? "-" : order.fromName)
                    infoRow("Recipient:", order.recipient.name.isEmpty ? "-" : order.recipient.name)
                    infoRow("Email:", order.recipient.email.isEmpty ? "-" : order.recipient.email)
                    infoRow("Date:", dateLine)
                }

                // Message card
                card {
                    Text("Message").font(.system(size: 15, weight: .semibold))
                    Text(order.message.isEmpty ? "-" : order.message)
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                        .padding(.top, 2)
                }

                // Actions
                card {
                    if loading {
                        ProgressView().padding(.vertical, 4)
                    }

                    switch order.status {
                    case .pending:
                        ButtonRow(title: "Approve", style: .approve) { approve() }
                        ButtonRow(title: "Reject", style: .reject) { showRejectAlert = true }

                    case .approved:
                        ButtonRow(title: "Send Email", style: .primary) { openMail() }

                    case .rejected, .sent:
                        Text("No actions available.")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }

            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .background(AtayaTheme.bg)
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reject Order", isPresented: $showRejectAlert) {
            TextField("Reason (optional)", text: $rejectReason)
            Button("Cancel", role: .cancel) { }
            Button("Reject", role: .destructive) { reject() }
        } message: {
            Text("Optional: add a reason")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(mailErrorText ?? "Something went wrong.")
        }
        .sheet(isPresented: $showMail) {
            if let payload = mailPayload {
                MailView(payload: payload) { result, error in
                    if let error {
                        mailErrorText = error.localizedDescription
                        showErrorAlert = true
                        return
                    }
                    if result == .sent {
                        Task { await markSent() }
                    }
                }
            }
        }
    }

    // MARK: UI helpers

    private func card(@ViewBuilder _ content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8, content: content)
            .padding(14)
            .background(AtayaTheme.card)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AtayaTheme.border, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func infoRow(_ t: String, _ v: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(t)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 85, alignment: .leading)
            Text(v)
                .font(.system(size: 13))
                .foregroundStyle(.primary)
            Spacer()
        }
    }

    private var subtitle: String {
        let amount = Money.format(order.amount, currency: order.currency)
        let mode = order.pricingMode.capitalized
        let card = order.cardDesignTitle.isEmpty ? "Gift" : order.cardDesignTitle
        return "\(card) • \(amount) • \(mode)"
    }

    private var dateLine: String {
        guard let ts = order.createdAt else { return "-" }
        return DateFormatter.atayaMedium.string(from: ts.dateValue())
    }

    // MARK: Actions

    private func approve() {
        Task {
            loading = true
            defer { loading = false }
            do {
                try await store.approve(orderId: order.id)
                dismiss()
            } catch {
                mailErrorText = error.localizedDescription
                showErrorAlert = true
            }
        }
    }

    private func reject() {
        Task {
            loading = true
            defer { loading = false }
            do {
                let reason = rejectReason.trimmingCharacters(in: .whitespacesAndNewlines)
                try await store.reject(orderId: order.id, reason: reason.isEmpty ? nil : reason)
                dismiss()
            } catch {
                mailErrorText = error.localizedDescription
                showErrorAlert = true
            }
        }
    }

    private func openMail() {
        guard MFMailComposeViewController.canSendMail() else {
            mailErrorText = "Mail not available. Sign in to Mail app (test on real device)."
            showErrorAlert = true
            return
        }
        let to = order.recipient.email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !to.isEmpty else {
            mailErrorText = "Recipient email is empty."
            showErrorAlert = true
            return
        }

        let amountText = Money.format(order.amount, currency: order.currency)
        let body =
"""
Hi \(order.recipient.name.isEmpty ? "there" : order.recipient.name),

You received a Gift of Mercy:
- Gift: \(order.giftTitle)
- Amount: \(amountText) (\(order.pricingMode.capitalized))
- From: \(order.fromName)

Message:
\(order.message.isEmpty ? "-" : order.message)

Regards,
Ataya
"""

        mailPayload = .init(to: to, subject: "Gift of Mercy Certificate ✅", body: body)
        showMail = true
    }

    private func markSent() async {
        loading = true
        defer { loading = false }
        do {
            try await store.markSent(orderId: order.id)
            dismiss()
        } catch {
            mailErrorText = error.localizedDescription
            showErrorAlert = true
        }
    }
}

struct ButtonRow: View {
    enum Style { case primary, approve, reject }
    let title: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundColor(fg)
                .background(bg)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var bg: Color {
        switch style {
        case .primary: return AtayaTheme.yellow
        case .approve: return Color.green.opacity(0.14)
        case .reject: return Color.red.opacity(0.14)
        }
    }
    private var fg: Color {
        switch style {
        case .primary: return .black
        case .approve: return .green
        case .reject: return .red
        }
    }
}
