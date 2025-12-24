//
//  AnalyticsViewController.swift
//  Ataya
//
//  Created by Maram on 02/12/2025.
//

import UIKit
import FirebaseFirestore
import DGCharts   // إذا ما اشتغل عندج، بدليه إلى: import Charts

final class AnalyticsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // ✅ جدول الدول (منفصل)
    @IBOutlet weak var tblCountries: UITableView?

    // ✅ جدول الليست (Leaderboard)
    @IBOutlet weak var tblList: UITableView?
    @IBOutlet weak var segListFilter: UISegmentedControl?

    // ✅ SegmentedControl حق 7 Days / 6 Months / 1 Year (اربطية من storyboard)
    @IBOutlet weak var segTimeRange: UISegmentedControl?

    @IBOutlet weak var lblRegisteredUsers: UILabel?
    @IBOutlet weak var lblTotalDonations: UILabel?
    @IBOutlet weak var lblVerifiedNGOs: UILabel?

    // ✅ chart container (اربطية من storyboard)
    @IBOutlet weak var cardVerified: UIView?
    @IBOutlet weak var chartContainer: UIView?

    @IBOutlet weak var cardTotal: UIView?
    @IBOutlet weak var cardRegistered: UIView?

    // ==========================================================
    // ✅ Donation Categories SECTION + Export PDF
    // ==========================================================

    // اربطي هذا بالـ container view حق "Donation Categories"
    @IBOutlet weak var donationCategoriesSectionView: UIView?

    // (اختياري) إذا سويتي UI بالـ Storyboard مثل placeholder:
    // اربطي Labels (النسب) يمين البارات
    @IBOutlet weak var lblFoodPct: UILabel?
    @IBOutlet weak var lblBasketsPct: UILabel?
    @IBOutlet weak var lblCampaignPct: UILabel?

    // اربطي الـ bar views نفسها (الملونة)
    @IBOutlet weak var barFoodView: UIView?
    @IBOutlet weak var barBasketsView: UIView?
    @IBOutlet weak var barCampaignView: UIView?

    // اربطي Constraints عرض البارات (Width)
    @IBOutlet weak var barFoodWidth: NSLayoutConstraint?
    @IBOutlet weak var barBasketsWidth: NSLayoutConstraint?
    @IBOutlet weak var barCampaignWidth: NSLayoutConstraint?

    // زر Export PDF (اربطيه بالـ button)
    @IBAction func exportCategoriesPDFTapped(_ sender: UIButton) {
        guard let section = donationCategoriesSectionView else {
            print("⚠️ donationCategoriesSectionView not connected")
            return
        }
        exportViewAsPDF(section, fileName: "Donation_Categories", anchor: sender)
    }

    // نخزن آخر نسب عشان نعيد رسم البارات بعد layout
    private var lastCategoryPct: (food: Double, baskets: Double, campaign: Double) = (0, 0, 0)

    // ✅ إذا ما عندج UI بالـ Storyboard، هذا يبنيه داخل donationCategoriesSectionView
    private struct CategoryRowUI {
        let nameLabel: UILabel
        let percentLabel: UILabel
        let trackView: UIView
        let fillView: UIView
        let fillWidth: NSLayoutConstraint
    }
    private var builtCategoryRows: [String: CategoryRowUI] = [:]

    // MARK: - Leaderboard

    enum RowType: String { case donor = "Donor", ngo = "NGO" }

    struct ListRow {
        let imageName: String?     // asset name (اختياري)
        let name: String
        let countryText: String    // مثال: "🇧🇭 Bahrain"
        let type: RowType
    }

    // ✅ Countries = amountUSD + percent (مثل الجدول القديم)
    struct CountryRow {
        let name: String
        let amountUSD: Double
        let percent: Int
    }

    private var countriesRows: [CountryRow] = []

    private let dotColors: [UIColor] = [
        UIColor(red: 102/255, green: 167/255, blue: 255/255, alpha: 1),
        UIColor(red: 111/255, green: 201/255, blue: 168/255, alpha: 1),
        UIColor(red: 255/255, green: 169/255, blue: 97/255,  alpha: 1),
        UIColor(red: 221/255, green: 203/255, blue: 242/255, alpha: 1)
    ]

    // ✅ Placeholder list (shows names حتى لو Firestore لسى ما رجّع شي)
    private let placeholderAllRows: [ListRow] = [
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

    // MARK: - Firestore

    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    private let ngoApplicationsCol = "ngo_applications"
    private let donationsCol = "donations"
    private let usersCol = "users"

    private var allRows: [ListRow] = []
    private var rows: [ListRow] = []
    private var cachedDonors: [ListRow] = []
    private var cachedNGOs: [ListRow] = []

    private var usersCountFromUsers: Int = 0
    private var usersCountFallback: Int = 0

    // MARK: - Chart

    private let lineChart = LineChartView()

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM" // Jan, Feb...
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        warnIfMissingOutlets()

        // ✅ Donation Categories (Only this part)
        setupDonationCategoriesUI()
        updateDonationCategoriesUI(food: 0, baskets: 0, campaign: 0, animated: false)

        // ✅ Leaderboard UI
        setupSegmentUI()
        setupListTableUI()

        // ✅ Countries table UI
        setupCountriesTableUI()

        segListFilter?.selectedSegmentIndex = 0
        segListFilter?.addTarget(self, action: #selector(filterChanged), for: .valueChanged)

        // ✅ Time range (7 Days / 6 Months / 1 Year) — default = 6 Months
        segTimeRange?.selectedSegmentIndex = 1
        segTimeRange?.addTarget(self, action: #selector(timeRangeChanged), for: .valueChanged)

        // ✅ Show placeholder immediately
        allRows = placeholderAllRows
        applyListFilterAndReload()

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

        // ✅ Donation Categories: re-apply widths after layout
        applyCategoryBarsFromLastPct(animated: false)
    }

    // MARK: - Safety / Debug

    private func warnIfMissingOutlets() {
        if tblList == nil { print("⚠️ Outlet not connected: tblList") }
        if tblCountries == nil { print("⚠️ Outlet not connected: tblCountries") }
        if segListFilter == nil { print("⚠️ Outlet not connected: segListFilter") }
        if segTimeRange == nil { print("⚠️ Outlet not connected: segTimeRange") }
        if lblRegisteredUsers == nil { print("⚠️ Outlet not connected: lblRegisteredUsers") }
        if lblTotalDonations == nil { print("⚠️ Outlet not connected: lblTotalDonations") }
        if lblVerifiedNGOs == nil { print("⚠️ Outlet not connected: lblVerifiedNGOs") }
        if chartContainer == nil { print("⚠️ Outlet not connected: chartContainer") }
        if cardRegistered == nil { print("⚠️ Outlet not connected: cardRegistered") }
        if cardTotal == nil { print("⚠️ Outlet not connected: cardTotal") }
        if cardVerified == nil { print("⚠️ Outlet not connected: cardVerified") }

        // Donation Categories
        if donationCategoriesSectionView == nil { print("⚠️ Outlet not connected: donationCategoriesSectionView") }
    }

    // ==========================================================
    // ✅ Donation Categories (ONLY DRAW THIS)
    // ==========================================================

    private func setupDonationCategoriesUI() {
        // إذا عندج placeholder UI في storyboard (labels/bars/constraints) → نستخدمه
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

        // إذا ما عندج شي بالـ storyboard → نبني الـ 3 rows داخل donationCategoriesSectionView
        guard let host = donationCategoriesSectionView else { return }

        // امسحي أي شي قديم
        host.subviews.forEach { $0.removeFromSuperview() }
        builtCategoryRows.removeAll()

        // rows
        let items: [(key: String, title: String, color: UIColor)] = [
            ("food", "Food", UIColor(red: 245/255, green: 226/255, blue: 196/255, alpha: 1)),
            ("baskets", "Baskets", UIColor(red: 236/255, green: 248/255, blue: 183/255, alpha: 1)),
            ("campaign", "Campaign", UIColor(red: 210/255, green: 242/255, blue: 200/255, alpha: 1))
        ]

        var previousBottom: NSLayoutConstraint?

        for (idx, it) in items.enumerated() {

            let name = UILabel()
            name.translatesAutoresizingMaskIntoConstraints = false
            name.text = it.title
            name.font = UIFont.systemFont(ofSize: 18, weight: .regular)
            name.textColor = .black

            let pct = UILabel()
            pct.translatesAutoresizingMaskIntoConstraints = false
            pct.text = "0.0%"
            pct.font = UIFont.systemFont(ofSize: 22, weight: .regular)
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

            host.addSubview(name)
            host.addSubview(track)
            host.addSubview(pct)

            NSLayoutConstraint.activate([
                name.leadingAnchor.constraint(equalTo: host.leadingAnchor),
                name.centerYAnchor.constraint(equalTo: track.centerYAnchor),

                pct.trailingAnchor.constraint(equalTo: host.trailingAnchor),
                pct.centerYAnchor.constraint(equalTo: track.centerYAnchor),
                pct.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),

                track.leadingAnchor.constraint(equalTo: name.trailingAnchor, constant: 18),
                track.trailingAnchor.constraint(equalTo: pct.leadingAnchor, constant: -18),
                track.heightAnchor.constraint(equalToConstant: 44),
            ])

            if let prev = previousBottom {
                track.topAnchor.constraint(equalTo: prev, constant: 16).isActive = true
            } else {
                track.topAnchor.constraint(equalTo: host.topAnchor).isActive = true
            }

            // last row pins to bottom
            if idx == items.count - 1 {
                track.bottomAnchor.constraint(equalTo: host.bottomAnchor).isActive = true
            }

            previousBottom = track.bottomAnchor

            builtCategoryRows[it.key] = CategoryRowUI(
                nameLabel: name,
                percentLabel: pct,
                trackView: track,
                fillView: fill,
                fillWidth: fillW
            )
        }
    }

    private func updateDonationCategoriesUI(food: Int, baskets: Int, campaign: Int, animated: Bool) {
        let total = max(food + baskets + campaign, 1)

        let foodPct = Double(food) / Double(total)
        let basketsPct = Double(baskets) / Double(total)
        let campaignPct = Double(campaign) / Double(total)

        lastCategoryPct = (foodPct, basketsPct, campaignPct)

        // إذا labels موجودة (storyboard)
        lblFoodPct?.text = percentText(foodPct)
        lblBasketsPct?.text = percentText(basketsPct)
        lblCampaignPct?.text = percentText(campaignPct)

        // إذا built labels (programmatic)
        builtCategoryRows["food"]?.percentLabel.text = percentText(foodPct)
        builtCategoryRows["baskets"]?.percentLabel.text = percentText(basketsPct)
        builtCategoryRows["campaign"]?.percentLabel.text = percentText(campaignPct)

        applyCategoryBarsFromLastPct(animated: animated)
    }

    private func applyCategoryBarsFromLastPct(animated: Bool) {

        // 1) Storyboard mode (constraints موجودة)
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

        // 2) Programmatic mode (builtCategoryRows)
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
        return String(format: "%.1f%%", value * 100)
    }

    // MARK: - Leaderboard UI

    private func setupSegmentUI() {
        guard let seg = segListFilter else { return }

        seg.backgroundColor = UIColor(white: 0.93, alpha: 1)
        seg.selectedSegmentTintColor = .white

        seg.setTitleTextAttributes([
            .foregroundColor: UIColor.darkGray,
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
        ], for: .normal)

        seg.setTitleTextAttributes([
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
        ], for: .selected)
    }

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

    // ✅ Countries table UI (منفصل)
    private func setupCountriesTableUI() {
        guard let table = tblCountries else { return }

        table.dataSource = self
        table.delegate = self

        table.isScrollEnabled = false
        table.rowHeight = 44
        table.separatorStyle = .none
        table.backgroundColor = .clear
    }

    // MARK: - Chart setup

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

        lineChart.leftAxis.valueFormatter = DollarAxisFormatter()

        lineChart.setScaleEnabled(false)
        lineChart.pinchZoomEnabled = false
        lineChart.doubleTapToZoomEnabled = false
    }

    private func updateMonthlyChart(from docs: [QueryDocumentSnapshot]) {
        var monthTotalsUSD: [String: Double] = [:]

        for doc in docs {
            let data = doc.data()

            let amountUSD = (data["amountUSD"] as? Double)
                ?? (data["amountUSD"] as? NSNumber)?.doubleValue
                ?? 0

            if let ts = data["createdAt"] as? Timestamp {
                let month = Self.monthFormatter.string(from: ts.dateValue())
                monthTotalsUSD[month, default: 0] += amountUSD
            }
        }

        let orderedMonths = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
        let months = orderedMonths.filter { monthTotalsUSD[$0] != nil }

        if months.isEmpty {
            lineChart.data = nil
            lineChart.notifyDataSetChanged()
            return
        }

        var entries: [ChartDataEntry] = []
        for (i, m) in months.enumerated() {
            entries.append(ChartDataEntry(x: Double(i), y: monthTotalsUSD[m] ?? 0))
        }

        let set = LineChartDataSet(entries: entries, label: "")
        set.drawCirclesEnabled = false
        set.mode = .linear
        set.lineWidth = 3
        set.drawValuesEnabled = false
        set.colors = [UIColor(red: 255/255, green: 216/255, blue: 63/255, alpha: 1)]

        lineChart.data = LineChartData(dataSet: set)

        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        lineChart.xAxis.granularity = 1

        lineChart.leftAxis.valueFormatter = DollarAxisFormatter()
        lineChart.leftAxis.axisMinimum = 0

        lineChart.notifyDataSetChanged()
    }

    // MARK: - Firestore

    private func startListening() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()

        listenUsersCountFuture()
        listenNgoApplications()
        listenDonations()
    }

    @objc private func timeRangeChanged() {
        startListening()
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

    private func listenUsersCountFuture() {
        let l = db.collection(usersCol)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err = err {
                    print("⚠️ users listener error:", err.localizedDescription)
                    return
                }
                self.usersCountFromUsers = snap?.documents.count ?? 0
                DispatchQueue.main.async { self.updateRegisteredUsersLabel() }
            }

        listeners.append(l)
    }

    private func listenNgoApplications() {
        let l = db.collection(ngoApplicationsCol)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err = err {
                    print("❌ ngo_applications error:", err.localizedDescription)
                    return
                }

                let docs = snap?.documents ?? []

                let verifiedCount = docs.filter { doc in
                    let status = (doc.data()["status"] as? String ?? "").lowercased()
                    return status == "verified"
                }.count

                let ngoRows: [ListRow] = docs.map { doc in
                    let data = doc.data()
                    let name = self.stringValue(data, keys: ["name", "ngoName"]).ifEmpty("NGO")

                    let rawCountry = self.stringValue(data, keys: ["country"])
                        .ifEmpty(self.extractCountry(from: self.stringValue(data, keys: ["location", "city", "address"])))
                        .ifEmpty("Unknown")

                    return ListRow(
                        imageName: nil,
                        name: name,
                        countryText: self.countryText(from: rawCountry),
                        type: .ngo
                    )
                }

                DispatchQueue.main.async {
                    self.lblVerifiedNGOs?.text = "\(verifiedCount)"
                }

                self.cachedNGOs = ngoRows
                self.mergeRowsAndReload()
            }

        listeners.append(l)
    }

    private func listenDonations() {
        let startDate = selectedStartDate()

        let l = db.collection(donationsCol)
            .whereField("createdAt", isGreaterThanOrEqualTo: Timestamp(date: startDate))
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err = err {
                    print("❌ donations error:", err.localizedDescription)
                    return
                }

                let docs = snap?.documents ?? []

                // ✅ Total Donations = عدد الدوكومنتس
                let totalDonationsCount = docs.count

                // ✅ Countries = مجموع amountUSD لكل دولة
                var byCountryUSD: [String: Double] = [:]
                var totalUSD: Double = 0

                // ✅ fallback Registered Users = unique donors
                var uniqueDonors = Set<String>()
                var donorRowsDict: [String: ListRow] = [:]

                // ✅ Donation Categories counts (ONLY USED FOR DRAWING THIS SECTION)
                var foodCount = 0
                var basketsCount = 0
                var campaignCount = 0

                for d in docs {
                    let data = d.data()

                    let amountUSD = (data["amountUSD"] as? Double)
                        ?? (data["amountUSD"] as? NSNumber)?.doubleValue
                        ?? 0
                    totalUSD += amountUSD

                    let country = self.stringValue(data, keys: ["country"])
                        .ifEmpty(self.extractCountry(from: self.stringValue(data, keys: ["location", "address"])))
                        .ifEmpty("Unknown")

                    byCountryUSD[country, default: 0] += amountUSD

                    let donorCode = self.stringValue(data, keys: ["donorCode", "donorId", "reporterCode", "userCode"])
                    let donorName = self.stringValue(data, keys: ["donorName", "reporter", "name", "fullName"]).ifEmpty("Donor")

                    let donorLocRaw = self.stringValue(data, keys: ["donorCountry", "donorLocation", "country", "location"]).ifEmpty("Unknown")
                    let donorCountry = self.extractCountry(from: donorLocRaw).ifEmpty(donorLocRaw)

                    let key = donorCode.isEmpty ? donorName.lowercased() : donorCode
                    uniqueDonors.insert(key)

                    if donorRowsDict[key] == nil {
                        donorRowsDict[key] = ListRow(
                            imageName: nil,
                            name: donorName,
                            countryText: self.countryText(from: donorCountry),
                            type: .donor
                        )
                    }

                    // ✅ Category counting
                    // IMPORTANT: عدّلي keys حسب اسم الحقل الحقيقي عندج إذا مو "category"
                    let catRaw = self.stringValue(data, keys: ["category", "donationCategory", "donationType", "type"]).lowercased()

                    if catRaw == "food" {
                        foodCount += 1
                    } else if catRaw == "baskets" || catRaw == "basket" {
                        basketsCount += 1
                    } else if catRaw == "campaign" || catRaw == "campaigns" {
                        campaignCount += 1
                    }
                }

                // ✅ Countries rows (amount + %)
                let safeTotal = max(totalUSD, 0.000001)
                let cRows = byCountryUSD
                    .map { (name: $0.key, amountUSD: $0.value) }
                    .sorted { $0.amountUSD > $1.amountUSD }
                    .map { item -> CountryRow in
                        let pct = Int(round((item.amountUSD / safeTotal) * 100))
                        return CountryRow(name: item.name, amountUSD: item.amountUSD, percent: pct)
                    }

                DispatchQueue.main.async {
                    self.lblTotalDonations?.text = self.formatNumber(totalDonationsCount)

                    self.usersCountFallback = uniqueDonors.count
                    self.updateRegisteredUsersLabel()

                    // ✅ Countries top 4 (غيري الرقم إذا تبين أكثر)
                    self.countriesRows = Array(cRows.prefix(4))
                    self.tblCountries?.reloadData()

                    // ✅ Update chart
                    self.updateMonthlyChart(from: docs)

                    // ✅ Update Donation Categories (THIS IS THE ONLY NEW OUTPUT)
                    self.updateDonationCategoriesUI(
                        food: foodCount,
                        baskets: basketsCount,
                        campaign: campaignCount,
                        animated: true
                    )
                }

                self.cachedDonors = Array(donorRowsDict.values).prefix(50).map { $0 }
                self.mergeRowsAndReload()
            }

        listeners.append(l)
    }

    private func updateRegisteredUsersLabel() {
        let valueToShow = (usersCountFromUsers > 0) ? usersCountFromUsers : usersCountFallback
        lblRegisteredUsers?.text = formatNumber(valueToShow)
    }

    private func mergeRowsAndReload() {
        let merged = cachedNGOs + cachedDonors
        DispatchQueue.main.async {
            self.allRows = merged.isEmpty ? self.placeholderAllRows : merged
            self.applyListFilterAndReload()
        }
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

        // ✅ Countries table cell (SAFE – ما يطيّح إذا CountryCell مو موجودة)
        if let c = tblCountries, tableView === c {

            let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell")
                ?? UITableViewCell(style: .subtitle, reuseIdentifier: nil)

            let item = countriesRows[indexPath.row]

            let dot = cell.contentView.viewWithTag(1)
            let nameLbl = cell.contentView.viewWithTag(2) as? UILabel
            let pctLbl  = cell.contentView.viewWithTag(3) as? UILabel
            let amtLbl  = cell.contentView.viewWithTag(4) as? UILabel

            if nameLbl != nil || pctLbl != nil || amtLbl != nil {
                nameLbl?.text = item.name
                amtLbl?.text  = formatUSD(item.amountUSD)
                pctLbl?.text  = "\(item.percent)%"

                dot?.backgroundColor = dotColors[indexPath.row % dotColors.count]
                dot?.layer.cornerRadius = 10
                dot?.layer.masksToBounds = true
            } else {
                cell.textLabel?.text = item.name
                cell.detailTextLabel?.text = "\(item.percent)% • \(formatUSD(item.amountUSD))"
            }

            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            return cell
        }

        // ✅ Leaderboard table cell (SAFE – ما يطيّح إذا ListCell مو موجودة)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: nil)

        let item = rows[indexPath.row]

        let img = cell.contentView.viewWithTag(10) as? UIImageView
        let lblName = cell.contentView.viewWithTag(1) as? UILabel
        let lblCountry = cell.contentView.viewWithTag(2) as? UILabel
        let lblType = cell.contentView.viewWithTag(3) as? UILabel

        if lblName != nil || lblCountry != nil || lblType != nil {
            img?.image = UIImage(named: item.imageName ?? "ic_avatar_placeholder")
            img?.layer.cornerRadius = 18
            img?.clipsToBounds = true
            img?.contentMode = .scaleAspectFill

            lblName?.text = item.name
            lblCountry?.text = item.countryText
            lblType?.text = item.type.rawValue

            if let card = cell.contentView.viewWithTag(99) {
                card.backgroundColor = .white
                card.layer.cornerRadius = 12
                card.layer.borderWidth = 1
                card.layer.borderColor = UIColor(white: 0.85, alpha: 1).cgColor
                card.layer.masksToBounds = true
            }
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

    private func formatUSD(_ value: Double) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencySymbol = "$"
        nf.maximumFractionDigits = 0
        return nf.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
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
            "germany": "🇩🇪",
            "canada": "🇨🇦",
            "united kingdom": "🇬🇧",
            "uk": "🇬🇧",
            "india": "🇮🇳",
            "united states": "🇺🇸",
            "usa": "🇺🇸",
            "us": "🇺🇸"
        ]
        return map[key] ?? ""
    }

    // ==========================================================
    // ✅ PDF Export helper
    // ==========================================================
    private func exportViewAsPDF(_ viewToExport: UIView, fileName: String, anchor: UIView?) {
        viewToExport.layoutIfNeeded()

        let bounds = viewToExport.bounds
        guard bounds.width > 0, bounds.height > 0 else {
            print("⚠️ exportViewAsPDF: bounds is zero")
            return
        }

        let renderer = UIGraphicsPDFRenderer(bounds: bounds)
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            viewToExport.drawHierarchy(in: bounds, afterScreenUpdates: true)
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        do {
            try data.write(to: url)

            let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if let pop = vc.popoverPresentationController {
                pop.sourceView = anchor ?? self.view
                pop.sourceRect = anchor?.bounds ?? CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 1, height: 1)
            }
            present(vc, animated: true)
        } catch {
            print("❌ PDF write error:", error.localizedDescription)
        }
    }
}

private extension String {
    func ifEmpty(_ fallback: String) -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? fallback : self
    }
}

// ✅ تنسيق محور Y للدولار
final class DollarAxisFormatter: AxisValueFormatter {
    private let nf: NumberFormatter = {
        let n = NumberFormatter()
        n.numberStyle = .currency
        n.currencySymbol = "$"
        n.maximumFractionDigits = 0
        return n
    }()

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return nf.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
    }
}

private extension UIView {
    func applyCardShadow(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false   // مهم عشان الشادو يبان

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.09
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 4)

        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}
