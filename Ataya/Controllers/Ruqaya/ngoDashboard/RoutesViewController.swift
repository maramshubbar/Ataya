//
//  RoutesViewController.swift
//  Ataya
//
//  Created by Ruqaya Habib on 29/12/2025.
//

import UIKit

final class RoutesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var filterSegmented: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Model
    struct RouteItem {
        let title: String
        let donor: String
        let location: String
        let date: String
        let time: String
        let priority: String
        let status: Status
        let imageName: String
    }

    enum Status {
        case pending, approved, rejected

        var title: String {
            switch self {
            case .pending: return "Pending"
            case .approved: return "Approved"
            case .rejected: return "Rejected"
            }
        }

        var color: UIColor {
            switch self {
            case .pending:   // FFFBCC
                return UIColor(red: 255/255, green: 251/255, blue: 204/255, alpha: 1)
            case .approved:  // D2F2C1
                return UIColor(red: 210/255, green: 242/255, blue: 193/255, alpha: 1)
            case .rejected:  // F44336 @ 78%
                return UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 0.78)
            }
        }
    }

    // MARK: - Data
    private var allItems: [RouteItem] = [
        .init(
            title: "Baby Formula (DON-10)",
            donor: "Donor: Ahmed Saleh (ID: D-26)",
            location: "Location: Manama, Bahrain",
            date: "Date: Nov 6, 2025",
            time: "Time Window: 09:00 AM – 11:00 AM",
            priority: "Priority: Normal",
            status: .pending,
            imageName: "babyformula"
        ),
        .init(
            title: "Canned Pasta (DON-9)",
            donor: "Donor: Ameer Mohd (ID: D-75)",
            location: "Location: Diraz, Bahrain",
            date: "Date: Nov 6, 2025",
            time: "Time Window: 11:30 AM – 01:00 PM",
            priority: "Priority: Normal",
            status: .pending,
            imageName: "canned-beans"
        ),
        .init(
            title: "Eggs (DON-8)",
            donor: "Donor: Hussain Ali (ID: D-05)",
            location: "Location: Kuwait City, Kuwait",
            date: "Date: Nov 4, 2025",
            time: "Time Window: 08:30 AM – 10:00 AM",
            priority: "Priority: Normal",
            status: .approved,
            imageName: "eggs"
        ),
        .init(
            title: "Water 5 Gallon (DON-7)",
            donor: "Donor: Sara Carter (ID: D-29)",
            location: "Location: A'ali, Bahrain",
            date: "Date: Nov 6, 2025",
            time: "Time Window: 02:00 PM – 04:00 PM",
            priority: "Priority: Urgent",
            status: .rejected,
            imageName: "Img-4"
        )
    ]

    private var filtered: [RouteItem] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        filtered = allItems

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = 186
        tableView.estimatedRowHeight = 186

        filterSegmented.addTarget(self,
                                  action: #selector(filterChanged),
                                  for: .valueChanged)
        
        tableView.contentInset.bottom = 70
        tableView.verticalScrollIndicatorInsets.bottom = 70
    }

    // MARK: - Filter
    @objc private func filterChanged() {
        switch filterSegmented.selectedSegmentIndex {
        case 1:
            filtered = allItems.filter { $0.status == .pending }
        case 2:
            filtered = allItems.filter { $0.status == .rejected }
        case 3:
            filtered = allItems.filter { $0.status == .approved }
        default:
            filtered = allItems
        }
        tableView.reloadData()
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        filtered.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let item = filtered[indexPath.row]

        // MARK: Card
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 8
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.systemGray5.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(card)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
        ])

        // MARK: Labels
        func makeLabel(_ text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor) -> UILabel {
            let l = UILabel()
            l.text = text
            l.font = .systemFont(ofSize: size, weight: weight)
            l.textColor = color
            l.numberOfLines = 1
            l.translatesAutoresizingMaskIntoConstraints = false
            return l
        }

        let titleLabel = makeLabel(item.title, size: 16, weight: .semibold, color: .black)
        let donorLabel = makeLabel(item.donor, size: 13, weight: .regular, color: .systemGray)
        let locationLabel = makeLabel(item.location, size: 13, weight: .regular, color: .systemGray)
        let dateLabel = makeLabel(item.date, size: 13, weight: .regular, color: .systemGray)
        let timeLabel = makeLabel(item.time, size: 13, weight: .regular, color: .systemGray)
        let priorityLabel = makeLabel(item.priority, size: 13, weight: .regular, color: .systemGray)

        // MARK: Status Badge
        let badge = UILabel()
        badge.text = item.status.title
        badge.font = .systemFont(ofSize: 12, weight: .bold)
        badge.textAlignment = .center
        badge.backgroundColor = item.status.color
        badge.layer.cornerRadius = 8
        badge.clipsToBounds = true
        badge.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Image
        let productImageView = UIImageView(image: UIImage(named: item.imageName))
        productImageView.contentMode = .scaleAspectFit
        productImageView.translatesAutoresizingMaskIntoConstraints = false

        [titleLabel, donorLabel, locationLabel,
         dateLabel, timeLabel, priorityLabel,
         badge, productImageView].forEach { card.addSubview($0) }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

            badge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            badge.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            badge.widthAnchor.constraint(equalToConstant: 99),
            badge.heightAnchor.constraint(equalToConstant: 28.52),

            donorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            donorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            locationLabel.topAnchor.constraint(equalTo: donorLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            dateLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            priorityLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            priorityLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            // Image (نازلة شوي لتحت)
            productImageView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            productImageView.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: 12),
            productImageView.widthAnchor.constraint(equalToConstant: 70),
            productImageView.heightAnchor.constraint(equalToConstant: 70)
        ])

        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
