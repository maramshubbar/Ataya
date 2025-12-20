//
//  LeaderboardViewController.swift
//  Ataya
//
//  Created by Maram on 19/12/2025.
//

import UIKit

final class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var segListFilter: UISegmentedControl!

    enum RowType: String { case donor = "Donor", ngo = "NGO" }

    struct ListRow {
        let imageName: String?     // asset name (اختياري)
        let name: String
        let countryText: String    // مثال: "🇧🇭 Bahrain"
        let type: RowType
    }

    private var allRows: [ListRow] = [
        .init(imageName: "hopPal",     name: "HopPal",        countryText: "🇧🇭 Bahrain",         type: .ngo),
        .init(imageName: "kindWave",   name: "KindWave",      countryText: "🇱🇧 Lebanon",         type: .ngo),
        .init(imageName: "lifeReach",  name: "LifeReach",     countryText: "🇸🇦 Saudi Arabia",    type: .ngo),
        .init(imageName: "aidBridge",  name: "AidBridge",     countryText: "🇩🇪 Germany",         type: .ngo),
        .init(imageName: "pureRelief", name: "PureRelief",    countryText: "🇨🇦 Canada",          type: .ngo),
        .init(imageName: "jassim",     name: "Jassim Ali",    countryText: "🇧🇭 Bahrain",         type: .donor),
        .init(imageName: "henry",      name: "Henry Beeston", countryText: "🇬🇧 United Kingdom",  type: .donor),
        .init(imageName: "noor",       name: "Noor Mohd",     countryText: "🇮🇳 India",           type: .donor),
        .init(imageName: "william",    name: "Willam Smith",  countryText: "🇺🇸 United States",   type: .donor)
    ]

    private var rows: [ListRow] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSegmentUI()
        setupTableUI()

        rows = allRows
        applyFilter()
    }

    // MARK: - UI

    private func setupSegmentUI() {
        segListFilter.selectedSegmentIndex = 0
        segListFilter.backgroundColor = UIColor(white: 0.93, alpha: 1)
        segListFilter.selectedSegmentTintColor = .white

        segListFilter.setTitleTextAttributes([
            .foregroundColor: UIColor.darkGray,
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
        ], for: .normal)

        segListFilter.setTitleTextAttributes([
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
        ], for: .selected)

        segListFilter.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
    }

    private func setupTableUI() {
        tblList.dataSource = self
        tblList.delegate = self

        tblList.separatorStyle = .none
        tblList.backgroundColor = .clear

        // يعطي نفس إحساس الصورة
        tblList.rowHeight = 74
        tblList.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 12, right: 0)
    }

    // MARK: - Filter

    @objc private func filterChanged() {
        applyFilter()
    }

    private func applyFilter() {
        switch segListFilter.selectedSegmentIndex {
        case 1: rows = allRows.filter { $0.type == .donor } // Donors
        case 2: rows = allRows.filter { $0.type == .ngo }   // NGOs
        default: rows = allRows                              // All
        }
        tblList.reloadData()
    }

    // MARK: - Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        let item = rows[indexPath.row]

        let img = cell.contentView.viewWithTag(10) as? UIImageView
        let lblName = cell.contentView.viewWithTag(1) as? UILabel
        let lblCountry = cell.contentView.viewWithTag(2) as? UILabel
        let lblType = cell.contentView.viewWithTag(3) as? UILabel

        // ✅ Image in ContentView (tag = 10)
        img?.image = UIImage(named: item.imageName ?? "ic_avatar_placeholder")
        img?.layer.cornerRadius = 18
        img?.clipsToBounds = true
        img?.contentMode = .scaleAspectFill

        // ✅ Labels
        lblName?.text = item.name
        lblCountry?.text = item.countryText
        lblType?.text = item.type.rawValue

        // ✅ Keep your card styling logic, BUT apply it ONLY if tag=99 exists
        if let card = cell.contentView.viewWithTag(99) {
            card.backgroundColor = .white
            card.layer.cornerRadius = 12
            card.layer.borderWidth = 1
            card.layer.borderColor = UIColor(white: 0.85, alpha: 1).cgColor
            card.layer.masksToBounds = true
        } else {
            // No card view (as you want) -> keep everything clear
            cell.contentView.backgroundColor = .clear
        }

        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        return cell
    }
}
