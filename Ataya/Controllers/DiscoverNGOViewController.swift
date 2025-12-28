//
//  DiscoverNGOViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 27/12/2025.
//

import UIKit

class DiscoverNGOViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    // Dummy data
        let ngos: [NGO] = [
            NGO(
                name: "BrightImpact",
                category: "Community Support",
                email: "support@brightimpact.org",
                location: "Riyadh, Saudi Arabia",
                rating: 5.0,
                impact: 5000,
                mission: "Helping families with food and essential supplies.",
                activities: [
                    "Food distribution",
                    "Donation drives",
                    "Volunteer programs"
                ]
            ),
            NGO(
                name: "GlobalReach",
                category: "Education & Relief",
                email: "info@globalreach.org",
                location: "Manama, Bahrain",
                rating: 4.2,
                impact: 2300,
                mission: "Providing education and emergency relief worldwide.",
                activities: [
                    "School support",
                    "Emergency aid",
                    "Community workshops"
                ]
            )
        ]
    
    var filteredNGOs: [NGO] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredNGOs = ngos

                tableView.dataSource = self
                tableView.delegate = self

                tableView.register(
                    UINib(nibName: "NGOCardCell", bundle: nil),
                    forCellReuseIdentifier: NGOCardCell.reuseId
                )

                tableView.rowHeight = UITableView.automaticDimension
                tableView.estimatedRowHeight = 160
    }
    
    // MARK: - TableView DataSource

        func tableView(_ tableView: UITableView,
                       numberOfRowsInSection section: Int) -> Int {
            return filteredNGOs.count
        }

        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: NGOCardCell.reuseId,
                for: indexPath
            ) as! NGOCardCell

            cell.configure(with: filteredNGOs[indexPath.row])
            return cell
        }
    
    // MARK: - Navigation

       func tableView(_ tableView: UITableView,
                      didSelectRowAt indexPath: IndexPath) {
           performSegue(
               withIdentifier: "ShowNGODetails",
               sender: filteredNGOs[indexPath.row]
           )
       }

       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "ShowNGODetails",
              let destination = segue.destination as? NGOProfileViewController,
              let ngo = sender as? NGO {
               destination.ngo = ngo
           }
       }
    
}

