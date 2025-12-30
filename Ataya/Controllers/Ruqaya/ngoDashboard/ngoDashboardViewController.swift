//
//  ngoDashboardViewController.swift
//  Ataya
//
//  Created by Ruqaya Habib on 27/12/2025.
//

import UIKit

final class ngoDashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var assignedTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var assignedTableHeightConstraint: NSLayoutConstraint!

    // Dummy data (نفس اللي تكتبينه)
       private let assignedPickups: [AssignedPickupItem] = [
           AssignedPickupItem(
               title: "Canned Beans",
               donor: "Zahra Ahmed (ID: D-17)",
               location: "Hamad Town, Bahrain",
               status: "Upcoming",
               imageName: "CB",

               donationId: "DON-102",
               itemName: "Canned Beans",
               quantity: "12 packs (400g)",
               category: "Canned Goods",
               expiryDate: "11/2028",
               packaging: "Sealed & Intact",
               allergenInfo: "Allergen free",

               donorName: "Zahra Ahmed",
               contactNumber: "+973 66156902",
               email: "zahraahmed88@gmail.com",
               donorLocation: "Building 1204, Road 2140, Hamad Town, Bahrain",

               scheduledDate: "Mon, Dec 08, 2025",
               pickupWindow: "5:00 PM – 6:00 PM",
               distance: "7.4 km from your location",
               estimatedTime: "1 hour",
               donorNotes: "Kindly call when you reach my building"
           ),

           AssignedPickupItem(
               title: "Cooking Oil",
               donor: "Ali AlArab (ID: D-61)",
               location: "Zayed Town, Bahrain",
               status: "Upcoming",
               imageName: "oil",

               donationId: "DON-103",
               itemName: "Cooking Oil",
               quantity: "2 bottles",
               category: "Groceries",
               expiryDate: "10/2027",
               packaging: "Sealed",
               allergenInfo: "N/A",

               donorName: "Ali AlArab",
               contactNumber: "+973 33XXXXXX",
               email: "ali@example.com",
               donorLocation: "Zayed Town, Bahrain",

               scheduledDate: "Tue, Dec 09, 2025",
               pickupWindow: "3:00 PM – 4:00 PM",
               distance: "5.1 km from your location",
               estimatedTime: "45 mins",
               donorNotes: "Please ring the bell"
           )
       ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backButtonTitle = ""
        
        assignedTableView.dataSource = self
        assignedTableView.delegate = self

        assignedTableView.isScrollEnabled = false
        assignedTableView.separatorStyle = .none
        assignedTableView.backgroundColor = .clear
        
        // ✅ خليها ثابتة عشان تتأكدين إنها تطلع
        assignedTableView.rowHeight = 110
        assignedTableView.estimatedRowHeight = 110

        assignedTableView.register(
            UINib(nibName: "AssignedPickupCell", bundle: nil),
            forCellReuseIdentifier: AssignedPickupCell.reuseId
        )

        assignedTableView.reloadData()
        
        assignedTableView.reloadData()
        DispatchQueue.main.async {
            self.updateTableHeight()
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }

    private func updateTableHeight() {
        guard isViewLoaded else { return }
        guard let heightConstraint = assignedTableHeightConstraint else { return }

        assignedTableView.layoutIfNeeded()
        heightConstraint.constant = assignedTableView.contentSize.height + 90
    }



    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }


       // MARK: - Table
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return assignedPickups.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

           let cell = tableView.dequeueReusableCell(
               withIdentifier: AssignedPickupCell.reuseId,
               for: indexPath
           ) as! AssignedPickupCell
           
           // ✅ هذي السطور اللي سألتِ عنها
           cell.backgroundColor = .clear
           cell.selectionStyle = .none

           cell.configure(with: assignedPickups[indexPath.row])
           return cell
       }

       // ✅ لما تضغط على assigned pickup يفتح التفاصيل
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)

           let sb = UIStoryboard(name: "Main", bundle: nil)
           guard let vc = sb.instantiateViewController(withIdentifier: "AssignedPickupViewController") as? AssignedPickupViewController else {
               assertionFailure("Storyboard ID (AssignedPickupViewController)")
               return
           }

           vc.item = assignedPickups[indexPath.row]
           navigationController?.pushViewController(vc, animated: true)
       }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ROWS:", assignedPickups.count)
        print("TABLE FRAME:", assignedTableView.frame)
        print("CONTENT SIZE:", assignedTableView.contentSize)
    }

    

    
}
