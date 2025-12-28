//
//  DiscoverNGOViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 27/12/2025.
//

import UIKit

class DiscoverNGOViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        
        }
    
    let ngos: [NGO] = [
        NGO(
            name: "BrightImpact",
            category: "Community Support & Donations",
            email: "support@brightimpact.org",
            location: "Riyadh, Saudi Arabia",
            rating: 5.0,
            impact: 5000,
            mission: "To collect and distribute food, groceries, and essentials to underprivileged families.",
            activities: ["Organizing donation pickups", "Sorting and packing donations", "Partnering with volunteers"]
        ),
        NGO(
            name: "GlobalReach",
            category: "Community Support & Donations",
            email: "support@globalimpact.org",
            location: "Manama, Bahrain",
            rating: 3.7,
            impact: 1200,
            mission: "Providing community support and donations to families in need.",
            activities: ["Running seasonal drives", "Collaborating with local organizations"]
        )
    ]


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ngos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NGOCell", for: indexPath)
        let ngo = ngos[indexPath.row]
        
        cell.textLabel?.text = ngo.name
        cell.detailTextLabel?.text = "\(ngo.category) • \(ngo.location)"
        
        return cell
    }




    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowNGODetails", sender: ngos[indexPath.row])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNGODetails",
           let destination = segue.destination as? NGOProfileViewController,
           let selectedNGO = sender as? NGO {
            destination.ngo = selectedNGO
        }
    }


    }

  


