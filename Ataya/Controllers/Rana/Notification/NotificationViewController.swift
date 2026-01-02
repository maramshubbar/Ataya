import UIKit
import FirebaseAuth
import FirebaseFirestore

final class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearAllButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    var role: AppRole = .donor

    private let yellow = UIColor(named: "#F7D44C")
    private let emptyGray = UIColor(named: "#898989")

    private let tableSidePadding: CGFloat = 36
    private let headerHeight: CGFloat = 36
    private let bottomButtonsAreaHeight: CGFloat = 90

    struct DaySection {
        let dayKey: Date
        let title: String
        let items: [AppNotification]
    }

    private var allNotifications: [AppNotification] = []
    private var sections: [DaySection] = []
    private var listener: ListenerRegistration?

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
        view.backgroundColor = .white

        setupTable()
        setupButtons()
        setupEmptyLabel()

        clearAllButton.addTarget(self, action: #selector(clearAllTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)

        startFirestoreListener()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomInset = bottomButtonsAreaHeight + view.safeAreaInsets.bottom
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }

    deinit { listener?.remove() }

    private func startFirestoreListener() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user logged in.")
            return
        }

        NotificationService.shared.ensureDefaultSettings(uid: uid, role: role)

        listener = NotificationService.shared.listenNotifications(uid: uid, role: role) { [weak self] items in
            guard let self else { return }
            self.allNotifications = items
            self.rebuildSections()
            self.refreshEmptyState()
        }
    }

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

        settingsButton.backgroundColor = .white
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.setTitleColor(yellow, for: .normal)
        settingsButton.layer.cornerRadius = 8
        settingsButton.layer.borderWidth = 1
        settingsButton.layer.borderColor = yellow?.cgColor
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

    private func rebuildSections() {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: allNotifications) { cal.startOfDay(for: $0.createdAt) }
        let sortedDays = grouped.keys.sorted(by: >)

        sections = sortedDays.map { dayStart in
            let items = (grouped[dayStart] ?? []).sorted { $0.createdAt > $1.createdAt }
            return DaySection(dayKey: dayStart, title: makeDayTitle(dayStart: dayStart), items: items)
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
    
    @objc private func settingsTapped() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "NotificationSettingsViewController") as! NotificationSettingsViewController
        vc.role = role
        navigationController?.pushViewController(vc, animated: true)
    }


    @objc private func clearAllTapped() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let alert = UIAlertController(title: "Clear All Notification?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            NotificationService.shared.clearAll(uid: uid, role: self.role) { err in
                if let err = err { print("clearAll error:", err.localizedDescription) }
            }
        }))
        present(alert, animated: true)
    }

    @objc private func settingsTapped() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "NotificationSettingsViewController") as! NotificationSettingsViewController
        vc.role = role
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor = .clear
        container.layoutMargins = tableView.layoutMargins

        let label = UILabel()
        label.text = sections[section].title
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
        ])
        return container
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { headerHeight }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCardCell", for: indexPath) as! NotificationCardCell
        let item = sections[indexPath.section].items[indexPath.row]
        cell.configure(title: item.title, message: item.message, timeText: timeText(for: item.createdAt))
        cell.backgroundColor = .clear
        return cell
    }
}

