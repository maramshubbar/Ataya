
import UIKit
import UserNotifications

final class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearAllButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    // MARK: - Roles
    enum UserRole: String {
        case admin = "ADMIN"
        case donor = "DONOR"
        case ngo   = "NGO"
    }


    var role: UserRole = .donor

    // MARK: - UI
    private let yellow = UIColor(hex: "#F7D44C")
    private let emptyGray = UIColor(hex: "#898989")

    // Figma specs
    private let tableSidePadding: CGFloat = 36
    private let headerHeight: CGFloat = 36
    private let bottomButtonsAreaHeight: CGFloat = 90

    // MARK: - Model
    struct AppNotification: Codable {
        let id: String
        let role: String
        let title: String
        let message: String
        let createdAt: TimeInterval // store as timestamp
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

    // MARK: - Storage Key (per role)
    private var storageKey: String { "notifications_history_\(role.rawValue)" }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notification"
        view.backgroundColor = .white

        setupTable()
        setupButtons()
        setupEmptyLabel()

        clearAllButton.addTarget(self, action: #selector(clearAllTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)

  
        configureSystemNotifications()

        // Load + build
        loadSavedHistory()
        rebuildSections()
        refreshEmptyState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

   
        let bottomInset = bottomButtonsAreaHeight + view.safeAreaInsets.bottom
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }

    // MARK: - Setup UI
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear


        tableView.layoutMargins = UIEdgeInsets(top: 0, left: tableSidePadding, bottom: 0, right: tableSidePadding)
        tableView.preservesSuperviewLayoutMargins = false

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
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
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func refreshEmptyState() {
        emptyLabel.isHidden = !allNotifications.isEmpty
        tableView.isHidden = allNotifications.isEmpty
    }

    // MARK: - iOS Notifications (REAL)
    private func configureSystemNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification permission error:", error.localizedDescription)
                } else {
                    print("Notification permission granted:", granted)
                }
            }
        }

        // Load delivered notifications (from device) and store them in our history for this role
        center.getDeliveredNotifications { [weak self] delivered in
            guard let self = self else { return }

            let roleKey = self.role.rawValue
            var newItems: [AppNotification] = []

            for n in delivered {
                let info = n.request.content.userInfo
                let r = (info["role"] as? String) ?? ""
                guard r == roleKey else { continue }

                let title = n.request.content.title
                let body  = n.request.content.body
                let id    = n.request.identifier

                // best effort timestamp
                let ts = Date().timeIntervalSince1970

                newItems.append(
                    AppNotification(id: id, role: r, title: title, message: body, createdAt: ts)
                )
            }

            DispatchQueue.main.async {
                if !newItems.isEmpty {
                    self.mergeAndSave(newItems)
                    self.rebuildSections()
                    self.refreshEmptyState()
                }
            }
        }
    }

    // MARK: - Role-based scheduling (use this anywhere)
    // You can call this when some pickup status changes etc.
    static func pushLocalNotification(role: UserRole, title: String, body: String) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = ["role": role.rawValue]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        center.add(request) { err in
            if let err = err { print("Notification schedule error:", err.localizedDescription) }
        }
    }

    // MARK: - Storage
    private func loadSavedHistory() {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: storageKey) else {
            allNotifications = []
            return
        }

        do {
            allNotifications = try JSONDecoder().decode([AppNotification].self, from: data)
        } catch {
            allNotifications = []
            print("Decode history error:", error.localizedDescription)
        }
    }

    private func saveHistory() {
        let defaults = UserDefaults.standard
        do {
            let data = try JSONEncoder().encode(allNotifications)
            defaults.set(data, forKey: storageKey)
        } catch {
            print("Encode history error:", error.localizedDescription)
        }
    }

    private func mergeAndSave(_ incoming: [AppNotification]) {
        // avoid duplicates by id
        var dict = Dictionary(uniqueKeysWithValues: allNotifications.map { ($0.id, $0) })
        for n in incoming { dict[n.id] = n }
        allNotifications = Array(dict.values).sorted { $0.createdAt > $1.createdAt }
        saveHistory()
    }

    // MARK: - Grouping
    private func rebuildSections() {
        let cal = Calendar.current

        let grouped = Dictionary(grouping: allNotifications) { n in
            cal.startOfDay(for: Date(timeIntervalSince1970: n.createdAt))
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

    private func timeText(for timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
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
        let alert = UIAlertController(title: "Clear All Notification?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.allNotifications.removeAll()
            self.sections.removeAll()
            self.saveHistory()
            self.tableView.reloadData()
            self.refreshEmptyState()

            // optional: clear delivered notifications too
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }))
        present(alert, animated: true)
    }

    @objc private func settingsTapped() {
        // if your storyboard has segue use it
        // performSegue(withIdentifier: "goToNotificationSettings", sender: nil)
    }
}

// MARK: - UITableView
extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

  
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor = .clear

        // make header use same margins as table (36)
        container.layoutMargins = tableView.layoutMargins
        container.preservesSuperviewLayoutMargins = false

        let label = UILabel()
        label.text = sections[section].title
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.layoutMarginsGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
        ])

        return container
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        headerHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 0.01 }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { UIView() }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCardCell", for: indexPath) as! NotificationCardCell

        let item = sections[indexPath.section].items[indexPath.row]
        cell.configure(
            title: item.title,
            message: item.message,
            timeText: timeText(for: item.createdAt)
        )

        // clean
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear

        return cell
    }
}

// MARK: - UNUserNotificationCenterDelegate (Foreground + Tap)
extension NotificationViewController: UNUserNotificationCenterDelegate {

    // show while app is OPEN
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let info = notification.request.content.userInfo
        let r = (info["role"] as? String) ?? ""
        guard r == role.rawValue else {
            completionHandler([]) // ignore other role notifications in this screen
            return
        }

        // show banner even while open
        completionHandler([.banner, .sound])

        // also save to history
        let n = AppNotification(
            id: notification.request.identifier,
            role: r,
            title: notification.request.content.title,
            message: notification.request.content.body,
            createdAt: Date().timeIntervalSince1970
        )

        mergeAndSave([n])
        rebuildSections()
        refreshEmptyState()
    }

    // user tapped it
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

// MARK: - Hex helper
//private extension UIColor {
//    convenience init(hex: String, alpha: CGFloat = 1.0) {
//        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//        if h.hasPrefix("#") { h.removeFirst() }
//        guard h.count == 6 else { self.init(white: 0, alpha: alpha); return }
//
//        var rgb: UInt64 = 0
//        Scanner(string: h).scanHexInt64(&rgb)
//
//        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//        let b = CGFloat(rgb & 0x0000FF) / 255.0
//
//        self.init(red: r, green: g, blue: b, alpha: alpha)
//    }
//}
//
