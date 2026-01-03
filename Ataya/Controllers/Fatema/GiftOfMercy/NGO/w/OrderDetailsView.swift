import SwiftUI

struct OrderDetailsView: View {

    let order: GiftCertificateOrder

    var body: some View {
        ZStack {
            AtayaTheme.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {

                    GroupBox("Gift") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(order.giftTitle.isEmpty ? "—" : order.giftTitle)
                            Text("GiftId: \(order.giftId)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    GroupBox("Card Design") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(order.cardDesignTitle.isEmpty ? "—" : order.cardDesignTitle)
                            Text("CardDesignId: \(order.cardDesignId)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    GroupBox("Message") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("From: \(order.fromName.isEmpty ? "—" : order.fromName)")
                            Text(order.message.isEmpty ? "—" : order.message)
                        }
                    }

                    GroupBox("Recipient") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name: \(order.recipient.name.isEmpty ? "—" : order.recipient.name)")
                            Text("Email: \(order.recipient.email.isEmpty ? "—" : order.recipient.email)")
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
