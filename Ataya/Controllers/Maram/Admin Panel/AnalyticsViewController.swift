//
//  AnalyticsViewController.swift
//  Ataya
//
//  Created by Maram on 02/12/2025.
//
//


import UIKit
import FirebaseFirestore
import DGCharts

final class AnalyticsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var analyticsScrollView: UIScrollView?

    @IBOutlet weak var tblCountries: UITableView?
    @IBOutlet weak var tblList: UITableView?

    @IBOutlet weak var segListFilter: UISegmentedControl?
    @IBOutlet weak var segTimeRange: UISegmentedControl?   // 7 Days / 6 Months / 1 Year

    @IBOutlet weak var lblRegisteredUsers: UILabel?
    @IBOutlet weak var lblTotalDonations: UILabel?
    @IBOutlet weak var lblVerifiedNGOs: UILabel?

    @IBOutlet weak var cardVerified: UIView?
    @IBOutlet weak var chartContainer: UIView?
    @IBOutlet weak var cardTotal: UIView?
    @IBOutlet weak var cardRegistered: UIView?

    // ==========================================================
    // Donation Categories UI
    // ==========================================================
    @IBOutlet weak var donationCategoriesSectionView: UIView?

    @IBOutlet weak var lblFoodPct: UILabel?
    @IBOutlet weak var lblBasketsPct: UILabel?
    @IBOutlet weak var lblCampaignPct: UILabel?

    @IBOutlet weak var barFoodView: UIView?
    @IBOutlet weak var barBasketsView: UIView?
    @IBOutlet weak var barCampaignView: UIView?

    @IBOutlet weak var barFoodWidth: NSLayoutConstraint?
    @IBOutlet weak var barBasketsWidth: NSLayoutConstraint?
    @IBOutlet weak var barCampaignWidth: NSLayoutConstraint?

    // Export PDF
    @IBAction func exportCategoriesPDFTapped(_ sender: UIButton) {
        sender.isHidden = true
        exportAnalyticsScreenPDF(anchor: sender)
        sender.isHidden = false
    }

    private var lastCategoryPct: (food: Double, baskets: Double, campaign: Double) = (0, 0, 0)

    private struct CategoryRowUI {
        let nameLabel: UILabel
        let percentLabel: UILabel
        let trackView: UIView
        let fillView: UIView
        let fillWidth: NSLayoutConstraint
    }
    private var builtCategoryRows: [String: CategoryRowUI] = [:]

    // MARK: - Leaderboard models

    enum RowType: String { case donor = "Donor", ngo = "NGO" }

    struct ListRow {
        let imageName: String?
        let name: String
        let countryText: String
        let type: RowType
        let points: Int

        init(imageName: String?, name: String, countryText: String, type: RowType, points: Int = 0) {
            self.imageName = imageName
            self.name = name
            self.countryText = countryText
            self.type = type
            self.points = points
        }
    }

    // Countries = COUNT + percent
    struct CountryRow {
        let name: String
        let count: Int
        let percent: Int
    }

    private var countriesRows: [CountryRow] = []

    private let dotColors: [UIColor] = [
        UIColor(red: 102/255, green: 167/255, blue: 255/255, alpha: 1),
        UIColor(red: 111/255, green: 201/255, blue: 168/255, alpha: 1),
        UIColor(red: 255/255, green: 169/255, blue: 97/255,  alpha: 1),
        UIColor(red: 221/255, green: 203/255, blue: 242/255, alpha: 1),
        UIColor(red: 250/255, green: 220/255, blue: 120/255, alpha: 1)
    ]

    private let useLeaderboardPlaceholderOnly = true

    private let placeholderAllRows: [ListRow] = [
        .init(imageName: "HopPalImg",    name: "HopPal",        countryText: " Bahrain",        type: .ngo,   points: 2200),
        .init(imageName: "KindWave",     name: "KindWave",      countryText: " Lebanon",        type: .ngo,   points: 1700),
        .init(imageName: "LifeReachImg", name: "LifeReach",     countryText: " KSA",   type: .ngo,   points: 1600),
        .init(imageName: "AidBridge",    name: "AidBridge",     countryText: " Germany",        type: .ngo,   points: 1200),
        .init(imageName: "PureRelief",   name: "PureRelief",    countryText: " Canada",         type: .ngo,   points: 800),

        // ✅ donors placeholder images
        .init(imageName: "Jassim Ali", name: "Jassim Ali",    countryText: " Bahrain",        type: .donor, points: 1500),
        .init(imageName: "Henry Beeston", name: "Henry Beeston", countryText: " UK", type: .donor, points: 1400),
        .init(imageName: "Noor Mohd", name: "Noor Mohd",     countryText: " India",          type: .donor, points: 900),
        .init(imageName: "Willam Smith", name: "Willam Smith",  countryText: " US",  type: .donor, points: 500)
    ]

    // MARK: - Firestore

    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []

    private let usersCol = "users"
    private let donationsCol = "donations"
    private let ngoApplicationsCol = "ngo_applications"

    private let campaignsCol = "campaigns"
    private let basketsCol = "baskets"

    private let pickupsCol = "pickups"

    // Latest docs
    private var latestDonationDocs: [QueryDocumentSnapshot] = []
    private var latestCampaignDocs: [QueryDocumentSnapshot] = []
    private var latestBasketDocs: [QueryDocumentSnapshot] = []
    private var latestNgoDocs: [QueryDocumentSnapshot] = []

    private var latestPickupDocs: [QueryDocumentSnapshot] = []

    // Leaderboard cache
    private var allRows: [ListRow] = []
    private var rows: [ListRow] = []
    private var cachedDonors: [ListRow] = []
    private var cachedNGOs: [ListRow] = []

    private var usersCountFromUsers: Int = 0
    private var usersCountFallback: Int = 0

    // MARK: - Chart (Counts)

    private let lineChart = LineChartView()

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM"
        return f
    }()

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "E"
        return f
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Donation Categories UI
        setupDonationCategoriesUI()
        updateDonationCategoriesUI(food: 0, baskets: 0, campaign: 0, animated: false)

        // Tables + segments
//        setupSegmentUI()
        setupListTableUI()
        setupCountriesTableUI()

        segListFilter?.selectedSegmentIndex = 0
        segListFilter?.addTarget(self, action: #selector(filterChanged), for: .valueChanged)

        segTimeRange?.selectedSegmentIndex = 1 // default 6 months
        segTimeRange?.addTarget(self, action: #selector(timeRangeChanged), for: .valueChanged)

        //  PLACEHOLDER leaderboard الآن
        loadLeaderboard_PLACEHOLDER()

        setupChart()
        startListening()
    }

    deinit {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        cardRegistered?.applyCardShadow(cornerRadius: 20)
        cardTotal?.applyCardShadow(cornerRadius: 20)
        cardVerified?.applyCardShadow(cornerRadius: 20)

        applyCategoryBarsFromLastPct(animated: false)
    }

    // ==========================================================
    // LEADERBOARD PLACEHOLDER LOADER
    // ==========================================================
    private func loadLeaderboard_PLACEHOLDER() {
        allRows = placeholderAllRows.sorted { $0.points > $1.points }
        applyListFilterAndReload()
    }

    // MARK: - Listening

    private func startListening() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()

        // Registered Users = users where role IN ["donor", "ngo"] (exclude admin)
        listeners.append(
            db.collection(usersCol)
                .whereField("role", in: ["donor", "ngo"])
                .addSnapshotListener { [weak self] snap, _ in
                    guard let self else { return }
                    self.usersCountFromUsers = snap?.documents.count ?? 0
                    DispatchQueue.main.async { self.updateRegisteredUsersLabel() }
                }
        )

        listeners.append(
            db.collection(ngoApplicationsCol).addSnapshotListener { [weak self] snap, _ in
                guard let self else { return }
                self.latestNgoDocs = snap?.documents ?? []
                self.recomputeNgoAndLeaderboard()
            }
        )

        listeners.append(
            db.collection(donationsCol).addSnapshotListener { [weak self] snap, _ in
                guard let self else { return }
                self.latestDonationDocs = snap?.documents ?? []
                self.recomputeAllFromLatest()
            }
        )

        listeners.append(
            db.collection(basketsCol).addSnapshotListener { [weak self] snap, _ in
                guard let self else { return }
                self.latestBasketDocs = snap?.documents ?? []
                self.recomputeAllFromLatest()
            }
        )

        listeners.append(
            db.collection(campaignsCol).addSnapshotListener { [weak self] snap, _ in
                guard let self else { return }
                self.latestCampaignDocs = snap?.documents ?? []
                self.recomputeAllFromLatest()
            }
        )

        // ✅✅✅ NEW: pickups listener (country from pickups.location)
        listeners.append(
            db.collection(pickupsCol).addSnapshotListener { [weak self] snap, _ in
                guard let self else { return }
                self.latestPickupDocs = snap?.documents ?? []
                self.recomputeAllFromLatest()
            }
        )
    }

    @objc private func timeRangeChanged() {
        recomputeAllFromLatest()
    }

    private func selectedStartDate() -> Date {
        let now = Date()
        let idx = segTimeRange?.selectedSegmentIndex ?? 1
        switch idx {
        case 0: return Calendar.current.date(byAdding: .day, value: -7, to: now) ?? Date.distantPast
        case 2: return Calendar.current.date(byAdding: .year, value: -1, to: now) ?? Date.distantPast
        default: return Calendar.current.date(byAdding: .month, value: -6, to: now) ?? Date.distantPast
        }
    }

    // MARK: - Recompute (Counts)

    private func recomputeAllFromLatest() {
        let startDate = selectedStartDate()

        let donationDocsInRange = latestDonationDocs.filter { doc in
            (extractDocDate(doc.data()) ?? Date.distantPast) >= startDate
        }
        let basketDocsInRange = latestBasketDocs.filter { doc in
            (extractDocDate(doc.data()) ?? Date.distantPast) >= startDate
        }
        let campaignDocsInRange = latestCampaignDocs.filter { doc in
            (extractDocDate(doc.data()) ?? Date.distantPast) >= startDate
        }

        // ✅ Top cards
        DispatchQueue.main.async {
            self.lblTotalDonations?.text = self.formatNumber(donationDocsInRange.count) // Total Donations = donations فقط
            self.updateRegisteredUsersLabel()
        }

        // ✅ Donation Categories = counts by collections
        let foodCount = donationDocsInRange.count
        let basketsCount = basketDocsInRange.count
        let campaignCount = campaignDocsInRange.count

        DispatchQueue.main.async {
            self.updateDonationCategoriesUI(
                food: foodCount,
                baskets: basketsCount,
                campaign: campaignCount,
                animated: true
            )
        }

        // Countries list:
        // NOW: Take country from pickups.location (if pickups exist)
        let allDocsForCountriesFallback = donationDocsInRange + basketDocsInRange + campaignDocsInRange
        recomputeCountriesFromPickupsLocationOrFallback(fallbackDocs: allDocsForCountriesFallback)

        // Chart = (donations + baskets + campaigns) counts over time
        let allDocsForChart = donationDocsInRange + basketDocsInRange + campaignDocsInRange
        DispatchQueue.main.async {
            self.updateOverviewChartCounts(from: allDocsForChart)
        }

        // Donors (for leaderboard) from DONATIONS only
        var uniqueDonors = Set<String>()
        var donorRowsDict: [String: ListRow] = [:]

        for d in donationDocsInRange {
            let data = d.data()

            let donorCode = stringValue(data, keys: ["donorCode", "donorId", "reporterCode", "userCode"])
            let donorName = stringValue(data, keys: ["donorName", "reporter", "name", "fullName"]).ifEmpty("Donor")

            let donorLocRaw = stringValue(data, keys: ["donorCountry", "donorLocation", "country", "location"]).ifEmpty("Unknown")
            let donorCountry = extractCountry(from: donorLocRaw).ifEmpty(donorLocRaw)

            let key = donorCode.isEmpty ? donorName.lowercased() : donorCode
            uniqueDonors.insert(key)

            if donorRowsDict[key] == nil {
                donorRowsDict[key] = ListRow(
                    imageName: nil,
                    name: donorName,
                    countryText: countryText(from: donorCountry),
                    type: .donor,
                    points: 0
                )
            }
        }

        self.cachedDonors = Array(donorRowsDict.values).prefix(50).map { $0 }

        DispatchQueue.main.async {
            self.usersCountFallback = uniqueDonors.count
            self.updateRegisteredUsersLabel()
        }

        recomputeNgoAndLeaderboard()
    }

    private func recomputeCountriesFromPickupsLocationOrFallback(fallbackDocs: [QueryDocumentSnapshot]) {

        let startDate = selectedStartDate()

        // pickups within time range (uses pickup date if exists, else createdAt)
        let pickupsInRange = latestPickupDocs.filter { doc in
            let d = extractPickupDate(doc.data()) ?? extractDocDate(doc.data()) ?? Date.distantPast
            return d >= startDate
        }

        // If we have pickups -> use them
        if !pickupsInRange.isEmpty {
            recomputeCountriesFromPickupLocationDocs(pickupsInRange)
            return
        }

        // fallback to old logic if pickups empty
        recomputeCountries(from: fallbackDocs)
    }

    private func recomputeCountriesFromPickupLocationDocs(_ docs: [QueryDocumentSnapshot]) {

        var byCountryCount: [String: Int] = [:]

        for d in docs {
            let data = d.data()

            // location is inside pickups
            let loc = stringValue(data, keys: ["location"]).ifEmpty("Unknown")
            let country = detectCountryFromLocation(loc).ifEmpty("Unknown")

            byCountryCount[country, default: 0] += 1
        }

        let total = max(docs.count, 1)

        let rows = byCountryCount
            .map { (name: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .map { item -> CountryRow in
                let pct = Int(round((Double(item.count) / Double(total)) * 100))
                return CountryRow(name: item.name, count: item.count, percent: pct)
            }

        DispatchQueue.main.async {
            self.countriesRows = Array(rows.prefix(5))
            self.tblCountries?.reloadData()
        }
    }

    // Optional: pickup date fields (if you have)
    private func extractPickupDate(_ data: [String: Any]) -> Date? {
        if let ts = data["pickupAt"] as? Timestamp { return ts.dateValue() }
        if let ts = data["pickedUpAt"] as? Timestamp { return ts.dateValue() }
        if let ts = data["pickupDate"] as? Timestamp { return ts.dateValue() }
        if let ts = data["scheduledAt"] as? Timestamp { return ts.dateValue() }
        return nil
    }

    // Detect country from pickups.location string
    // Works with: "Manama, Bahrain" OR "Bahrain" OR "UK" OR "KSA"
    private func detectCountryFromLocation(_ location: String) -> String {
        let cleaned = location.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.isEmpty { return "" }

        // split by common separators
        let tokens = cleaned
            .replacingOccurrences(of: "\n", with: " ")
            .components(separatedBy: CharacterSet(charactersIn: ",-|–—•/"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // usually last part is country
        for t in tokens.reversed() {
            let key = t.lowercased()

            // known short codes
            if key == "ksa" { return "KSA" }
            if key == "uk" { return "UK" }
            if key == "us" { return "US" }
            if key == "usa" { return "USA" }

            // if it maps to a flag, accept it as a country name
            if flagEmoji(forCountryName: t) != "" { return t }
        }

        // fallback: comma-last extraction
        let commaBased = extractCountry(from: cleaned)
        if !commaBased.isEmpty { return commaBased }

        return cleaned
    }
    
    private func recomputeCountries(from docs: [QueryDocumentSnapshot]) {
        var byCountryCount: [String: Int] = [:]

        for d in docs {
            let data = d.data()

            let raw = stringValue(data, keys: ["country", "donorCountry", "ngoCountry"])
                .ifEmpty(extractCountry(from: stringValue(data, keys: ["location", "address", "city"])))
                .ifEmpty("Unknown")

            byCountryCount[raw, default: 0] += 1
        }

        let total = max(docs.count, 1)

        let rows = byCountryCount
            .map { (name: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .map { item -> CountryRow in
                let pct = Int(round((Double(item.count) / Double(total)) * 100))
                return CountryRow(name: item.name, count: item.count, percent: pct)
            }

        DispatchQueue.main.async {
            self.countriesRows = Array(rows.prefix(5))
            self.tblCountries?.reloadData()
        }
    }

    private func recomputeNgoAndLeaderboard() {
        let verifiedCount = latestNgoDocs.filter { doc in
            let status = (doc.data()["status"] as? String ?? "").lowercased()
            return status == "verified"
        }.count

        DispatchQueue.main.async {
            self.lblVerifiedNGOs?.text = "\(verifiedCount)"
        }

        if useLeaderboardPlaceholderOnly { return }

        let ngoRows: [ListRow] = latestNgoDocs.map { doc in
            let data = doc.data()
            let name = stringValue(data, keys: ["name", "ngoName"]).ifEmpty("NGO")

            let rawCountry = stringValue(data, keys: ["country"])
                .ifEmpty(extractCountry(from: stringValue(data, keys: ["location", "city", "address"])))
                .ifEmpty("Unknown")

            return ListRow(
                imageName: nil,
                name: name,
                countryText: countryText(from: rawCountry),
                type: .ngo,
                points: 0
            )
        }

        self.cachedNGOs = ngoRows
        mergeRowsAndReload()
    }

    private func updateRegisteredUsersLabel() {
        let valueToShow = (usersCountFromUsers > 0) ? usersCountFromUsers : usersCountFallback
        lblRegisteredUsers?.text = formatNumber(valueToShow)
    }

    private func mergeRowsAndReload() {
        if useLeaderboardPlaceholderOnly { return }

        let merged = cachedNGOs + cachedDonors
        DispatchQueue.main.async {
            self.allRows = merged.isEmpty ? self.placeholderAllRows : merged
            self.applyListFilterAndReload()
        }
    }

    // MARK: - Chart (Counts)

    private func setupChart() {
        guard let container = chartContainer else { return }

        lineChart.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(lineChart)

        NSLayoutConstraint.activate([
            lineChart.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            lineChart.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            lineChart.topAnchor.constraint(equalTo: container.topAnchor),
            lineChart.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        lineChart.rightAxis.enabled = false
        lineChart.legend.enabled = false
        lineChart.chartDescription.enabled = false

        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.drawGridLinesEnabled = false

        lineChart.leftAxis.axisMinimum = 0
        lineChart.leftAxis.granularity = 1
        lineChart.leftAxis.drawGridLinesEnabled = true
        lineChart.leftAxis.valueFormatter = CountAxisFormatter()

        lineChart.setScaleEnabled(false)
        lineChart.pinchZoomEnabled = false
        lineChart.doubleTapToZoomEnabled = false
    }

    private func updateOverviewChartCounts(from docs: [QueryDocumentSnapshot]) {
        let idx = segTimeRange?.selectedSegmentIndex ?? 1
        let cal = Calendar.current

        // 7 Days => by day
        if idx == 0 {
            let today = cal.startOfDay(for: Date())
            let start = cal.date(byAdding: .day, value: -6, to: today) ?? today

            var labels: [String] = []
            var counts = Array(repeating: 0, count: 7)

            for i in 0..<7 {
                let d = cal.date(byAdding: .day, value: i, to: start) ?? start
                labels.append(Self.dayFormatter.string(from: d))
            }

            for doc in docs {
                guard let d = extractDocDate(doc.data()) else { continue }
                let day = cal.startOfDay(for: d)
                let diff = cal.dateComponents([.day], from: start, to: day).day ?? -999
                if diff >= 0 && diff < 7 {
                    counts[diff] += 1
                }
            }

            applyLineChart(labels: labels, counts: counts)
            return
        }

        // 6 Months / 1 Year => by month
        let monthsBack = (idx == 2) ? 12 : 6
        let now = Date()
        let startOfThisMonth = cal.date(from: cal.dateComponents([.year, .month], from: now)) ?? now
        let start = cal.date(byAdding: .month, value: -(monthsBack - 1), to: startOfThisMonth) ?? startOfThisMonth

        var labels: [String] = []
        var counts = Array(repeating: 0, count: monthsBack)

        for i in 0..<monthsBack {
            let m = cal.date(byAdding: .month, value: i, to: start) ?? start
            labels.append(Self.monthFormatter.string(from: m))
        }

        for doc in docs {
            guard let d = extractDocDate(doc.data()) else { continue }
            let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: d)) ?? d
            let diff = cal.dateComponents([.month], from: start, to: monthStart).month ?? -999
            if diff >= 0 && diff < monthsBack {
                counts[diff] += 1
            }
        }

        applyLineChart(labels: labels, counts: counts)
    }

    private func applyLineChart(labels: [String], counts: [Int]) {
        guard labels.count == counts.count, !labels.isEmpty else {
            lineChart.data = nil
            lineChart.notifyDataSetChanged()
            return
        }

        var entries: [ChartDataEntry] = []
        for i in 0..<labels.count {
            entries.append(ChartDataEntry(x: Double(i), y: Double(counts[i])))
        }

        let set = LineChartDataSet(entries: entries, label: "")
        set.mode = .linear
        set.lineWidth = 3
        set.drawValuesEnabled = false
        set.colors = [UIColor(red: 255/255, green: 216/255, blue: 63/255, alpha: 1)]

        if entries.count <= 1 {
            set.drawCirclesEnabled = true
            set.drawCircleHoleEnabled = false
        } else {
            set.drawCirclesEnabled = false
        }

        lineChart.data = LineChartData(dataSet: set)
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        lineChart.xAxis.granularity = 1

        lineChart.leftAxis.valueFormatter = CountAxisFormatter()
        lineChart.leftAxis.axisMinimum = 0

        lineChart.notifyDataSetChanged()
    }

    // MARK: - Donation Categories UI

    private func setupDonationCategoriesUI() {
        let storyboardBarsConnected =
            (lblFoodPct != nil || lblBasketsPct != nil || lblCampaignPct != nil) ||
            (barFoodView != nil || barBasketsView != nil || barCampaignView != nil) ||
            (barFoodWidth != nil || barBasketsWidth != nil || barCampaignWidth != nil)

        if storyboardBarsConnected {
            [barFoodView, barBasketsView, barCampaignView].forEach {
                $0?.layer.cornerRadius = 6
                $0?.clipsToBounds = true
            }
            return
        }

        guard let host = donationCategoriesSectionView else { return }

        host.subviews.forEach { $0.removeFromSuperview() }
        builtCategoryRows.removeAll()

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fillEqually

        host.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: host.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: host.trailingAnchor),
            stack.topAnchor.constraint(equalTo: host.topAnchor),
            stack.bottomAnchor.constraint(equalTo: host.bottomAnchor)
        ])

        let nameColumnWidth: CGFloat = 80

        let items: [(key: String, title: String, color: UIColor)] = [
            ("food", "Food", UIColor(red: 245/255, green: 226/255, blue: 196/255, alpha: 1)),
            ("baskets", "Baskets", UIColor(red: 236/255, green: 248/255, blue: 183/255, alpha: 1)),
            ("campaign", "Campaign", UIColor(red: 210/255, green: 242/255, blue: 200/255, alpha: 1))
        ]

        for it in items {
            let row = UIView()
            row.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(row)

            let name = UILabel()
            name.translatesAutoresizingMaskIntoConstraints = false
            name.text = it.title
            name.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            name.textColor = .black
            name.textAlignment = .left

            let pct = UILabel()
            pct.translatesAutoresizingMaskIntoConstraints = false
            pct.text = "0.0%"
            pct.font = UIFont.systemFont(ofSize: 18, weight: .regular)
            pct.textColor = .black
            pct.textAlignment = .right
            pct.setContentHuggingPriority(.required, for: .horizontal)

            let track = UIView()
            track.translatesAutoresizingMaskIntoConstraints = false
            track.backgroundColor = .clear
            track.layer.borderWidth = 1
            track.layer.borderColor = UIColor(white: 0.45, alpha: 0.6).cgColor
            track.clipsToBounds = true

            let fill = UIView()
            fill.translatesAutoresizingMaskIntoConstraints = false
            fill.backgroundColor = it.color

            track.addSubview(fill)
            let fillW = fill.widthAnchor.constraint(equalToConstant: 10)

            NSLayoutConstraint.activate([
                fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
                fill.topAnchor.constraint(equalTo: track.topAnchor),
                fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
                fillW
            ])

            row.addSubview(name)
            row.addSubview(track)
            row.addSubview(pct)

            NSLayoutConstraint.activate([
                name.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                name.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                name.widthAnchor.constraint(equalToConstant: nameColumnWidth),

                pct.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                pct.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                pct.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),

                track.leadingAnchor.constraint(equalTo: name.trailingAnchor, constant: 18),
                track.trailingAnchor.constraint(equalTo: pct.leadingAnchor, constant: -18),
                track.heightAnchor.constraint(equalToConstant: 36),
                track.centerYAnchor.constraint(equalTo: row.centerYAnchor)
            ])

            builtCategoryRows[it.key] = CategoryRowUI(
                nameLabel: name,
                percentLabel: pct,
                trackView: track,
                fillView: fill,
                fillWidth: fillW
            )
        }

        host.layoutIfNeeded()
    }

    private func updateDonationCategoriesUI(food: Int, baskets: Int, campaign: Int, animated: Bool) {
        let total = max(food + baskets + campaign, 1)

        let foodPct = Double(food) / Double(total)
        let basketsPct = Double(baskets) / Double(total)
        let campaignPct = Double(campaign) / Double(total)

        lastCategoryPct = (foodPct, basketsPct, campaignPct)

        lblFoodPct?.text = percentText(foodPct)
        lblBasketsPct?.text = percentText(basketsPct)
        lblCampaignPct?.text = percentText(campaignPct)

        builtCategoryRows["food"]?.percentLabel.text = percentText(foodPct)
        builtCategoryRows["baskets"]?.percentLabel.text = percentText(basketsPct)
        builtCategoryRows["campaign"]?.percentLabel.text = percentText(campaignPct)

        applyCategoryBarsFromLastPct(animated: animated)
    }

    private func applyCategoryBarsFromLastPct(animated: Bool) {
        // Storyboard constraints mode
        if let foodW = barFoodWidth, let basketsW = barBasketsWidth, let campW = barCampaignWidth {

            let baseWidth: CGFloat = {
                if let w = barFoodView?.superview?.bounds.width, w > 0 { return w }
                if let w = donationCategoriesSectionView?.bounds.width, w > 0 { return w * 0.55 }
                return 220
            }()

            let minW: CGFloat = 10
            foodW.constant = max(minW, baseWidth * max(0, lastCategoryPct.food))
            basketsW.constant = max(minW, baseWidth * max(0, lastCategoryPct.baskets))
            campW.constant = max(minW, baseWidth * max(0, lastCategoryPct.campaign))

            if animated {
                UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
            } else {
                self.view.layoutIfNeeded()
            }
            return
        }

        // Programmatic mode
        if !builtCategoryRows.isEmpty {

            func apply(key: String, pct: Double) {
                guard let ui = builtCategoryRows[key] else { return }
                let trackW = max(ui.trackView.bounds.width, 1)
                let minW: CGFloat = 10
                ui.fillWidth.constant = max(minW, trackW * max(0, min(1, pct)))
            }

            apply(key: "food", pct: lastCategoryPct.food)
            apply(key: "baskets", pct: lastCategoryPct.baskets)
            apply(key: "campaign", pct: lastCategoryPct.campaign)

            if animated {
                UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
            } else {
                self.view.layoutIfNeeded()
            }
        }
    }

    private func percentText(_ value: Double) -> String {
        String(format: "%.1f%%", value * 100)
    }

    // MARK: - Leaderboard UI
//
//    private func setupSegmentUI() {
//        guard let seg = segListFilter else { return }
//
//        seg.backgroundColor = UIColor(white: 0.93, alpha: 1)
//        seg.selectedSegmentTintColor = .white
//
//        seg.setTitleTextAttributes([
//            .foregroundColor: UIColor.darkGray,
//            .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
//        ], for: .normal)
//
//        seg.setTitleTextAttributes([
//            .foregroundColor: UIColor.black,
//            .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
//        ], for: .selected)
//    }

    private func setupListTableUI() {
        guard let table = tblList else { return }

        table.dataSource = self
        table.delegate = self

        table.isScrollEnabled = false
        table.separatorStyle = .none
        table.backgroundColor = .clear

        table.rowHeight = 74
        table.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 12, right: 0)
    }

    private func setupCountriesTableUI() {
        guard let table = tblCountries else { return }

        table.dataSource = self
        table.delegate = self

        table.isScrollEnabled = false
        table.rowHeight = 44
        table.separatorStyle = .none
        table.backgroundColor = .clear
    }

    // MARK: - Filters

    @objc private func filterChanged() {
        applyListFilterAndReload()
    }

    private func applyListFilterAndReload() {
        let idx = segListFilter?.selectedSegmentIndex ?? 0
        switch idx {
        case 1: rows = allRows.filter { $0.type == .donor }
        case 2: rows = allRows.filter { $0.type == .ngo }
        default: rows = allRows
        }

        rows.sort {
            if $0.points != $1.points { return $0.points > $1.points }
            return $0.name.lowercased() < $1.name.lowercased()
        }

        tblList?.reloadData()
    }

    // MARK: - UITableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let c = tblCountries, tableView === c { return countriesRows.count }
        if let l = tblList, tableView === l { return rows.count }
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let c = tblCountries, tableView === c { return 44 }
        return 74
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // ✅ Countries cell (COUNT + % + Country)
        if let c = tblCountries, tableView === c {

            let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell")
                ?? UITableViewCell(style: .subtitle, reuseIdentifier: nil)

            let item = countriesRows[indexPath.row]
            cell.layoutIfNeeded()

            // ✅ dot (tag 1)
            if let dot = cell.contentView.viewWithTag(1) {
                dot.backgroundColor = dotColors[indexPath.row % dotColors.count]
                dot.layer.cornerRadius = (dot.bounds.height > 0 ? dot.bounds.height : 20) / 2
                dot.clipsToBounds = true
            }

            let l2 = cell.contentView.viewWithTag(2) as? UILabel
            let l3 = cell.contentView.viewWithTag(3) as? UILabel
            let l4 = cell.contentView.viewWithTag(4) as? UILabel
            let taggedLabels = [l2, l3, l4].compactMap { $0 }

            if taggedLabels.count == 3 {
                let sorted = taggedLabels.sorted { $0.frame.minX < $1.frame.minX }
                let nameLbl = sorted[0]
                let countLbl = sorted[1]
                let pctLbl = sorted[2]

                nameLbl.text = item.name
                countLbl.text = formatNumber(item.count)
                pctLbl.text = "\(item.percent)%"

                cell.textLabel?.text = nil
                cell.detailTextLabel?.text = nil
            } else {
                let allLabels = allLabelsInside(cell.contentView)
                if allLabels.count >= 3 {
                    let sorted = allLabels.sorted { $0.frame.minX < $1.frame.minX }
                    let nameLbl = sorted[0]
                    let countLbl = sorted[1]
                    let pctLbl = sorted[2]

                    nameLbl.text = item.name
                    countLbl.text = formatNumber(item.count)
                    pctLbl.text = "\(item.percent)%"

                    cell.textLabel?.text = nil
                    cell.detailTextLabel?.text = nil
                } else {
                    cell.textLabel?.text = item.name
                    cell.detailTextLabel?.text = "\(item.count) • \(item.percent)%"
                }
            }

            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            return cell
        }

        // Leaderboard cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: nil)

        let item = rows[indexPath.row]

        let img = cell.contentView.viewWithTag(10) as? UIImageView
        let lblName = cell.contentView.viewWithTag(1) as? UILabel
        let lblCountry = cell.contentView.viewWithTag(2) as? UILabel
        let lblType = cell.contentView.viewWithTag(3) as? UILabel

        
        if lblName != nil && lblCountry != nil && lblType != nil {

            // placeholder image if not found
            let avatar = UIImage(named: item.imageName ?? "") ?? UIImage(named: "ic_avatar_placeholder")
            img?.image = avatar
            img?.layer.cornerRadius = 18
            img?.clipsToBounds = true
            img?.contentMode = .scaleAspectFill

            lblName?.text = item.name
            lblCountry?.text = item.countryText
            lblType?.text = item.type.rawValue

        } else {
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = "\(item.countryText) • \(item.type.rawValue)"
        }

        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        return cell
    }

    // MARK: - Helpers

    private func allLabelsInside(_ view: UIView) -> [UILabel] {
        var result: [UILabel] = []
        for sub in view.subviews {
            if let l = sub as? UILabel { result.append(l) }
            result.append(contentsOf: allLabelsInside(sub))
        }
        return result.filter { $0.bounds.width > 0 && $0.bounds.height > 0 }
    }

    private func extractDocDate(_ data: [String: Any]) -> Date? {
        if let ts = data["createdAt"] as? Timestamp { return ts.dateValue() }
        if let ts = data["created_at"] as? Timestamp { return ts.dateValue() }
        if let ts = data["timestamp"] as? Timestamp { return ts.dateValue() }
        if let ts = data["submittedAt"] as? Timestamp { return ts.dateValue() }
        if let ts = data["startDate"] as? Timestamp { return ts.dateValue() } // campaigns
        return nil
    }

    private func stringValue(_ data: [String: Any], keys: [String]) -> String {
        for k in keys {
            if let s = data[k] as? String, !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return s
            }
        }
        return ""
    }

    private func extractCountry(from location: String) -> String {
        let parts = location.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return parts.last.map { String($0) } ?? ""
    }

    private func formatNumber(_ value: Int) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func countryText(from countryName: String) -> String {
        let cleaned = countryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return "—" }
        let flag = flagEmoji(forCountryName: cleaned)
        return flag.isEmpty ? cleaned : "\(flag) \(cleaned)"
    }

    private func flagEmoji(forCountryName name: String) -> String {
        let key = name.lowercased()
        let map: [String: String] = [
            "bahrain": "🇧🇭",
            "lebanon": "🇱🇧",
            "saudi arabia": "🇸🇦",
            "ksa": "🇸🇦",
            "germany": "🇩🇪",
            "canada": "🇨🇦",
            "united kingdom": "🇬🇧",
            "uk": "🇬🇧",
            "india": "🇮🇳",
            "united states": "🇺🇸",
            "usa": "🇺🇸",
            "us": "🇺🇸",
            "jordan": "🇯🇴",
            "kenya": "🇰🇪",
            "indonesia": "🇮🇩",
            "palestine": "🇵🇸"
        ]
        return map[key] ?? ""
    }

    // ==========================================================
    // ✅✅✅ FIREBASE LEADERBOARD
    // ==========================================================
    /*
    private func startListeningLeaderboard_FIREBASE_USERS() {


        listeners.append(
            db.collection("users").addSnapshotListener { [weak self] snap, err in
                guard let self else { return }

                if let err {
                    print("❌ Analytics leaderboard users listen:", err.localizedDescription)
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
                        ?? "Unknown"

                    let country = (data["country"] as? String) ?? "Unknown"
                    let flag = (data["countryFlag"] as? String) ?? ""
                    let countryText = flag.isEmpty ? country : "\(flag) \(country)"

                    let points: Int
                    if type == .donor {
                        let rewards = data["rewards"] as? [String: Any] ?? [:]
                        points = Self.intValue(rewards["points"])
                    } else {
                        let rewardsNgo = data["rewardsNgo"] as? [String: Any] ?? [:]
                        points = Self.intValue(rewardsNgo["points"])
                    }

                    let imageName = data["avatarAssetName"] as? String
                    list.append(.init(imageName: imageName,
                                      name: name,
                                      countryText: countryText,
                                      type: type,
                                      points: points))
                }

                list.sort {
                    if $0.points != $1.points { return $0.points > $1.points }
                    return $0.name.lowercased() < $1.name.lowercased()
                }

                DispatchQueue.main.async {
                    self.allRows = list.isEmpty ? self.placeholderAllRows : list
                    self.applyListFilterAndReload()
                }
            }
        )
    }

    private static func intValue(_ any: Any?) -> Int {
        if let i = any as? Int { return i }
        if let d = any as? Double { return Int(d) }
        if let n = any as? NSNumber { return n.intValue }
        if let s = any as? String { return Int(s.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0 }
        return 0
    }
    */

    // ==========================================================
    // ✅ PDF Export
    // ==========================================================

    private func exportAnalyticsScreenPDF(anchor: UIView?) {
        if let scroll = analyticsScrollView {
            exportScrollContentViewAsPDF(scroll, fileName: "Analytics_Report", anchor: anchor)
        } else {
            exportViewAsPDF(self.view, fileName: "Analytics_Report", anchor: anchor)
        }
    }

    private func exportViewAsPDF(_ viewToExport: UIView, fileName: String, anchor: UIView?) {
        viewToExport.layoutIfNeeded()
        let bounds = viewToExport.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }

        let renderer = UIGraphicsPDFRenderer(bounds: bounds)
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            viewToExport.drawHierarchy(in: bounds, afterScreenUpdates: true)
        }

        sharePDFData(data, fileName: fileName, anchor: anchor)
    }

    private func exportScrollContentViewAsPDF(_ scrollView: UIScrollView, fileName: String, anchor: UIView?) {
        scrollView.layoutIfNeeded()
        let contentView = scrollView.subviews.first ?? scrollView
        contentView.layoutIfNeeded()

        let targetWidth = max(contentView.bounds.width, scrollView.bounds.width)
        let targetHeight = max(contentView.bounds.height, scrollView.contentSize.height)
        let targetSize = CGSize(width: targetWidth, height: targetHeight)
        guard targetWidth > 0, targetHeight > 0 else { return }

        let previousFrame = contentView.frame
        contentView.frame = CGRect(origin: .zero, size: targetSize)
        contentView.layoutIfNeeded()

        let bounds = CGRect(origin: .zero, size: targetSize)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            contentView.layer.render(in: ctx.cgContext)
        }

        contentView.frame = previousFrame
        sharePDFData(data, fileName: fileName, anchor: anchor)
    }

    private func sharePDFData(_ data: Data, fileName: String, anchor: UIView?) {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        try? data.write(to: url)

        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let pop = vc.popoverPresentationController {
            pop.sourceView = anchor ?? self.view
            pop.sourceRect = anchor?.bounds ?? CGRect(x: self.view.bounds.midX,
                                                      y: self.view.bounds.midY,
                                                      width: 1,
                                                      height: 1)
        }
        present(vc, animated: true)
    }
}

// MARK: - Small extensions

private extension String {
    func ifEmpty(_ fallback: String) -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? fallback : self
    }
}

// ✅ Y-axis formatter = COUNTS
final class CountAxisFormatter: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "\(Int(value))"
    }
}

private extension UIView {
    func applyCardShadow(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.09
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 4)

        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}
