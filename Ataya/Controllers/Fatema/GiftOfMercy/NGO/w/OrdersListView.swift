//
//  OrdersListView.swift
//  Ataya
//
//  Created by Fatema Maitham on 03/01/2026.
//


import SwiftUI

struct OrdersListView: View {

    @StateObject private var store = GiftCertificatesOrdersStore()

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {

                // Search
                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Search", text: $store.searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .onChange(of: store.searchText) { _ in store.apply() }

                // Segmented
                Picker("", selection: $store.filter) {
                    ForEach(GiftCertificatesOrdersStore.Filter.allCases, id: \.self) { f in
                        Text(f.title).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .onChange(of: store.filter) { _ in store.apply() }

                // List
                ScrollView {
                    LazyVStack(spacing: 10) {
                        if store.shown.isEmpty {
                            Text("No orders yet.")
                                .foregroundStyle(.secondary)
                                .padding(.top, 30)
                        } else {
                            ForEach(store.shown) { order in
                                NavigationLink {
                                    OrderDetailsView(order: order)
                                        .environmentObject(store)
                                } label: {
                                    OrderCardView(order: order) { }
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .background(AtayaTheme.bg)
            .navigationTitle("Orders")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear { store.start() }
        .onDisappear { store.stop() }
    }
}
