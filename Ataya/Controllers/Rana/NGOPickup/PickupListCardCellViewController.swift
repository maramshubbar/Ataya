
//
//
import UIKit
import FirebaseFirestore

final class PickupListCardCellViewController: UIViewController {

    @IBOutlet weak var statusSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    private var allItems: [PickupItem] = []
    private var shownItems: [PickupItem] = []
    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔥🔥 PICKUP VC LOADED")
        title = "My Pickups"

        setupSegmentUI()
        setupTable()

        statusSegment.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)

        startListening()
    }

    deinit { listener?.remove() }

    private func startListening() {
        listener?.remove()

        listener = PickupFirestoreService.shared.listenMyPickups { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    print("✅ got pickups:", items.count)
                    self.allItems = items
                    self.applyFilter()

                case .failure(let error):
                    print("❌ Firestore listen error:", error.localizedDescription)
                }
            }
        }
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white

        tableView.rowHeight = 200  // ✅ force height (no hiding)

        tableView.register(PickupListCardCell.self, forCellReuseIdentifier: "PickupListCardCell")
    }

    private func setupSegmentUI() {
        statusSegment.selectedSegmentIndex = 0
        statusSegment.backgroundColor = UIColor.hex("#F3F3F3")
        statusSegment.selectedSegmentTintColor = .white
        statusSegment.layer.cornerRadius = 10
        statusSegment.layer.masksToBounds = true
    }

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        applyFilter()
    }

    private func applyFilter() {
        switch statusSegment.selectedSegmentIndex {
        case 1: shownItems = allItems.filter { $0.status == .pending }
        case 2: shownItems = allItems.filter { $0.status == .accepted }
        case 3: shownItems = allItems.filter { $0.status == .completed }
        default: shownItems = allItems
        }
        tableView.reloadData()
    }

    private func openDetails(for pickupID: String) {
        guard let index = allItems.firstIndex(where: { $0.pickupID == pickupID }) else { return }

        let vc = storyboard?.instantiateViewController(withIdentifier: "PickupDetailsViewController") as! PickupDetailsViewController
        vc.item = allItems[index]

        vc.onStatusChanged = { newStatus in
            guard let docId = vc.item.id else {
                print("Firestore docId missing – status update skipped")
                return
            }

            PickupFirestoreService.shared.updateStatus(docId: docId, status: newStatus) { result in
                switch result {
                case .success: print("✅ Firestore updated:", newStatus.rawValue)
                case .failure(let error): print("❌ Firestore update failed:", error.localizedDescription)
                }
            }
        }

        navigationController?.pushViewController(vc, animated: true)
    }
}

extension PickupListCardCellViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shownItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = shownItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickupListCardCell", for: indexPath) as! PickupListCardCell

        cell.configure(
            title: item.title,
            donor: item.donor,
            location: item.location,
            date: item.date,
            status: item.status.rawValue,
            imageName: item.imageName
        ) { [weak self] in
            self?.openDetails(for: item.pickupID)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openDetails(for: shownItems[indexPath.row].pickupID)
    }
}

