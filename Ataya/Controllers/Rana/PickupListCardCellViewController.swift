import UIKit

final class PickupListCardCellViewController: UIViewController {

    @IBOutlet weak var statusSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    private struct CardItem {
        let title: String
        let donor: String
        let location: String
        let date: String
        let status: String
        let imageName: String
    }

    private var allItems: [CardItem] = []
    private var shownItems: [CardItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Pickups"

        setupSegmentUI()
        setupTable()

        // ✅ always works
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

        // ✅ Register the cell (no storyboard layout needed)
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
            CardItem(title: "Baby Formula (DON-10)", donor: "Ahmed Saleh (ID: D-26)", location: "Manama, Bahrain", date: "Nov 6 2025", status: "Accepted", imageName: "baby_formula"),
            CardItem(title: "Water 5 Gallon (DON-7)", donor: "Sara Carter (ID: D-29)", location: "A'ali, Bahrain", date: "Nov 6 2025", status: "Pending", imageName: "water_gallon"),
            CardItem(title: "White Rice (DON-99)", donor: "Mohd Jamal (ID: D-150)", location: "Kuwait City, Kuwait", date: "Nov 4 2025", status: "Completed", imageName: "white_rice")
        ]
    }

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        applyFilter()
    }

    private func applyFilter() {
        switch statusSegment.selectedSegmentIndex {
        case 1: shownItems = allItems.filter { $0.status == "Pending" }
        case 2: shownItems = allItems.filter { $0.status == "Accepted" }
        case 3: shownItems = allItems.filter { $0.status == "Completed" }
        default: shownItems = allItems
        }
        tableView.reloadData()
    }

    private func showTempDetails(for item: CardItem) {
        let alert = UIAlertController(title: "View Details",
                                      message: "Not going to details now.\nSelected: \(item.title)\nStatus: \(item.status)",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
            status: item.status,
            imageName: item.imageName
        ) { [weak self] in
            self?.showTempDetails(for: item)
        }

        return cell
    }
}
