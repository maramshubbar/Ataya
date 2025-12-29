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
    


    private let assignedPickups: [AssignedPickupItem] = [
        .init(
            title: "Canned Beans",
            donor: "Abdulla Hasan (ID: D-17)",
            location: "Hamad Town, Bahrain",
            status: "Upcoming",
            imageName: "beans"
        ),
        .init(
            title: "Cooking Oil",
            donor: "Ali AlArab (ID: D-61)",
            location: "Zayed Town, Bahrain",
            status: "Upcoming",
            imageName: "oil"
        )
    ]

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        assignedTableView.dataSource = self
               assignedTableView.delegate = self
               assignedTableView.isScrollEnabled = false
               assignedTableView.separatorStyle = .none
               assignedTableView.backgroundColor = .clear

               assignedTableView.rowHeight = UITableView.automaticDimension
               assignedTableView.estimatedRowHeight = 120

        assignedTableView.rowHeight = 125

        assignedTableView.register(
            UINib(nibName: "AssignedPickupCell", bundle: nil),
            forCellReuseIdentifier: AssignedPickupCell.reuseId
        )

        assignedTableView.reloadData()

        // ✅ احسبي الارتفاع بعد ما يخلص reload + layout
        DispatchQueue.main.async {
            self.updateTableHeight()
        }


    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            assignedPickups.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: AssignedPickupCell.reuseId,
                for: indexPath
            ) as! AssignedPickupCell

            cell.configure(with: assignedPickups[indexPath.row])
            return cell
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            updateTableHeight()
        }

        private func updateTableHeight() {
            assignedTableView.layoutIfNeeded()
            assignedTableHeightConstraint.constant = assignedTableView.contentSize.height
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
