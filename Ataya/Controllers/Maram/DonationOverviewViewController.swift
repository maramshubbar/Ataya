//
//  DonationOverviewViewController.swift
//  Ataya
//
//  Created by Maram on 18/12/2025.
//

import UIKit

final class DonationOverviewViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var items: [DonationItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "DonationOverviewCell", bundle: nil),
                           forCellReuseIdentifier: DonationOverviewCell.reuseId)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 190

        // بيانات تجريبية مثل الصورة
        items = [
            DonationItem(title: "Baby Formula (DON-100)",
                         donorText: "Zainab Ali (ID: D-20)",
                         ngoText: "HopPal (ID: N-01)",
                         locationText: "Manama, Bahrain",
                         dateText: "Nov 6 2025",
                         imageName: "aptamil",
                         status: .pending),

            DonationItem(title: "White Rice (DON-99)",
                         donorText: "Mohd Jamal (ID: D-150)",
                         ngoText: "KindWave (ID: N-06)",
                         locationText: "Kuwait City, Kuwait",
                         dateText: "Nov 4 2025",
                         imageName: "rice",
                         status: .approved),

            DonationItem(title: "Flour (DON-98)",
                         donorText: "Lerato Mbeki (ID: D-270)",
                         ngoText: "PureRelief (ID: N-10)",
                         locationText: "Johannesburg, South Africa",
                         dateText: "Nov 6 2025",
                         imageName: "flour",
                         status: .rejected)
        ]
    }
}

extension DonationOverviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DonationOverviewCell.reuseId,
                                                 for: indexPath) as! DonationOverviewCell
        let item = items[indexPath.row]
        cell.configure(item: item)
        cell.selectionStyle = .none
        cell.onViewDetailsTapped = { [weak self] in
            self?.openDetails(item: item)
        }
        return cell
    }
}

extension DonationOverviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openDetails(item: items[indexPath.row])
    }

    private func openDetails(item: DonationItem) {
        // هنا بنفتح صفحة التفاصيل بعدين
    }
}

