//
//  DonorCampaignsListViewController.swift
//  Ataya
//
//  Created by Maram on 25/12/2025.
//
import UIKit
import FirebaseFirestore

// MARK: - Donor: Seasonal Campaigns List
final class DonorCampaignsListViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private var items: [DonorCampaignItem] = [] {
        didSet { updateEmptyState() }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Seasonal Campaigns"
        navigationItem.largeTitleDisplayMode = .never

        setupNav()
        setupTable()
        layoutUI()
        startListening()
    }

    deinit { listener?.remove() }

    // MARK: - Nav
    private func setupNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
    }

    @objc private func didTapBack() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Table
    private func setupTable() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 14, left: 0, bottom: 24, right: 0)

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(DonorCampaignCardCell.self, forCellReuseIdentifier: DonorCampaignCardCell.reuseId)

        tableView.estimatedRowHeight = 470
        tableView.rowHeight = UITableView.automaticDimension

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func layoutUI() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func updateEmptyState() {
        if items.isEmpty {
            let wrap = UIView()
            let lbl = UILabel()
            lbl.text = "No campaigns yet."
            lbl.textColor = .secondaryLabel
            lbl.font = .systemFont(ofSize: 15, weight: .regular)
            lbl.textAlignment = .center
            wrap.addSubview(lbl)
            lbl.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                lbl.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
                lbl.centerYAnchor.constraint(equalTo: wrap.centerYAnchor),
                lbl.leadingAnchor.constraint(greaterThanOrEqualTo: wrap.leadingAnchor, constant: 24),
                lbl.trailingAnchor.constraint(lessThanOrEqualTo: wrap.trailingAnchor, constant: -24)
            ])
            tableView.backgroundView = wrap
        } else {
            tableView.backgroundView = nil
        }
    }

    // MARK: - Firestore
    private func startListening() {
        listener?.remove()

        listener = db.collection("campaigns")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }

                if let err {
                    print("❌ donor listen error:", err)
                    self.items = []
                    self.tableView.reloadData()
                    return
                }

                let docs = snap?.documents ?? []
                self.items = docs.map { doc in
                    let d = doc.data()

                    let title = self.readString(d["title"]) ?? "—"

                    // ✅ category هو اللي عندج (مو status)
                    let category = self.readString(d["category"]) ?? (self.readString(d["badge"]) ?? "Campaign")

                    let goal = self.readDouble(d["goalAmount"])
                    let raised = self.readDouble(d["raisedAmount"])

                    let endDate = self.readDate(d["endDate"]) ?? Date()

                    let supporters = self.readInt(d["supportersCount"]) ?? self.readInt(d["supporters"]) ?? 0

                    let imageUrl = self.readString(d["imageUrl"]) ?? self.readString(d["imageURL"])

                    // detail
                    let overview = self.readString(d["overview"]) ?? (self.readString(d["story"]) ?? "")
                    let quoteText = self.readString(d["quoteText"]) ?? ""
                    let quoteAuthor = self.readString(d["quoteAuthor"]) ?? ""
                    let org = self.readString(d["organization"]) ?? ""
                    let orgAbout = self.readString(d["orgAbout"]) ?? ""

                    return DonorCampaignItem(
                        id: doc.documentID,
                        title: title,
                        badgeText: category,
                        goalAmount: goal,
                        raisedAmount: raised,
                        endDate: endDate,
                        supportersCount: supporters,
                        imageUrl: imageUrl,
                        overview: overview,
                        quoteText: quoteText,
                        quoteAuthor: quoteAuthor,
                        organization: org,
                        orgAbout: orgAbout
                    )
                }

                self.tableView.reloadData()
            }
    }

    private func readString(_ any: Any?) -> String? { any as? String }

    private func readDouble(_ any: Any?) -> Double {
        if let d = any as? Double { return d }
        if let i = any as? Int { return Double(i) }
        if let n = any as? NSNumber { return n.doubleValue }
        return 0
    }

    private func readInt(_ any: Any?) -> Int? {
        if let i = any as? Int { return i }
        if let d = any as? Double { return Int(d) }
        if let n = any as? NSNumber { return n.intValue }
        return nil
    }

    private func readDate(_ any: Any?) -> Date? {
        if let ts = any as? Timestamp { return ts.dateValue() }
        if let d = any as? Date { return d }
        return nil
    }
}

// MARK: - Table Delegates
extension DonorCampaignsListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: DonorCampaignCardCell.reuseId, for: indexPath) as! DonorCampaignCardCell
        let item = items[indexPath.row]

        cell.configure(with: item)

        // ✅ Read More -> يفتح DonorCampaignDetailViewController (الجديد)
        cell.onReadMore = { [weak self] in
            guard let self else { return }
            self.openDetails(item)
        }

        // ✅ Donate (على الكارد)
        cell.onDonate = { [weak self] in
            let a = UIAlertController(title: "Donate", message: "Later ✨", preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(a, animated: true)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openDetails(items[indexPath.row])
    }

    private func openDetails(_ item: DonorCampaignItem) {

        // ✅ ViewModel للصفحة الجديدة (category نص)
        let vm = DonorCampaignDetailViewController.ViewModel(
            title: item.title,
            category: item.badgeText,           // ✅ هذا اللي يطلع فوق يسار
            imageURL: item.imageUrl,
            goalAmount: item.goalAmount,
            raisedAmount: item.raisedAmount,
            daysLeftText: item.daysLeftText,
            overviewText: item.overview,
            quoteText: item.quoteText,
            quoteAuthor: item.quoteAuthor,
            orgName: item.organization,
            orgAbout: item.orgAbout
        )

        let vc = DonorCampaignDetailViewController(model: vm, onDonate: { [weak self] in
            // 🔥 هنا حطي فتح صفحة التبرع عندج
            let a = UIAlertController(title: "Donate Now", message: "Open your donate flow here ✅", preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(a, animated: true)
        })

        vc.hidesBottomBarWhenPushed = true

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
}

// MARK: - Model
struct DonorCampaignItem {
    let id: String
    let title: String
    let badgeText: String
    let goalAmount: Double
    let raisedAmount: Double
    let endDate: Date
    let supportersCount: Int
    let imageUrl: String?

    // detail
    let overview: String
    let quoteText: String
    let quoteAuthor: String
    let organization: String
    let orgAbout: String

    var progress: CGFloat {
        guard goalAmount > 0 else { return 0 }
        return min(max(CGFloat(raisedAmount / goalAmount), 0), 1)
    }

    var percentText: String { "\(Int(progress * 100)) %" }

    var daysLeftText: String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return "\(max(days, 0)) days left"
    }

    var raisedOfGoalText: String {
        "\(formatMoney(raisedAmount)) of \(formatMoney(goalAmount)) $"
    }

    var supportersText: String {
        "\(formatMoney(Double(supportersCount))) supports"
    }
}

// MARK: - Cell (352×442 + Donate 92×42 + Badge 108×31 + Shadow + Places fixed)
final class DonorCampaignCardCell: UITableViewCell {

    static let reuseId = "DonorCampaignCardCell"

    var onReadMore: (() -> Void)?
    var onDonate: (() -> Void)?

    // sizes
    private let cardW: CGFloat = 352
    private let cardH: CGFloat = 442
    private let badgeW: CGFloat = 108
    private let badgeH: CGFloat = 31
    private let donateW: CGFloat = 92
    private let donateH: CGFloat = 42

    private let brandYellow = colorHex("#F7D44C")
    private let borderGray  = colorHex("#E6E6E6")
    private let thumbBG     = colorHex("#F2F2F7")

    private let shadowWrap = UIView()
    private let cardView = UIView()

    private let heroImage = UIImageView()
    private let heroTitle = UILabel()

    private let badge = UILabel()
    private let daysLabel = UILabel()

    private let raisedLabel = UILabel()
    private let percentLabel = UILabel()

    private let progressBar = AtayaProgressBar()

    private let supportersLabel = UILabel()
    private let readMoreButton = UIButton(type: .system)
    private let donateButton = UIButton(type: .system)

    private var imageTask: URLSessionDataTask?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        setupCardShadow()
        setupHero()
        setupInfo()
        setupBottom()
        layoutAll()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        heroImage.image = nil
    }

    private func setupCardShadow() {
        contentView.addSubview(shadowWrap)
        shadowWrap.translatesAutoresizingMaskIntoConstraints = false

        shadowWrap.layer.shadowColor = UIColor.black.cgColor
        shadowWrap.layer.shadowOpacity = 0.12
        shadowWrap.layer.shadowRadius = 14
        shadowWrap.layer.shadowOffset = CGSize(width: 0, height: 8)

        shadowWrap.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 18
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = borderGray.cgColor
        cardView.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: shadowWrap.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: shadowWrap.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: shadowWrap.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: shadowWrap.bottomAnchor)
        ])
    }

    private func setupHero() {
        heroImage.backgroundColor = thumbBG
        heroImage.contentMode = .scaleAspectFill
        heroImage.clipsToBounds = true

        heroTitle.font = .systemFont(ofSize: 18, weight: .bold)
        heroTitle.textColor = .white
        heroTitle.numberOfLines = 2
        heroTitle.layer.shadowColor = UIColor.black.cgColor
        heroTitle.layer.shadowOpacity = 0.35
        heroTitle.layer.shadowRadius = 6
        heroTitle.layer.shadowOffset = CGSize(width: 0, height: 2)

        cardView.addSubview(heroImage)
        heroImage.translatesAutoresizingMaskIntoConstraints = false

        heroImage.addSubview(heroTitle)
        heroTitle.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heroTitle.leadingAnchor.constraint(equalTo: heroImage.leadingAnchor, constant: 14),
            heroTitle.trailingAnchor.constraint(equalTo: heroImage.trailingAnchor, constant: -14),
            heroTitle.bottomAnchor.constraint(equalTo: heroImage.bottomAnchor, constant: -14)
        ])
    }

    private func setupInfo() {
        badge.font = .systemFont(ofSize: 12, weight: .semibold)
        badge.textColor = .white
        badge.textAlignment = .center
        badge.layer.cornerRadius = 8
        badge.layer.masksToBounds = true

        daysLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        daysLabel.textColor = .secondaryLabel
        daysLabel.textAlignment = .right

        raisedLabel.font = .systemFont(ofSize: 12, weight: .regular)
        raisedLabel.textColor = .secondaryLabel

        percentLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        percentLabel.textColor = .secondaryLabel
        percentLabel.textAlignment = .right

        progressBar.configure(trackBorder: borderGray, trackFill: .white, fill: brandYellow, height: 12)

        [badge, daysLabel, raisedLabel, percentLabel, progressBar].forEach {
            cardView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            badge.widthAnchor.constraint(equalToConstant: badgeW),
            badge.heightAnchor.constraint(equalToConstant: badgeH),
        ])
    }

    private func setupBottom() {
        supportersLabel.font = .systemFont(ofSize: 12, weight: .regular)
        supportersLabel.textColor = .secondaryLabel

        readMoreButton.setTitle("Read More", for: .normal)
        readMoreButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        readMoreButton.contentHorizontalAlignment = .left
        readMoreButton.addTarget(self, action: #selector(tapReadMore), for: .touchUpInside)

        donateButton.setTitle("Donate", for: .normal)
        donateButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        donateButton.setTitleColor(.label, for: .normal)
        donateButton.backgroundColor = brandYellow
        donateButton.layer.cornerRadius = 8
        donateButton.layer.masksToBounds = true
        donateButton.addTarget(self, action: #selector(tapDonate), for: .touchUpInside)

        [supportersLabel, readMoreButton, donateButton].forEach {
            cardView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            donateButton.widthAnchor.constraint(equalToConstant: donateW),
            donateButton.heightAnchor.constraint(equalToConstant: donateH),
        ])
    }

    private func layoutAll() {
        NSLayoutConstraint.activate([
            shadowWrap.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            shadowWrap.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            shadowWrap.widthAnchor.constraint(equalToConstant: cardW),
            shadowWrap.heightAnchor.constraint(equalToConstant: cardH),
            shadowWrap.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            heroImage.topAnchor.constraint(equalTo: cardView.topAnchor),
            heroImage.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            heroImage.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            heroImage.heightAnchor.constraint(equalToConstant: 226),

            badge.topAnchor.constraint(equalTo: heroImage.bottomAnchor, constant: 12),
            badge.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),

            daysLabel.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
            daysLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            raisedLabel.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 10),
            raisedLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),

            percentLabel.centerYAnchor.constraint(equalTo: raisedLabel.centerYAnchor),
            percentLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            progressBar.topAnchor.constraint(equalTo: raisedLabel.bottomAnchor, constant: 10),
            progressBar.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            progressBar.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            supportersLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 10),
            supportersLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),

            readMoreButton.topAnchor.constraint(equalTo: supportersLabel.bottomAnchor, constant: 12),
            readMoreButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),

            donateButton.centerYAnchor.constraint(equalTo: readMoreButton.centerYAnchor),
            donateButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            readMoreButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
        ])
    }

    func configure(with item: DonorCampaignItem) {
        heroTitle.text = item.title

        let lower = item.badgeText.lowercased()
        badge.text = item.badgeText
        if lower.contains("emergency") {
            badge.backgroundColor = UIColor.systemRed.withAlphaComponent(0.85)
        } else if lower.contains("critical") {
            badge.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.85)
        } else {
            badge.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.85)
        }

        daysLabel.text = item.daysLeftText
        raisedLabel.text = item.raisedOfGoalText
        percentLabel.text = item.percentText
        supportersLabel.text = item.supportersText
        progressBar.setProgress(item.progress)

        heroImage.image = nil
        imageTask?.cancel()
        imageTask = nil

        guard let s = item.imageUrl, let url = URL(string: s) else {
            heroImage.backgroundColor = thumbBG
            return
        }

        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.heroImage.image = img }
        }
        imageTask?.resume()
    }

    @objc private func tapReadMore() { onReadMore?() }
    @objc private func tapDonate() { onDonate?() }
}

// MARK: - Thick Progress
final class AtayaProgressBar: UIView {

    private let track = UIView()
    private let fill = UIView()

    private var fillWidth: NSLayoutConstraint!
    private var heightC: NSLayoutConstraint!

    private var progress: CGFloat = 0
    private var barHeight: CGFloat = 12

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(track)
        track.translatesAutoresizingMaskIntoConstraints = false

        track.addSubview(fill)
        fill.translatesAutoresizingMaskIntoConstraints = false

        heightC = heightAnchor.constraint(equalToConstant: barHeight)
        heightC.isActive = true

        fillWidth = fill.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            track.topAnchor.constraint(equalTo: topAnchor),
            track.leadingAnchor.constraint(equalTo: leadingAnchor),
            track.trailingAnchor.constraint(equalTo: trailingAnchor),
            track.bottomAnchor.constraint(equalTo: bottomAnchor),

            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fillWidth
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(trackBorder: UIColor, trackFill: UIColor, fill: UIColor, height: CGFloat) {
        self.barHeight = height
        heightC.constant = height

        track.backgroundColor = trackFill
        track.layer.borderWidth = 1
        track.layer.borderColor = trackBorder.cgColor

        self.fill.backgroundColor = fill

        setNeedsLayout()
        layoutIfNeeded()
        updateCorners()
        updateFillWidth()
    }

    func setProgress(_ p: CGFloat) {
        progress = min(max(p, 0), 1)
        setNeedsLayout()
        layoutIfNeeded()
        updateFillWidth()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCorners()
        updateFillWidth()
    }

    private func updateCorners() {
        let r = barHeight / 2
        track.layer.cornerRadius = r
        fill.layer.cornerRadius = r
        track.clipsToBounds = true
        fill.clipsToBounds = true
    }

    private func updateFillWidth() {
        fillWidth.constant = track.bounds.width * progress
    }
}

// MARK: - Local helpers
private func colorHex(_ hex: String) -> UIColor {
    var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if s.hasPrefix("#") { s.removeFirst() }
    var value: UInt64 = 0
    Scanner(string: s).scanHexInt64(&value)

    let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
    let g = CGFloat((value & 0x00FF00) >> 8)  / 255.0
    let b = CGFloat(value & 0x0000FF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: 1.0)
}

private func formatMoney(_ value: Double) -> String {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.maximumFractionDigits = 0
    return f.string(from: NSNumber(value: value)) ?? "\(Int(value))"
}
