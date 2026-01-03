//  LeaderboardViewController.swift
//  Ataya
//
//  Created by Maram on 19/12/2025.
//

import UIKit
import FirebaseFirestore

final class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var segListFilter: UISegmentedControl! // 7 Days / 6 Month / 1 Year (UI only حاليا)

    enum RowType: String { case donor = "Donor", ngo = "NGO" }

    struct ListRow {
        let imageName: String?
        let name: String
        let countryText: String
        let type: RowType
        let points: Int
    }

    // MARK: - Firebase
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // MARK: - Data
    private var rows: [ListRow] = []

    private let placeholderRows: [ListRow] = [
        .init(imageName: "HopPalImg",  name: "HopPal",        countryText: " Bahrain",        type: .ngo,   points: 2200),
        .init(imageName: "KindWave",   name: "KindWave",      countryText: " Lebanon",        type: .ngo,   points: 1700),
        .init(imageName: "LifeReachImg",  name: "LifeReach",     countryText: " KSA",   type: .ngo,   points: 1600),
        .init(imageName: "AidBridge",  name: "AidBridge",     countryText: " Germany",        type: .ngo,   points: 1200),
        .init(imageName: "PureRelief", name: "PureRelief",    countryText: " Canada",         type: .ngo,   points: 800),

        .init(imageName: "Jassim Ali",     name: "Jassim Ali",    countryText: " Bahrain",        type: .donor, points: 1500),
        .init(imageName: "Henry Beeston",      name: "Henry Beeston", countryText: " UK", type: .donor, points: 1400),
        .init(imageName: "Noor Mohd",       name: "Noor Mohd",     countryText: " India",          type: .donor, points: 900),
        .init(imageName: "Willam Smith",    name: "Willam Smith",  countryText: " US",  type: .donor, points: 500)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableUI()

        segListFilter.addTarget(self, action: #selector(filterChanged), for: .valueChanged)

        loadLeaderboard_PLACEHOLDER()

        // startListeningLeaderboard_FIREBASE()
    }

    deinit { listener?.remove() }

    // MARK: - UI
    private func setupTableUI() {
        tblList.dataSource = self
        tblList.delegate = self
        tblList.separatorStyle = .none
        tblList.backgroundColor = .clear
        tblList.rowHeight = 74
        tblList.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 12, right: 0)
    }

    // MARK: - Filter (placeholder)

    @objc private func filterChanged() {
        loadLeaderboard_PLACEHOLDER()
    }

    // MARK: - ✅ PLACEHOLDER LOADER

    private func loadLeaderboard_PLACEHOLDER() {

        var filtered = placeholderRows

        switch segListFilter.selectedSegmentIndex {
        case 0: // 7 Days
            filtered = placeholderRows.filter { placeholderBucket(for: $0.name) == 0 }
            if filtered.count < 4 { filtered = Array(placeholderRows.prefix(4)) }

        case 1: // 6 Month
            filtered = placeholderRows.filter { placeholderBucket(for: $0.name) != 2 }
            if filtered.count < 6 { filtered = Array(placeholderRows.prefix(6)) }

        case 2: // 1 Year
            filtered = placeholderRows

        default:
            filtered = placeholderRows
        }

        rows = filtered.sorted { $0.points > $1.points }
        tblList.reloadData()
    }

    private func placeholderBucket(for key: String) -> Int {
        let h = abs(key.unicodeScalars.reduce(0) { $0 + Int($1.value) })
        return h % 3
    }

    // MARK: - ✅ FIREBASE
    /*
    private func startListeningLeaderboard_FIREBASE() {
        listener?.remove()

        listener = db.collection("users").addSnapshotListener { [weak self] snap, err in
            guard let self else { return }

            if let err {
                print("❌ Leaderboard listen error:", err.localizedDescription)
                // fallback placeholder
                DispatchQueue.main.async { self.loadLeaderboard_PLACEHOLDER() }
                return
            }

            let docs = snap?.documents ?? []
            var list: [ListRow] = []

            for doc in docs {
                let data = doc.data()

                let roleStr = (data["role"] as? String ?? "").lowercased()
                let type: RowType?
                if roleStr == "donor" { type = .donor }
                else if roleStr == "ngo" { type = .ngo }
                else { type = nil }

                guard let type else { continue }

                let name = (data["name"] as? String)
                    ?? (data["fullName"] as? String)
                    ?? (data["organizationName"] as? String)
                    ?? "—"

                let country = (data["country"] as? String) ?? "—"
                let flag = (data["countryFlag"] as? String) ?? "" // can be empty
                let countryText = flag.isEmpty ? country : "\(flag) \(country)"

                // points
                let points: Int
                if type == .donor {
                    let rewards = data["rewards"] as? [String: Any] ?? [:]
                    points = Self.intValue(rewards["points"])
                } else {
                    let rewardsNgo = data["rewardsNgo"] as? [String: Any] ?? [:]
                    points = Self.intValue(rewardsNgo["points"])
                }

                let imageName = data["avatarAssetName"] as? String // optional
                list.append(.init(imageName: imageName, name: name, countryText: countryText, type: type, points: points))
            }

            list.sort {
                if $0.points != $1.points { return $0.points > $1.points }
                return $0.name.lowercased() < $1.name.lowercased()
            }

            DispatchQueue.main.async {
                self.rows = list
                self.tblList.reloadData()
            }
        }
    }

    private static func intValue(_ any: Any?) -> Int {
        if let i = any as? Int { return i }
        if let d = any as? Double { return Int(d) }
        if let n = any as? NSNumber { return n.intValue }
        if let s = any as? String { return Int(s.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0 }
        return 0
    }


    private func applyFilter_FIREBASE_ByDonationDate() {

        let dateField = "createdAt" // Timestamp in donations

        let now = Date()
        let cal = Calendar.current
        let startDate: Date

        switch segListFilter.selectedSegmentIndex {
        case 0: startDate = cal.date(byAdding: .day, value: -7, to: now) ?? now
        case 1: startDate = cal.date(byAdding: .month, value: -6, to: now) ?? now
        default: startDate = cal.date(byAdding: .year, value: -1, to: now) ?? now
        }

        db.collection("donations")
            .whereField("status", isEqualTo: "completed")
            .whereField(dateField, isGreaterThanOrEqualTo: startDate)
            .getDocuments { [weak self] snap, err in
                guard let self else { return }
                if let err {
                    print("❌ donations date filter error:", err.localizedDescription)
                    return
                }

                let docs = snap?.documents ?? []

                var pointsByUid: [String: Int] = [:]
                var typeByUid: [String: RowType] = [:]

                for doc in docs {
                    let d = doc.data()

                    let donorId = d["donorId"] as? String ?? ""
                    let ngoId   = d["ngoId"] as? String ?? ""

                    if !donorId.isEmpty {
                        pointsByUid[donorId, default: 0] += 100
                        typeByUid[donorId] = .donor
                    }
                    if !ngoId.isEmpty {
                        pointsByUid[ngoId, default: 0] += 100
                        typeByUid[ngoId] = .ngo
                    }
                }

                self.db.collection("users").getDocuments { [weak self] snap2, err2 in
                    guard let self else { return }
                    if let err2 {
                        print("❌ users fetch error:", err2.localizedDescription)
                        return
                    }

                    let uDocs = snap2?.documents ?? []
                    var list: [ListRow] = []

                    for u in uDocs {
                        let uid = u.documentID
                        guard let pts = pointsByUid[uid], let t = typeByUid[uid] else { continue }

                        let data = u.data()

                        let name = (data["name"] as? String)
                            ?? (data["fullName"] as? String)
                            ?? (data["organizationName"] as? String)
                            ?? "—"

                        let country = (data["country"] as? String) ?? "—"
                        let flag = (data["countryFlag"] as? String) ?? ""
                        let countryText = flag.isEmpty ? country : "\(flag) \(country)"

                        let imageName = data["avatarAssetName"] as? String
                        list.append(.init(imageName: imageName, name: name, countryText: countryText, type: t, points: pts))
                    }

                    list.sort { $0.points > $1.points }

                    DispatchQueue.main.async {
                        self.rows = list
                        self.tblList.reloadData()
                    }
                }
            }
    }
    */

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
        // ✅ ADDED: placeholder if imageName not found
        let avatar = UIImage(named: item.imageName ?? "") ?? UIImage(named: "ic_avatar_placeholder")
        img?.image = avatar
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
