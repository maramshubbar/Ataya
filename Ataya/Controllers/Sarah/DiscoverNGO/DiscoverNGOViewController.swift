//
//  DiscoverNGOViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 27/12/2025.
//

import UIKit

class DiscoverNGOViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var search: UISearchBar!
    
    @IBOutlet weak var filterNGO: UISegmentedControl!
    
    let ngos: [NGOdiscover] = [
        NGOdiscover(
            name: "BrightImpact",
            category: "Community Support",
            email: "support@brightimpact.org",
            location: "Riyadh, Saudi Arabia",
            rating: 5.0,
            impact: 5000,
            mission: "Our mission is to empower communities by addressing social, educational, and humanitarian challenges through sustainable and inclusive initiatives.",
            activities: [
                "Food distribution",
                "Donation drives",
                "Volunteer programs"
            ],
            imageName: "image1" ,
        ),
        NGOdiscover(
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
            ],
            imageName: "image2",
        ),
        NGOdiscover(
            name: "NextGen Giving",
            category: "Children & Youth Support",
            email: "info@nextgen.org",
            location: "Doha, Qatar",
            rating: 4.5,
            impact: 1200,
            mission: "Empowering the next generation through education and mentorship.",
            activities: [
                "Scholarship programs",
                "Mentorship sessions",
                "Youth leadership camps"
            ],
            imageName: "Image3",
        ),
        NGOdiscover(
            name: "PillarSupport",
            category: "Refugee & Poverty Assistance",
            email: "contact@pillarsupport.org",
            location: "Amman, Jordan",
            rating: 4.9,
            impact: 8000,
            mission: "Supporting displaced families with shelter, food, and healthcare.",
            activities: [
                "Shelter building",
                "Medical aid",
                "Job training"
            ],
            imageName: "Image4",
        ),
        NGOdiscover(
            name: "EcoFuture",
            category: "Environmental Protection",
            email: "eco@future.org",
            location: "Dubai, UAE",
            rating: 4.7,
            impact: 3500,
            mission: "Promoting sustainability and protecting natural habitats.",
            activities: [
                "Tree planting",
                "Beach cleanups",
                "Renewable energy workshops"
            ],
            imageName: "Data 5",
        ),
        
        NGOdiscover(
            name: "EcoFuture",
            category: "Environmental Protection",
            email: "eco@future.org",
            location: "Dubai, UAE",
            rating: 4.7,
            impact: 3500,
            mission: "Promoting sustainability and protecting natural habitats.",
            activities: [
                "Tree planting",
                "Beach cleanups",
                "Renewable energy workshops"
            ],
            imageName: "Data 2",
        ),
    ]

    
    // This array will hold NGOs after filtering (e.g., search)
    var filteredNGOs: [NGOdiscover] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initially show all NGOs
        filteredNGOs = ngos
        
        // Connect table view to this controller
        tableView.dataSource = self
        tableView.delegate = self
        
        // Register the custom cell (NGOCardCell.xib)
        tableView.register(
            UINib(nibName: "NGOCardCell", bundle: nil),
            forCellReuseIdentifier: NGOCardCell.reuseId
        )
        // Allow dynamic row height based on Auto Layout
                tableView.rowHeight = UITableView.automaticDimension
                tableView.estimatedRowHeight = 160
        
        // Remove default separator lines between cells
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white // or any light gray

    }
    
    // TableView DataSource
    // Number of rows = number of NGOs in filtered list
    func tableView(_ tableView: UITableView,
                       numberOfRowsInSection section: Int) -> Int {
            return filteredNGOs.count
        }

    // Configure each cell with NGO data
    func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: NGOCardCell.reuseId,
                for: indexPath
            ) as! NGOCardCell

            cell.configure(with: filteredNGOs[indexPath.row])
            return cell
        }
    
    //Navigation
    // Handle tap on a cell to navigate to NGOProfileViewController
    func tableView(_ tableView: UITableView,
                      didSelectRowAt indexPath: IndexPath) {
           performSegue(withIdentifier: "ShowNGODetails",sender: filteredNGOs[indexPath.row]
           )
       }

    // Pass selected NGO object to the profile screen
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "ShowNGODetails",
              let destination = segue.destination as? NGOdiscoverProfileViewController,
              let ngo = sender as? NGOdiscover {
               destination.ngo = ngo
           }
       }
    
    // Fixed row height (optional, overrides automaticDimension)
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135 // Adjust to fit your card nicely
    }


    // Make sure cell backgrounds are transparent (so only card shows)
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
    }

}

