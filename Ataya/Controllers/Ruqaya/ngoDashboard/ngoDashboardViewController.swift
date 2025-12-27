//
//  ngoDashboardViewController.swift
//  Ataya
//
//  Created by Ruqaya Habib on 27/12/2025.
//

import UIKit

class ngoDashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var assignedTableView: UITableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var assignedTableHeightConstraint: NSLayoutConstraint!
    
    
    struct AssignedPickupItem {
        let title: String
        let donor: String
        let location: String
        let status: String
    }

    private let assignedPickups: [AssignedPickupItem] = [
        .init(title: "Canned Beans",
              donor: "Abdulla Hasan (ID: D-17)",
              location: "Hamad Town, Bahrain",
              status: "Upcoming"),
        .init(title: "Cooking Oil",
              donor: "Ali AlArab (ID: D-61)",
              location: "Zayed Town, Bahrain",
              status: "Upcoming")
    ]

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        assignedTableView.dataSource = self
        assignedTableView.delegate = self
        assignedTableView.isScrollEnabled = false
        assignedTableView.separatorStyle = .none
        assignedTableView.backgroundColor = .clear

        assignedTableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "cell"
        )

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignedPickups.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)

        let item = assignedPickups[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = """
        \(item.title)
        \(item.donor)
        \(item.location)
        \(item.status)
        """

        cell.selectionStyle = .none
        return cell
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        assignedTableView.layoutIfNeeded()
        assignedTableHeightConstraint.constant =
            assignedTableView.contentSize.height
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
