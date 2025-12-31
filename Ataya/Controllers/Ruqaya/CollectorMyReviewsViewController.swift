import UIKit


final class CollectorMyReviewsViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)

    private var reviews: [ReviewItem] = [
        ReviewItem(
            name: "Fawaz Zayed",
            minutesOrDaysAgo: "5 days ago",
            rating: 5.0,
            text: "Handled my donation with amazing care.\nThe pickup was fast, communication was\nclear, and I always felt informed. Truly a\ntrustworthy organization...",
            avatarImageName: "collectorAvatar1"
        ),
        ReviewItem(
            name: "Sara Ali",
            minutesOrDaysAgo: "5 days ago",
            rating: 4.5,
            text: "Very supportive NGO with professional\ncollectors. The process was smooth,\nthough scheduling could be a bit faster.\nStill highly recommended.",
            avatarImageName: "collectorAvatar2"
        ),
        ReviewItem(
            name: "Mary Richard",
            minutesOrDaysAgo: "3 months ago",
            rating: 3.0,
            text: "My donation was eventually collected and\nprocessed, but the wait was longer than\nexpected. Not bad overall, but there’s\nroom for improvement.",
            avatarImageName: "collectorAvatar3"
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "My Reviews"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .black

        setupTable()
    }

    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(ReviewCardCell.self, forCellReuseIdentifier: ReviewCardCell.reuseId)
    }
}

extension CollectorMyReviewsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCardCell.reuseId, for: indexPath) as! ReviewCardCell
        cell.configure(with: reviews[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 215 + 16
    }
}
