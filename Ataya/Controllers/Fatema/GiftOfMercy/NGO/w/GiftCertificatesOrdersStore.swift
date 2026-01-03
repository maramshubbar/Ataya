import Foundation
import FirebaseFirestore

@MainActor
final class GiftCertificatesOrdersStore: ObservableObject {

    @Published var items: [GiftCertificateOrder] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var listener: ListenerRegistration?

    deinit { listener?.remove() }

    func startListening() {
        isLoading = true
        errorMessage = nil
        listener?.remove()

        listener = GiftCertificatesService.shared.listenOrders { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .failure(let err):
                    self.items = []
                    self.errorMessage = err.localizedDescription

                case .success(let list):
                    self.items = list
                    print("✅ store items:", list.count)
                }
            }
        }
    }
}
