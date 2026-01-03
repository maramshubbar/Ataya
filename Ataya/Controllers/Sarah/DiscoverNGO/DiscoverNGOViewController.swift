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
            rating: 5,
            impact: 5000,
            mission: "Our mission is to empower communities in Saudi Arabia by providing essential resources, education, and support, while fostering long-term growth through skills training, youth engagement, and community development",
            activities: [
                "Weekly food distribution to families in need.",
                "Donation drives including clothes, school supplies, and medical aid.",
                
            ],
            imageName: "Image1" ,
        ),
        NGOdiscover(
            name: "GlobalReach",
            category: "Education & Relief",
            email: "info@globalreach.org",
            location: "Manama, Bahrain",
            rating: 4,
            impact: 2300,
            mission:"Our mission is to provide education and emergency relief worldwide, giving children and families access to learning, safe environments, and immediate humanitarian support.",
            activities: [
                "School support",
                "Emergency aid",
            ],
            imageName: "Image2",
        ),
        NGOdiscover(
            name: "NextGen Giving",
            category: "Children & Youth Support",
            email: "info@nextgen.org",
            location: "Doha, Qatar",
            rating: 5,
            impact: 1200,
            mission: "Our mission is to empower the next generation by providing access to quality education, mentorship opportunities, and programs that develop leadership and life skills in children and youth.",
            activities: [
                "Scholarship programs",
                "Mentorship sessions",
            ],
            imageName: "Image3",
        ),
        NGOdiscover(
            name: "PillarSupport",
            category: "Refugee & Poverty Assistance",
            email: "contact@pillarsupport.org",
            location: "Amman, Jordan",
            rating: 5,
            impact: 8000,
            mission: "Supporting displaced families with shelter, food, and healthcare.",
            activities: [
                "Shelter building",
                "Medical aid",
            ],
            imageName: "Image4",
        ),
        NGOdiscover(
            name: "EcoFuture",
            category: "Environmental Protection",
            email: "eco@future.org",
            location: "Dubai, UAE",
            rating: 4,
            impact: 3500,
            mission: "Promoting sustainability and protecting natural habitats.",
            activities: [
                "Tree planting",
                "Renewable energy workshops"
            ],
            imageName: "Image6",
        ),
        
        NGOdiscover(
            name: "HelpHands",
            category: "Environmental Protection",
            email: "support@HelpHands.org",
            location: "Dubai, UAE",
            rating: 5,
            impact: 3500,
            mission: "To protect the environment by empowering communities through sustainable action, education, and eco-friendly initiatives.",
            activities: [
                "Tree planting initiatives",
                "Beach and public area cleanups",
            ],
            imageName: "Image7",
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

