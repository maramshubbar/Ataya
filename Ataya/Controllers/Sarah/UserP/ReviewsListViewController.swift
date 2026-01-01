//
//  ReviewsListViewController.swift
//  Ataya
//
//  Created by BP-36-213-12 on 30/12/2025.
//

import UIKit

class ReviewsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                   withIdentifier: "ReviewCell",
                   for: indexPath
               )
        let review = reviews[indexPath.row]
             cell.textLabel?.text = "\(review.reviewerName) ⭐️\(review.rating)"
             cell.detailTextLabel?.text = review.comment

             return cell
    }
    

    @IBOutlet weak var tableView: UITableView!
    
    
    var reviews: [Review] = []

        override func viewDidLoad() {
            super.viewDidLoad()

            tableView.dataSource = self
            tableView.delegate = self

            // Dummy data from "backend"
            reviews = DummyDatabase.shared
                .collectors["collector_1"]?
                .reviews ?? []
        }

}
