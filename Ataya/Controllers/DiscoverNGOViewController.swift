//
//  DiscoverNGOViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 27/12/2025.
//

import UIKit

class DiscoverNGOViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterSegment: UISegmentedControl!
    
    
    private var allNGOs: [NGO] = []
    private var shownNGOs: [NGO] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        filterSegment.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NGOCardCell", bundle: nil), forCellReuseIdentifier: NGOCellTableViewCell.reuseId)


        
        loadDummyNGOs()
        applyFiltersAndReload()
    }

    private func loadDummyNGOs() {
        allNGOs = [
            NGO(name: "NextGen Giving", category: "Educational & Children Support", email: "info@brighthands.org", location: "Manama, Bahrain", rating: 4.5),
            NGO(name: "GlobalReach", category: "Community Support & Donations", email: "contact@globalreach.org", location: "Doha, Qatar", rating: 5.0),
        ]
    }

    @objc private func filterChanged() {
        applyFiltersAndReload()
    }

    private func applyFiltersAndReload() {
        let key = filterSegment.selectedSegmentIndex
        let searchText = (searchBar.text ?? "").lowercased().trimmingCharacters(in: .whitespaces)
        var filtered = allNGOs
        
        switch key {
        case 1:filtered = filtered.filter { $0.category.lowercased().contains("education") }
        case 2: filtered = filtered.filter { $0.location.lowercased().contains("qatar") }
        case 3:filtered = filtered.filter { $0.rating >= 4.8 }
        default:
            break
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                [$0.name, $0.category, $0.email, $0.location]
                    .joined(separator: " ")
                    .lowercased()
                    .contains(searchText)
            }
        }
        
        shownNGOs = filtered
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownNGOs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NGOCellTableViewCell.reuseId, for: indexPath) as! NGOCellTableViewCell
        let ngo = shownNGOs[indexPath.row]
        cell.configure(with: ngo)
        return cell
    }

        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = ""
            searchBar.resignFirstResponder()
            applyFiltersAndReload()
        }
    }

  


