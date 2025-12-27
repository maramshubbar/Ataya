//
//  DiscoverNGOViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 27/12/2025.
//

import UIKit

struct NGO {
    let name: String
    let category: String
    let email: String
    let location: String
    let rating: Double
}

class DiscoverNGOViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var ngos: [NGO] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "NGOCellTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "NGOCellTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        ngos = loadDummyNGOs()
    }
    
    func loadDummyNGOs() -> [NGO] {
        return [
            NGO(name: "NextGen Giving", category: "Educational & Children Support",
                email: "info@brighthands.org", location: "Manama, Bahrain", rating: 4.5),
            NGO(name: "GlobalReach", category: "Community Support & Donations",
                email: "contact@globalreach.org", location: "Doha, Qatar", rating: 5.0)
        ]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ngos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NGOCellTableViewCell", for: indexPath) as? NGOCellTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: ngos[indexPath.row])
        return cell
    }
}

