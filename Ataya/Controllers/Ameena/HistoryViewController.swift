import UIKit
import FirebaseAuth
import FirebaseFirestore

final class HistoryViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    

    private var listener: ListenerRegistration?
    private var allItems: [RecurringDonation] = []
    private var filteredItems: [RecurringDonation] = []

    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Recurring History"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backButtonTitle = ""

        definesPresentationContext = true

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 220
        tableView.keyboardDismissMode = .onDrag

        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.autocapitalizationType = .none
        searchBar.searchTextField.clearButtonMode = .whileEditing

        startListening()
    }

    deinit {
        listener?.remove()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let tf = searchBar.searchTextField
        tf.frame.size.height = 44
        tf.layer.cornerRadius = 10
        tf.clipsToBounds = true
    }

    // MARK: - Firestore
    private func startListening() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No logged in user")
            return
        }

        listener?.remove()
        listener = db.collection("Recurring_Donations")
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }

                if let err = err {
                    print("Firestore error:", err)
                    return
                }

                let list = snap?.documents.compactMap { RecurringDonation(doc: $0) } ?? []
                self.allItems = list
                self.applySearchFilter(text: self.searchBar.text ?? "")
            }
    }

    private func updateDonationStatus(docId: String, newStatus: String, completion: @escaping (Bool) -> Void) {
        db.collection("Recurring_Donations")
            .document(docId)
            .updateData([
                "status": newStatus,
                "updatedAt": FieldValue.serverTimestamp()
            ]) { err in
                completion(err == nil)
            }
    }

    // MARK: - Popups / Alerts
    private func showConfirm(title: String, message: String, onYes: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in onYes() })
        present(alert, animated: true)
    }

    private func showPopup(storyboardID: String) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: storyboardID)
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }

    private func showPausedPopup() { showPopup(storyboardID: "HistoryPausedPopup") }
    private func showResumedPopup() { showPopup(storyboardID: "HistoryResumedPopup") }

    // MARK: - Navigation (Edit)
        private func openEdit(for item: RecurringDonation) {
            var draft = RecurringDonationDraft()

        // Keep document id for update later
        draft.docId = item.docId

        // Page 1 fields
        draft.frequency = item.frequency
        draft.startDate = item.startDate
        draft.nextPickupDate = item.nextPickupDate

        // Page 2 fields
        draft.foodCategoryName = item.foodCategoryName
        draft.foodItemName = item.foodItemName
        draft.estimatedQuantity = item.estimatedQuantity
        draft.unit = item.unit
        draft.description = item.description

        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "RecurringDonationDetailsViewController") as? RecurringDonationDetailsViewController else {
            assertionFailure("RecurringDonationDetailsViewController storyboard ID is missing or incorrect.")
            return
        }

        vc.draft = draft
        vc.isEditingDonation = true
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Search
    private func applySearchFilter(text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if t.isEmpty {
            filteredItems = allItems
        } else {
            filteredItems = allItems.filter { item in
                let title = item.foodItemName.lowercased()
                let cat = item.foodCategoryName.lowercased()
                let status = item.status.lowercased()
                let date = formatDate(item.createdAt).lowercased()

                return title.contains(t) ||
                       cat.contains(t) ||
                       status.contains(t) ||
                       date.contains(t)
            }
        }

        tableView.reloadData()
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM dd yyyy"
        return f.string(from: date)
    }
}

// MARK: - Table
extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "RecurringHistoryCell",
                                                 for: indexPath) as! RecurringHistoryCell

        let item = filteredItems[indexPath.row]

        cell.configure(
            title: item.foodItemName,
            category: item.foodCategoryName,
            date: formatDate(item.createdAt),
            status: item.status
        )

        cell.onEdit = { [weak self] in
            self?.openEdit(for: item)
        }

        cell.onPause = { [weak self] in
            guard let self else { return }

            self.showConfirm(title: "Pause Donation",
                             message: "Are you sure you want to pause this donation?") {

                self.updateDonationStatus(docId: item.docId, newStatus: "paused") { ok in
                    if ok { self.showPausedPopup() }
                    else { print("Failed to update status") }
                }
            }
        }

        cell.onResume = { [weak self] in
            guard let self else { return }

            self.showConfirm(title: "Resume Donation",
                             message: "Are you sure you want to resume this donation?") {

                self.updateDonationStatus(docId: item.docId, newStatus: "confirmed") { ok in
                    if ok { self.showResumedPopup() }
                    else { print("Failed to update status") }
                }
            }
        }

        return cell
    }
}

// MARK: - UISearchBarDelegate
extension HistoryViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        applySearchFilter(text: "")
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applySearchFilter(text: searchText)
    }
}
