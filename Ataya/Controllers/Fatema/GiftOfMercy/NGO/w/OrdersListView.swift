import SwiftUI

struct OrdersListView: View {

    @StateObject private var store = GiftCertificatesOrdersStore()

    private static let amountFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        return f
    }()

    private func money(_ o: GiftCertificateOrder) -> String {
        let f = Self.amountFormatter
        f.currencyCode = o.currency.isEmpty ? "BHD" : o.currency
        return f.string(from: NSNumber(value: o.amount)) ?? "\(o.amount) \(o.currency)"
    }

    var body: some View {
        ZStack {
            AtayaTheme.bg.ignoresSafeArea()

            if store.isLoading {
                ProgressView()

            } else if let err = store.errorMessage {
                Text(err)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()

            } else if store.items.isEmpty {
                Text("No gift orders yet")
                    .foregroundStyle(.secondary)

            } else {
                List {
                    ForEach(store.items) { o in
                        NavigationLink {
                            OrderDetailsView(order: o)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(o.giftTitle.isEmpty ? "Gift" : o.giftTitle)
                                    .font(.headline)

                                Text(money(o))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Text("Card: \(o.cardDesignTitle)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Text("Status: \(o.status.rawValue.capitalized)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Gift Orders")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.startListening()
        }
    }
}
