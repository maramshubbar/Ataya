import UIKit
import FirebaseFirestore

struct NGO {
    let id: String
    let name: String
    let description: String
    let email: String
    let note: String?
    let status: String          // pending / verified / rejected
    let createdAt: Date
}

final class NGOVerificationViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // ✅ لازم يكون نفس اسم كوليكشن البنات بالضبط
    private let collectionName = "ngo_applications"

    private var allNGOs: [NGO] = []
    private var shownNGOs: [NGO] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // ✅ تأكد سريع (إذا طلع nil معناها outlet مو مربوط)
        // print("searchBar nil? ->", searchBar == nil)

        // SearchBar UI
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none

        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = .white
            searchField.layer.cornerRadius = 10
            searchField.clipsToBounds = true
        }

        // Delegates
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self

        // Segment change
        filterSegment.addTarget(self, action: #selector(filterChanged), for: .valueChanged)

        // Table setup
        let nib = UINib(nibName: "NGOVerificationTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NGOVerificationTableViewCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.keyboardDismissMode = .onDrag
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListening()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListening()
    }

    deinit {
        stopListening()
    }

    private func stopListening() {
        listener?.remove()
        listener = nil
    }

    // MARK: - Firestore Listener
    private func startListening() {
        stopListening() // ✅ امنعي تكرار listeners

        // ✅ الخيار 1: Root collection
        let query = db.collection(collectionName)
            .order(by: "createdAt", descending: true)
            .limit(to: 200)

        // ✅ الخيار 2 (إذا البنات مسوينها Subcollection):
        // let query = db.collectionGroup(collectionName)
        //     .order(by: "createdAt", descending: true)
        //     .limit(to: 200)

        listener = query.addSnapshotListener { [weak self] snap, err in
            guard let self else { return }

            if let err = err {
                print("❌ NGO verification error:", err.localizedDescription)
                return
            }

            let docs = snap?.documents ?? []
            self.allNGOs = docs.compactMap { doc in
                let data = doc.data()

                let name = data["name"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let note = data["note"] as? String
                let status = (data["status"] as? String ?? "pending").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

                let ts = data["createdAt"] as? Timestamp
                let createdAt = ts?.dateValue() ?? Date.distantPast

                return NGO(
                    id: doc.documentID,
                    name: name,
                    description: description,
                    email: email,
                    note: note,
                    status: status,
                    createdAt: createdAt
                )
            }

            DispatchQueue.main.async {
                self.applyFiltersAndReload()
            }
        }
    }

    // MARK: - Filters + Search
    @objc private func filterChanged() {
        applyFiltersAndReload()
    }

    private func selectedStatusFromSegment() -> String {
        // All / Pending / Verified / Rejected
        switch filterSegment.selectedSegmentIndex {
        case 0: return "all"
        case 1: return "pending"
        case 2: return "verified"
        case 3: return "rejected"
        default: return "all"
        }
    }

    private func applyFiltersAndReload() {
        let selectedStatus = selectedStatusFromSegment()
        let searchText = (searchBar.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        var items = allNGOs

        // Segment filter
        if selectedStatus != "all" {
            items = items.filter { $0.status == selectedStatus }
        }

        // Search filter
        if !searchText.isEmpty {
            items = items.filter { ngo in
                let haystack = [
                    ngo.name,
                    ngo.description,
                    ngo.email,
                    ngo.note ?? "",
                    ngo.status // ✅ لو تبين تبحثين بـ pending/verified
                ].joined(separator: " ").lowercased()

                return haystack.contains(searchText)
            }
        }

        shownNGOs = items
        tableView.reloadData()

        // ✅ Debug (اختياري)
        // print("all:", allNGOs.count, "shown:", shownNGOs.count, "search:", searchText, "seg:", selectedStatus)
    }

    private func openDetails(ngo: NGO) {
        // later
    }
}

// MARK: - UITableView
extension NGOVerificationViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shownNGOs.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "NGOVerificationTableViewCell",
            for: indexPath
        ) as? NGOVerificationTableViewCell else {
            return UITableViewCell()
        }

        let ngo = shownNGOs[indexPath.row]

        cell.nameLabel.text = ngo.name
        cell.descriptionLabel.text = ngo.description
        cell.emailLabel.text = ngo.email

        if let note = ngo.note, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            cell.noteLabel.isHidden = false
            cell.noteLabel.text = note
        } else {
            cell.noteLabel.isHidden = true
            cell.noteLabel.text = nil
        }

        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openDetails(ngo: shownNGOs[indexPath.row])
    }
}

// MARK: - UISearchBarDelegate
extension NGOVerificationViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // print("Typing:", searchText) // ✅ Debug
        applyFiltersAndReload()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        applyFiltersAndReload()
    }
}
