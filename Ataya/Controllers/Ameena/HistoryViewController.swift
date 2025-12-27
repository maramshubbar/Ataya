import UIKit
import FirebaseAuth
import FirebaseFirestore


final class HistoryViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // Simple model (replace later with your Firebase model)
    typealias HistoryItem = (title: String, category: String, date: String, status: String)

    private var filteredItems: [HistoryItem] = []
    
    private var allItems: [HistoryItem] = [
        HistoryItem(title: "Bread & Bakery Items",
                    category: "Baked Goods",
                    date: "Nov 14 2025",
                    status: "Confirmed")
    ]

    // ✅ Save which row was tapped for Edit (for prepare segue)
    private var selectedItemForDetails: HistoryItem?
    
    private var listener: ListenerRegistration?
    private var items: [RecurringDonation] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        startListening()

        definesPresentationContext = true

        title = "Recurring History"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backButtonTitle = ""

        filteredItems = allItems

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
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let tf = searchBar.searchTextField
        tf.frame.size.height = 44
        tf.layer.cornerRadius = 10
        tf.clipsToBounds = true
    }

    // MARK: - Alerts
    private func showAlert(_ msg: String) {
        let a = UIAlertController(title: "Action", message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    private func showConfirm(title: String, message: String, onYes: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in onYes() })
        present(alert, animated: true)
    }

    // MARK: - Popup Presenting
    private func showPopup(storyboardID: String) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: storyboardID)
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }

    private func showPausedPopup() { showPopup(storyboardID: "HistoryPausedPopup") }
    private func showResumedPopup() { showPopup(storyboardID: "HistoryResumedPopup") }
    
    private func startListening() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No logged in user")
            return
        }

        listener = Firestore.firestore()
            .collection("Recurring_Donations")
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                if let err = err {
                    print("Firestore error:", err)
                    return
                }

                self?.items = snap?.documents.compactMap { RecurringDonation(doc: $0) } ?? []
                self?.tableView.reloadData()
            }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetails" {
            // Example: pass data to details page later
            // let vc = segue.destination as! RecurringDonationDetailsViewController
            // vc.prefilledTitle = selectedItemForDetails?.title

            // For now just confirm we have the item:
            print("✅ going to details with item:", selectedItemForDetails?.title ?? "nil")
        }
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
        
        cell.configure(title: item.title,
                       category: item.category,
                       date: item.date,
                       status: item.status)
        
        // ✅ Set callbacks ONCE (don’t repeat / overwrite)
        
        cell.onEdit = { [weak self] in
            guard let self else { return }
            
            // Save selected item (so prepare() can use it)
            self.selectedItemForDetails = item
            
            // Go to details
            self.performSegue(withIdentifier: "goToDetails", sender: self)
        }
        
        cell.onPause = { [weak self] in
            guard let self else { return }

            self.showConfirm(title: "Pause Donation",
                             message: "Are you sure you want to pause this donation?") {

                // ✅ Update status
                self.filteredItems[indexPath.row].status = "Paused"

                // ✅ Reload only this row (smooth)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)

                // ✅ Show popup
                self.showPausedPopup()
            }
        }
        
        cell.onResume = { [weak self] in
            guard let self else { return }

            self.showConfirm(title: "Resume Donation",
                             message: "Are you sure you want to resume this donation?") {

                // ✅ Update status
                self.filteredItems[indexPath.row].status = "Resumed"

                // ✅ Reload only this row
                self.tableView.reloadRows(at: [indexPath], with: .automatic)

                // ✅ Show popup
                self.showResumedPopup()
            }
        }

        
        return cell
        
    }
}
    // MARK: - Search
    extension HistoryViewController: UISearchBarDelegate {
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = ""
            filteredItems = allItems
            tableView.reloadData()
            searchBar.resignFirstResponder()
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            let t = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            
            if t.isEmpty {
                filteredItems = allItems
            } else {
                filteredItems = allItems.filter {
                    $0.title.lowercased().contains(t) ||
                    $0.category.lowercased().contains(t) ||
                    $0.status.lowercased().contains(t) ||
                    $0.date.lowercased().contains(t)
                }
            }
            
            tableView.reloadData()
        }
    }

