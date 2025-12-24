////
////  AnalyticsViewController.swift
////  Ataya
////
////  Created by Maram on 02/12/2025.
////
////
////  AnalyticsViewController.swift
////  Ataya
////
////  Created by Maram on 02/12/2025.
////
//
//import UIKit
//import FirebaseFirestore
//import DGCharts   // إذا ما اشتغل عندج، بدليه إلى: import Charts
//
//final class AnalyticsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//
//    @IBOutlet weak var tblCountries: UITableView!
//    @IBOutlet weak var tblList: UITableView!
//    @IBOutlet weak var segListFilter: UISegmentedControl!
//
//    // ✅ SegmentedControl حق 7 Days / 6 Months / 1 Year (اربطية من storyboard)
//    @IBOutlet weak var segTimeRange: UISegmentedControl!
//
//    @IBOutlet weak var lblRegisteredUsers: UILabel!
//    @IBOutlet weak var lblTotalDonations: UILabel!
//    @IBOutlet weak var lblVerifiedNGOs: UILabel!
//
//    // ✅ chart container (اربطية من storyboard)
//    @IBOutlet weak var chartContainer: UIView!
//
//    enum RowType: String { case donor = "Donor", ngo = "NGO" }
//
//    struct ListRow {
//        let name: String
//        let location: String
//        let type: RowType
//    }
//
//    // ✅ Countries = amountUSD + percent (مثل الصورة)
//    struct CountryRow {
//        let name: String
//        let amountUSD: Double
//        let percent: Int
//    }
//
//    private let db = Firestore.firestore()
//    private var listeners: [ListenerRegistration] = []
//    private let ngoApplicationsCol = "ngo_applications"
//    private let donationsCol = "donations"
//    private let usersCol = "users"
//
//    private var countriesRows: [CountryRow] = []
//    private var allRows: [ListRow] = []
//    private var rows: [ListRow] = []
//
//    private var cachedDonors: [ListRow] = []
//    private var cachedNGOs: [ListRow] = []
//
//    private var usersCountFromUsers: Int = 0
//    private var usersCountFallback: Int = 0
//
//    private let dotColors: [UIColor] = [
//        UIColor(red: 102/255, green: 167/255, blue: 255/255, alpha: 1),
//        UIColor(red: 111/255, green: 201/255, blue: 168/255, alpha: 1),
//        UIColor(red: 255/255, green: 169/255, blue: 97/255,  alpha: 1),
//        UIColor(red: 221/255, green: 203/255, blue: 242/255, alpha: 1)
//    ]
//
//    // ✅ Line chart
//    private let lineChart = LineChartView()
//
//    private static let monthFormatter: DateFormatter = {
//        let f = DateFormatter()
//        f.dateFormat = "MMM" // Jan, Feb...
//        return f
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Countries table
//        tblCountries.dataSource = self
//        tblCountries.delegate = self
//        tblCountries.isScrollEnabled = false
//        tblCountries.rowHeight = 44
//        tblCountries.separatorStyle = .none
//        tblCountries.backgroundColor = .clear
//
//        // List table
//        tblList.dataSource = self
//        tblList.delegate = self
//        tblList.isScrollEnabled = false
//        tblList.rowHeight = 64
//        tblList.separatorStyle = .none
//        tblList.backgroundColor = .clear
//
//        // Segmented (All / Donors / NGOs)
//        segListFilter.selectedSegmentIndex = 0
//        segListFilter.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
//
//        // ✅ Time range (7 Days / 6 Months / 1 Year) — default = 6 Months مثل الصورة
//        segTimeRange.selectedSegmentIndex = 1
//        segTimeRange.addTarget(self, action: #selector(timeRangeChanged), for: .valueChanged)
//
//        setupChart()
//        startListening()
//    }
//
//    deinit {
//        listeners.forEach { $0.remove() }
//        listeners.removeAll()
//    }
//
//    // MARK: - Chart setup
//    private func setupChart() {
//        guard chartContainer != nil else { return }
//
//        lineChart.translatesAutoresizingMaskIntoConstraints = false
//        chartContainer.addSubview(lineChart)
//
//        NSLayoutConstraint.activate([
//            lineChart.leadingAnchor.constraint(equalTo: chartContainer.leadingAnchor),
//            lineChart.trailingAnchor.constraint(equalTo: chartContainer.trailingAnchor),
//            lineChart.topAnchor.constraint(equalTo: chartContainer.topAnchor),
//            lineChart.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor)
//        ])
//
//        lineChart.rightAxis.enabled = false
//        lineChart.legend.enabled = false
//        lineChart.chartDescription.enabled = false
//
//        lineChart.xAxis.labelPosition = .bottom
//        lineChart.xAxis.drawGridLinesEnabled = false
//
//        lineChart.leftAxis.axisMinimum = 0
//        lineChart.leftAxis.granularity = 1
//        lineChart.leftAxis.drawGridLinesEnabled = true
//
//        // ✅ محور Y بالدولار
//        lineChart.leftAxis.valueFormatter = DollarAxisFormatter()
//
//        lineChart.setScaleEnabled(false)
//        lineChart.pinchZoomEnabled = false
//        lineChart.doubleTapToZoomEnabled = false
//    }
//
//    // ✅ chart = مجموع amountUSD لكل شهر
//    private func updateMonthlyChart(from docs: [QueryDocumentSnapshot]) {
//        var monthTotalsUSD: [String: Double] = [:]
//
//        for doc in docs {
//            let data = doc.data()
//
//            let amountUSD = (data["amountUSD"] as? Double)
//                ?? (data["amountUSD"] as? NSNumber)?.doubleValue
//                ?? 0
//
//            if let ts = data["createdAt"] as? Timestamp {
//                let month = Self.monthFormatter.string(from: ts.dateValue())
//                monthTotalsUSD[month, default: 0] += amountUSD
//            }
//        }
//
//        let orderedMonths = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
//        let months = orderedMonths.filter { monthTotalsUSD[$0] != nil }
//
//        if months.isEmpty {
//            lineChart.data = nil
//            lineChart.notifyDataSetChanged()
//            return
//        }
//
//        var entries: [ChartDataEntry] = []
//        for (i, m) in months.enumerated() {
//            entries.append(ChartDataEntry(x: Double(i), y: monthTotalsUSD[m] ?? 0))
//        }
//
//        let set = LineChartDataSet(entries: entries, label: "")
//        set.drawCirclesEnabled = false
//        set.mode = .linear
//        set.lineWidth = 3
//        set.drawValuesEnabled = false
//        set.colors = [UIColor(red: 255/255, green: 216/255, blue: 63/255, alpha: 1)]
//
//        let data = LineChartData(dataSet: set)
//        lineChart.data = data
//
//        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
//        lineChart.xAxis.granularity = 1
//
//        lineChart.leftAxis.valueFormatter = DollarAxisFormatter()
//        lineChart.leftAxis.axisMinimum = 0
//
//        lineChart.notifyDataSetChanged()
//    }
//
//    // MARK: - Firestore
//    private func startListening() {
//        listeners.forEach { $0.remove() }
//        listeners.removeAll()
//
//        listenUsersCountFuture()
//        listenNgoApplications()
//        listenDonations()
//    }
//
//    // ✅ تغيير المدة يعيد تحميل الداتا
//    @objc private func timeRangeChanged() {
//        startListening()
//    }
//
//    private func selectedStartDate() -> Date {
//        let now = Date()
//        switch segTimeRange.selectedSegmentIndex {
//        case 0: // 7 Days
//            return Calendar.current.date(byAdding: .day, value: -7, to: now) ?? Date.distantPast
//        case 2: // 1 Year
//            return Calendar.current.date(byAdding: .year, value: -1, to: now) ?? Date.distantPast
//        default: // 6 Months
//            return Calendar.current.date(byAdding: .month, value: -6, to: now) ?? Date.distantPast
//        }
//    }
//
//    private func listenUsersCountFuture() {
//        let l = db.collection(usersCol)
//            .addSnapshotListener { [weak self] snap, err in
//                guard let self else { return }
//
//                if let err = err {
//                    print("⚠️ users listener error:", err.localizedDescription)
//                    return
//                }
//
//                self.usersCountFromUsers = snap?.documents.count ?? 0
//                DispatchQueue.main.async {
//                    self.updateRegisteredUsersLabel()
//                }
//            }
//
//        listeners.append(l)
//    }
//
//    private func listenNgoApplications() {
//        let l = db.collection(ngoApplicationsCol)
//            .addSnapshotListener { [weak self] snap, err in
//                guard let self else { return }
//                if let err = err {
//                    print("❌ ngo_applications error:", err.localizedDescription)
//                    return
//                }
//
//                let docs = snap?.documents ?? []
//
//                let verifiedCount = docs.filter { doc in
//                    let status = (doc.data()["status"] as? String ?? "").lowercased()
//                    return status == "verified"
//                }.count
//
//                let ngoRows: [ListRow] = docs.map { doc in
//                    let data = doc.data()
//                    let name = self.stringValue(data, keys: ["name", "ngoName"]).ifEmpty("NGO")
//                    let location = self.stringValue(data, keys: ["country", "location", "city"]).ifEmpty("—")
//                    return ListRow(name: name, location: location, type: .ngo)
//                }
//
//                DispatchQueue.main.async {
//                    self.lblVerifiedNGOs.text = "\(verifiedCount)"
//                }
//
//                self.cachedNGOs = ngoRows
//                self.mergeRowsAndReload()
//            }
//
//        listeners.append(l)
//    }
//
//    private func listenDonations() {
//        let startDate = selectedStartDate()
//
//        let l = db.collection(donationsCol)
//            .whereField("createdAt", isGreaterThanOrEqualTo: Timestamp(date: startDate))
//            .addSnapshotListener { [weak self] snap, err in
//                guard let self else { return }
//                if let err = err {
//                    print("❌ donations error:", err.localizedDescription)
//                    return
//                }
//
//                let docs = snap?.documents ?? []
//
//                // ✅ Total Donations = عدد الدوكومنتس (يبقى عدد)
//                let totalDonationsCount = docs.count
//
//                // ✅ Countries = مجموع amountUSD لكل دولة
//                var byCountryUSD: [String: Double] = [:]
//                var totalUSD: Double = 0
//
//                // ✅ fallback Registered Users = unique donors
//                var uniqueDonors = Set<String>()
//                var donorRowsDict: [String: ListRow] = [:]
//
//                for d in docs {
//                    let data = d.data()
//
//                    let amountUSD = (data["amountUSD"] as? Double)
//                        ?? (data["amountUSD"] as? NSNumber)?.doubleValue
//                        ?? 0
//                    totalUSD += amountUSD
//
//                    let country = self.stringValue(data, keys: ["country"])
//                        .ifEmpty(self.extractCountry(from: self.stringValue(data, keys: ["location", "address"])))
//                        .ifEmpty("Unknown")
//
//                    byCountryUSD[country, default: 0] += amountUSD
//
//                    let donorCode = self.stringValue(data, keys: ["donorCode", "donorId", "reporterCode", "userCode"])
//                    let donorName = self.stringValue(data, keys: ["donorName", "reporter", "name", "fullName"]).ifEmpty("Donor")
//                    let donorLoc  = self.stringValue(data, keys: ["donorCountry", "donorLocation", "country", "location"]).ifEmpty("—")
//
//                    let key = donorCode.isEmpty ? donorName.lowercased() : donorCode
//                    uniqueDonors.insert(key)
//
//                    if donorRowsDict[key] == nil {
//                        donorRowsDict[key] = ListRow(
//                            name: donorName,
//                            location: self.extractCountry(from: donorLoc).ifEmpty(donorLoc),
//                            type: .donor
//                        )
//                    }
//                }
//
//                // ✅ Countries rows (amount + %)
//                let safeTotal = max(totalUSD, 0.000001)
//                let cRows = byCountryUSD
//                    .map { (name: $0.key, amountUSD: $0.value) }
//                    .sorted { $0.amountUSD > $1.amountUSD }
//                    .map { item -> CountryRow in
//                        let pct = Int(round((item.amountUSD / safeTotal) * 100))
//                        return CountryRow(name: item.name, amountUSD: item.amountUSD, percent: pct)
//                    }
//
//                DispatchQueue.main.async {
//                    self.lblTotalDonations.text = self.formatNumber(totalDonationsCount)
//
//                    self.usersCountFallback = uniqueDonors.count
//                    self.updateRegisteredUsersLabel()
//
//                    self.countriesRows = cRows
//                    self.tblCountries.reloadData()
//
//                    // ✅ تحديث الجارت (USD)
//                    self.updateMonthlyChart(from: docs)
//                }
//
//                self.cachedDonors = Array(donorRowsDict.values).prefix(50).map { $0 }
//                self.mergeRowsAndReload()
//            }
//
//        listeners.append(l)
//    }
//
//    private func updateRegisteredUsersLabel() {
//        let valueToShow = (usersCountFromUsers > 0) ? usersCountFromUsers : usersCountFallback
//        lblRegisteredUsers.text = formatNumber(valueToShow)
//    }
//
//    private func mergeRowsAndReload() {
//        let merged = cachedNGOs + cachedDonors
//        DispatchQueue.main.async {
//            self.allRows = merged
//            self.applyListFilterAndReload()
//        }
//    }
//
//    // MARK: - Filters
//    @objc private func filterChanged() {
//        applyListFilterAndReload()
//    }
//
//    private func applyListFilterAndReload() {
//        switch segListFilter.selectedSegmentIndex {
//        case 1: rows = allRows.filter { $0.type == .donor }
//        case 2: rows = allRows.filter { $0.type == .ngo }
//        default: rows = allRows
//        }
//        tblList.reloadData()
//    }
//
//    // MARK: - UITableView
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if tableView == tblCountries { return countriesRows.count }
//        if tableView == tblList { return rows.count }
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        if tableView == tblCountries {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
//            let item = countriesRows[indexPath.row]
//
//            let dot = cell.contentView.viewWithTag(1)
//            let nameLbl = cell.contentView.viewWithTag(2) as? UILabel
//            let pctLbl  = cell.contentView.viewWithTag(3) as? UILabel
//            let amtLbl  = cell.contentView.viewWithTag(4) as? UILabel
//
//            nameLbl?.text = item.name
//            amtLbl?.text  = formatUSD(item.amountUSD)   // ✅ $ مثل الصورة
//            pctLbl?.text  = "\(item.percent)%"
//
//            dot?.backgroundColor = dotColors[indexPath.row % dotColors.count]
//            dot?.layer.cornerRadius = 10
//            dot?.layer.masksToBounds = true
//
//            cell.selectionStyle = .none
//            cell.backgroundColor = .clear
//            return cell
//        }
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
//        let item = rows[indexPath.row]
//
//        let img = cell.contentView.viewWithTag(10) as? UIImageView
//        img?.image = UIImage(named: "ic_report_center")
//
//        let lblName = cell.contentView.viewWithTag(1) as? UILabel
//        let lblLocation = cell.contentView.viewWithTag(2) as? UILabel
//        let lblType = cell.contentView.viewWithTag(3) as? UILabel
//
//        lblName?.text = item.name
//        lblLocation?.text = item.location
//        lblType?.text = item.type.rawValue
//
//        cell.selectionStyle = .none
//        cell.backgroundColor = .clear
//        return cell
//    }
//
//    // MARK: - Helpers
//    private func stringValue(_ data: [String: Any], keys: [String]) -> String {
//        for k in keys {
//            if let s = data[k] as? String, !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                return s
//            }
//        }
//        return ""
//    }
//
//    private func extractCountry(from location: String) -> String {
//        let parts = location.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//        return parts.last.map { String($0) } ?? ""
//    }
//
//    private func formatNumber(_ value: Int) -> String {
//        let nf = NumberFormatter()
//        nf.numberStyle = .decimal
//        return nf.string(from: NSNumber(value: value)) ?? "\(value)"
//    }
//
//    private func formatUSD(_ value: Double) -> String {
//        let nf = NumberFormatter()
//        nf.numberStyle = .currency
//        nf.currencySymbol = "$"
//        nf.maximumFractionDigits = 0
//        return nf.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
//    }
//}
//
//private extension String {
//    func ifEmpty(_ fallback: String) -> String {
//        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? fallback : self
//    }
//}
//
//// ✅ تنسيق محور Y للدولار
//final class DollarAxisFormatter: AxisValueFormatter {
//    private let nf: NumberFormatter = {
//        let n = NumberFormatter()
//        n.numberStyle = .currency
//        n.currencySymbol = "$"
//        n.maximumFractionDigits = 0
//        return n
//    }()
//
//    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//        return nf.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
//    }
//}
