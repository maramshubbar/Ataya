
//
//
import UIKit

final class PickupListCardCellViewController: UIViewController {

    @IBOutlet weak var statusSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    private var allItems: [PickupItem] = []
    private var shownItems: [PickupItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Pickups"

        setupSegmentUI()
        setupTable()

        statusSegment.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)

        loadExampleCards()
        applyFilter()
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.estimatedRowHeight = 190
        tableView.rowHeight = UITableView.automaticDimension

        tableView.register(PickupListCardCell.self, forCellReuseIdentifier: "PickupListCardCell")
    }

    private func setupSegmentUI() {
        statusSegment.selectedSegmentIndex = 0
        statusSegment.backgroundColor = UIColor.hex("#F3F3F3")
        statusSegment.selectedSegmentTintColor = .white
        statusSegment.layer.cornerRadius = 10
        statusSegment.layer.masksToBounds = true
    }

    private func loadExampleCards() {
        allItems = [
            PickupItem(
                pickupID: "DON-10",
                title: "Baby Formula (DON-10)",
                donor: "Ahmed Saleh (ID: D-26)",
                location: "Manama, Bahrain",
                date: "Nov 6 2025",
                imageName: "baby_formula",
                itemName: "Baby Formula",
                quantity: "850 grams",
                category: "Infant Nutrition",
                expiryDate: "05/2026",
                notes: "Keep in a cool, dry place",
                scheduledDate: "Nov 6, 2025",
                status: .pending
            ),
            PickupItem(
                pickupID: "DON-7",
                title: "Water 5 Gallon (DON-7)",
                donor: "Sara Carter (ID: D-29)",
                location: "A'ali, Bahrain",
                date: "Nov 6 2025",
                imageName: "water_gallon",
                itemName: "Water 5 Gallon",
                quantity: "1 bottle",
                category: "Drinks",
                expiryDate: "—",
                notes: "Handle carefully",
                scheduledDate: "Nov 6, 2025",
                status: .accepted
            ),
            PickupItem(
                pickupID: "DON-99",
                title: "White Rice (DON-99)",
                donor: "Mohd Jamal (ID: D-150)",
                location: "Kuwait City, Kuwait",
                date: "Nov 4 2025",
                imageName: "white_rice",
                itemName: "White Rice",
                quantity: "2 kg",
                category: "Food",
                expiryDate: "12/2026",
                notes: "Store in a dry place",
                scheduledDate: "Nov 4, 2025",
                status: .completed
            )
        ]
    }

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        applyFilter()
    }

    private func applyFilter() {
        switch statusSegment.selectedSegmentIndex {
        case 1:
            shownItems = allItems.filter { $0.status == .pending }
        case 2:
            shownItems = allItems.filter { $0.status == .accepted }
        case 3:
            shownItems = allItems.filter { $0.status == .completed }
        default:
            shownItems = allItems
        }
        tableView.reloadData()
    }

    private func openDetails(for pickupID: String) {
        guard let index = allItems.firstIndex(where: { $0.pickupID == pickupID }) else { return }

        let vc = storyboard?.instantiateViewController(withIdentifier: "PickupDetailsViewController") as! PickupDetailsViewController
        vc.item = allItems[index]

        vc.onStatusChanged = { [weak self] newStatus in
            guard let self else { return }
            self.allItems[index].status = newStatus
            self.applyFilter()
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

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PickupListCardCell", for: indexPath) as? PickupListCardCell else {
            return UITableViewCell()
        }

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

    // Optional: tap on whole cell also opens details
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = shownItems[indexPath.row]
        openDetails(for: item.pickupID)
    }
}

