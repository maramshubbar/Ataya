import UIKit

final class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearAllButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    private let yellow = UIColor(hex: "#F7D44C")
    private let borderGray = UIColor(hex: "#B8B8B8")
    private let emptyGray = UIColor(hex: "#898989")

    // Figma specs
    private let cardHeight: CGFloat = 118          // ✅ smaller than before (not too big)
    private let cardGap: CGFloat = 12              // ✅ space between cards
    private let headerHeight: CGFloat = 36
    private let bottomButtonsAreaHeight: CGFloat = 90

    // MARK: - Model
    struct AppNotification {
        let id: String
        let title: String
        let message: String
        let createdAt: Date
    }

    struct DaySection {
        let dayKey: Date
        let title: String
        let items: [AppNotification]
    }

    private var allNotifications: [AppNotification] = []
    private var sections: [DaySection] = []

    private lazy var emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "You’re all caught up\nno new notifications."
        l.numberOfLines = 2
        l.textAlignment = .center
        l.textColor = emptyGray
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.isHidden = true
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notification"

        setupTable()
        setupButtons()
        setupEmptyLabel()

        seedDemoData()
        rebuildSections()
        refreshEmptyState()

        clearAllButton.addTarget(self, action: #selector(clearAllTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // ✅ prevent table under buttons
        let bottomInset = bottomButtonsAreaHeight + view.safeAreaInsets.bottom
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }

    // MARK: - Setup
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear

        // ✅ IMPORTANT: table itself is the 36/36 padding (cards & headers are 0/0 inside)
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: 36, bottom: 0, right: 36)
        tableView.contentInsetAdjustmentBehavior = .automatic

        tableView.rowHeight = cardHeight + cardGap   // ✅ spacing comes from row frame
        tableView.estimatedRowHeight = cardHeight + cardGap
    }

    private func setupButtons() {
        clearAllButton.backgroundColor = yellow
        clearAllButton.setTitle("Clear all", for: .normal)
        clearAllButton.setTitleColor(.black, for: .normal)
        clearAllButton.layer.cornerRadius = 8
        clearAllButton.layer.masksToBounds = true

        settingsButton.backgroundColor = .white
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.setTitleColor(yellow, for: .normal)
        settingsButton.layer.cornerRadius = 8
        settingsButton.layer.masksToBounds = true
        settingsButton.layer.borderWidth = 1
        settingsButton.layer.borderColor = yellow.cgColor
    }

    private func setupEmptyLabel() {
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
        ])
    }

    private func refreshEmptyState() {
        emptyLabel.isHidden = !allNotifications.isEmpty
        tableView.isHidden = allNotifications.isEmpty
    }

    // MARK: - Demo data (replace with Firebase later)
    private func seedDemoData() {
        let now = Date()

        // ✅ ONLY 2 Today + 1 Yesterday
        allNotifications = [
            AppNotification(
                id: "1",
                title: "New Pickup Assigned!",
                message: "A new donation pickup (DON-17) has been assigned to you.",
                createdAt: now.addingTimeInterval(-45 * 60)
            ),
            AppNotification(
                id: "2",
                title: "Pickup Completed",
                message: "Collector completed pickup (DON-13). Delivery incoming.",
                createdAt: now.addingTimeInterval(-30 * 60)
            ),
            AppNotification(
                id: "3",
                title: "Pickup Reminder!",
                message: "You have a pickup today at 3:30 PM. Tap to view address details.",
                createdAt: Calendar.current.date(byAdding: .day, value: -1, to: now)!.addingTimeInterval(-2 * 60 * 60)
            )
        ]
    }

    // MARK: - Auto grouping
    private func rebuildSections() {
        let cal = Calendar.current

        let grouped = Dictionary(grouping: allNotifications) { n in
            cal.startOfDay(for: n.createdAt)
        }

        let sortedDays = grouped.keys.sorted(by: >)

        sections = sortedDays.map { dayStart in
            let items = (grouped[dayStart] ?? []).sorted { $0.createdAt > $1.createdAt }
            let title = makeDayTitle(dayStart: dayStart)
            return DaySection(dayKey: dayStart, title: title, items: items)
        }

        tableView.reloadData()
    }

    private func makeDayTitle(dayStart: Date) -> String {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!

        if dayStart == today { return "Today" }
        if dayStart == yesterday { return "Yesterday" }

        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "MMM d"
        return df.string(from: dayStart)
    }

    private func timeText(for date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "Just now" }
        if seconds < 3600 { return "\(seconds / 60) min ago" }
        if seconds < 86400 { return "\(seconds / 3600) hr ago" }

        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "h:mm a"

        let dayTitle = makeDayTitle(dayStart: Calendar.current.startOfDay(for: date))
        return "\(dayTitle) • \(df.string(from: date))"
    }

    // MARK: - Actions
    @objc private func clearAllTapped() {
        let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.allNotifications.removeAll()
            self.sections.removeAll()
            self.tableView.reloadData()
            self.refreshEmptyState()
        }))
        present(alert, animated: true)
    }

    @objc private func settingsTapped() {
        let a = UIAlertController(title: "Settings", message: "Connect Settings screen later.", preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - Table DataSource/Delegate
extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    // ✅ Header is 0/0 inside table (table already has 36 margins)
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor = .clear

        let label = UILabel()
        label.text = sections[section].title
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor), // ✅ 0 inside table margins
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.layoutMarginsGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
        ])

        // make container use same margins as table
        container.layoutMargins = tableView.layoutMargins
        return container
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        headerHeight
    }

    // ✅ NO section footer needed (spacing is per-row, not per-section)
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 0.01 }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { UIView() }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCardCell", for: indexPath) as! NotificationCardCell

        let item = sections[indexPath.section].items[indexPath.row]
        cell.configure(title: item.title, message: item.message, timeText: timeText(for: item.createdAt))

        // ✅ IMPORTANT: make sure the cell doesn’t add its own padding
        cell.contentView.layoutMargins = .zero
        cell.layoutMargins = .zero

        return cell
    }

    // ✅ THIS is the spacing between cards (Figma gap)
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        // Inset the entire cell content to create “gap”
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: cardGap, right: 0)
        cell.contentView.frame = cell.contentView.frame.inset(by: inset)

        // Keep backgrounds clean
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
    }
}

// MARK: - Hex helper
private extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6 else { self.init(white: 0, alpha: alpha); return }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
