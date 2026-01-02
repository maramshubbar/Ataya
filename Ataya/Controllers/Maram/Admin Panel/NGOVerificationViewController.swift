import UIKit
import FirebaseFirestore

// ✅ Model مربوط بـ users collection
struct NGO {
    let id: String
    let name: String
    let type: String           // ✅ NEW
    let description: String    // mission/description (لـ View Details)
    let email: String
    let phone: String
    let note: String?
    let status: String         // pending / verified / rejected
    let createdAt: Date
}

final class NGOVerificationViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private let usersCollection = "users"

    private var allNGOs: [NGO] = []
    private var shownNGOs: [NGO] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // SearchBar UI
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none

        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = .white
            searchField.layer.cornerRadius = 10
            searchField.clipsToBounds = true
        }

        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self

        filterSegment.addTarget(self, action: #selector(filterChanged), for: .valueChanged)

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

    deinit { stopListening() }

    private func stopListening() {
        listener?.remove()
        listener = nil
    }

    // MARK: - Firestore Listener (USERS -> NGO)
    private func startListening() {
        stopListening()

        let query = db.collection(usersCollection)
            .whereField("role", isEqualTo: "ngo")
            .order(by: "createdAt", descending: true)
            .limit(to: 200)

        listener = query.addSnapshotListener { [weak self] snap, err in
            guard let self else { return }

            if let err = err {
                print("❌ NGO verification error:", err.localizedDescription)
                return
            }

            let docs = snap?.documents ?? []
            self.allNGOs = docs.compactMap { doc in
                let data = doc.data()

                let name  = data["name"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let phone = data["phone"] as? String ?? ""

                // ✅ type من Org Details
                let type = (data["type"] as? String ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                // description (mission/description/overview) للـ details
                let description =
                    (data["mission"] as? String) ??
                    (data["description"] as? String) ??
                    (data["overview"] as? String) ??
                    ""

                let note =
                    (data["rejectionReason"] as? String) ??
                    (data["note"] as? String)

                let statusRaw =
                    (data["approvalStatus"] as? String) ??
                    (data["status"] as? String) ??
                    "pending"

                let status = statusRaw
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased()

                let ts = data["createdAt"] as? Timestamp
                let createdAt = ts?.dateValue() ?? Date.distantPast

                return NGO(
                    id: doc.documentID,
                    name: name,
                    type: type,                 // ✅ NEW
                    description: description,
                    email: email,
                    phone: phone,
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

        if selectedStatus != "all" {
            items = items.filter { $0.status == selectedStatus }
        }

        if !searchText.isEmpty {
            items = items.filter { ngo in
                let haystack = [
                    ngo.name,
                    ngo.type,          // ✅ NEW
                    ngo.description,
                    ngo.email,
                    ngo.phone,
                    ngo.note ?? "",
                    ngo.status
                ].joined(separator: " ").lowercased()

                return haystack.contains(searchText)
            }
        }

        shownNGOs = items
        tableView.reloadData()
    }

    // MARK: - Admin Actions (View Details)
    private func presentDetailsAndActions(for ngo: NGO) {

        let typeText = ngo.type.isEmpty ? "—" : ngo.type
        let descText = ngo.description.isEmpty ? "—" : ngo.description
        let noteText = (ngo.note?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? ngo.note! : "—"

        let message =
        """
        Type: \(typeText)

        Email: \(ngo.email)
        Phone: \(ngo.phone)

        About:
        \(descText)

        Note:
        \(noteText)

        Status: \(ngo.status.uppercased())
        """

        let sheet = UIAlertController(title: ngo.name, message: message, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: "Approve (Verified)", style: .default, handler: { [weak self] _ in
            self?.updateNGOStatus(ngoId: ngo.id, status: "verified", rejectionReason: nil)
        }))

        sheet.addAction(UIAlertAction(title: "Reject", style: .destructive, handler: { [weak self] _ in
            self?.promptRejectReason(ngo: ngo)
        }))

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let pop = sheet.popoverPresentationController {
            pop.sourceView = self.view
            pop.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY - 120, width: 1, height: 1)
        }

        present(sheet, animated: true)
    }

    private func promptRejectReason(ngo: NGO) {
        let alert = UIAlertController(title: "Reject NGO", message: "Add reason (optional)", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Reason…"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reject", style: .destructive, handler: { [weak self] _ in
            let reason = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            self?.updateNGOStatus(ngoId: ngo.id, status: "rejected", rejectionReason: reason)
        }))
        present(alert, animated: true)
    }

    private func updateNGOStatus(ngoId: String, status: String, rejectionReason: String?) {
        var data: [String: Any] = [
            "approvalStatus": status,
            "statusUpdatedAt": FieldValue.serverTimestamp()
        ]

        if status == "rejected" {
            if let r = rejectionReason, !r.isEmpty {
                data["rejectionReason"] = r
            }
        } else {
            data["rejectionReason"] = FieldValue.delete()
        }

        db.collection(usersCollection).document(ngoId).updateData(data) { [weak self] err in
            if let err {
                self?.simpleAlert(title: "Update Failed", message: err.localizedDescription)
                return
            }

            self?.db.collection("audit_logs").addDocument(data: [
                "title": status == "verified" ? "NGO Verified" : "NGO Rejected",
                "user": "Admin",
                "location": "",
                "category": "verification",
                "createdAt": FieldValue.serverTimestamp()
            ])

            self?.simpleAlert(title: "Done", message: "Status updated to \(status)")
        }
    }

    private func simpleAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
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

        // ✅ هنا التايب يطلع مكان الـ "—"
        cell.descriptionLabel.text = ngo.type.isEmpty ? "—" : ngo.type

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
        presentDetailsAndActions(for: shownNGOs[indexPath.row])
    }
}

// MARK: - UISearchBarDelegate
extension NGOVerificationViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // ✅ لا نعرض زر Cancel
        searchBar.showsCancelButton = false
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFiltersAndReload()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
