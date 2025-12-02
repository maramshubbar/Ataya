//
//  NGOVerificationViewController.swift
//  Ataya
//
//  Created by Maram on 02/12/2025.
//

import UIKit

struct NGO {
    let name: String
    let description: String
    let email: String
    let note: String?
}


class NGOVerificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var filterSegment: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // TEMP SAMPLE DATA
        let sampleNGOs: [NGO] = [
            NGO(name: "HealBridge",
                description: "Medical & Psychological Support",
                email: "support@healbridge.org",
                note: ""),
            NGO(name: "GlobalReach",
                description: "International Humanitarian Aid",
                email: "contact@globalreach.org",
                note: ""),
            NGO(name: "PureRelief (N–30)",
                description: "Disaster & Medical Relief",
                email: "info@purerelief.org",
                note: ""),
            NGO(name: "BrightHands",
                description: "Educational & Children Support",
                email: "info@brighthands.org",
                note: "Missing verification document")
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        // MARK: - UITableViewDataSource
        
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = .white
            searchField.layer.cornerRadius = 10
            searchField.clipsToBounds = true
        }
        // -----------------------------
        // REGISTER XIB CELL
        // -----------------------------
        let nib = UINib(nibName: "NGOVerificationTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NGOVerificationTableViewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200

    }
    
    // -----------------------------
    // TABLE VIEW DATA SOURCE
    // -----------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleNGOs.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NGOVerificationTableViewCell", for: indexPath) as? NGOVerificationTableViewCell else {
            return UITableViewCell()
        }
        
        let ngo = sampleNGOs[indexPath.row]
        
        cell.nameLabel.text = ngo.name
        cell.descriptionLabel.text = ngo.description
        cell.emailLabel.text = ngo.email
        
        if let note = ngo.note, !note.isEmpty {
            cell.noteLabel.isHidden = false
            cell.noteLabel.text = note
        } else {
            cell.noteLabel.isHidden = true
        }
        
        return cell
    }
    
    // -----------------------------
    // TABLE VIEW DELEGATE (OPTIONAL)
    // -----------------------------
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // push details later
    }
}
