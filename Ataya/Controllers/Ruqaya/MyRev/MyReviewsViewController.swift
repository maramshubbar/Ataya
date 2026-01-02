import UIKit

final class MyReviewsViewController: UIViewController {

    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Data (Dummy)
    private var reviews: [ReviewItem] = [
        ReviewItem(
            name: "Wgel Ahmed",
            minutesOrDaysAgo: "32 minutes ago",
            rating: 5.0,
            text: "The donor was very kind and cooperative,\nThe food was clean and well packed.",
            avatarImageName: "avatar1"
        ),
        ReviewItem(
            name: "Yara Mahmood",
            minutesOrDaysAgo: "13 days ago",
            rating: 4.5,
            text: "Very generous donor and easy to\ncoordinate with. Almost perfect.",
            avatarImageName: "avatar2"
        ),
        ReviewItem(
            name: "Aliya Mubarak",
            minutesOrDaysAgo: "1 month ago",
            rating: 3.0,
            text: "Good donor, but sometimes not fully\nprepared at the scheduled time,\nOverall still a positive experience,\njust needs a bit more consistency.",
            avatarImageName: "avatar3"
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "My Reviews"
        navigationItem.backButtonTitle = ""

        // back arrow black
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

// MARK: - Table
extension MyReviewsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCardCell.reuseId, for: indexPath) as! ReviewCardCell
        cell.configure(with: reviews[indexPath.row])
        return cell
    }

    // Card height: h = 215
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 215 + 16 // 215 card + spacing feeling
    }
}
