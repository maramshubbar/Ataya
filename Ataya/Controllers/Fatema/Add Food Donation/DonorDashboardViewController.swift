//
//  DonorDashboardViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 26/11/2025.
//
import UIKit

struct Campaign {
    let imageName: String
}

final class DonorDashboardViewController: UIViewController,
    UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
                                          UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var campaignsCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    private let campaigns: [Campaign] = [
        .init(imageName: "campaign1"),
        .init(imageName: "campaign2"),
        .init(imageName: "campaign3"),
        .init(imageName: "campaign4")
    ]
    
    private let ongoing: [OngoingDonationItem] = [
        .init(title: "Bananas",     ngoName: "HopePal",      status: "Ready Pickup", imageName: "banana"),
        .init(title: "Baby Formula", ngoName: "Light of Gaza", status: "In Progress", imageName: "baby_formula"),
        .init(title: "Flour",       ngoName: "Meal of Hope", status: "Completed",    imageName: "flour")
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // TableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.rowHeight = 120
        tableView.estimatedRowHeight = 120

        // CollectionView
        campaignsCollectionView.dataSource = self
        campaignsCollectionView.delegate = self
        if let layout = campaignsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
            layout.estimatedItemSize = .zero
        }

        tableView.reloadData()
        campaignsCollectionView.reloadData()
    }

    
    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        campaigns.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CampaignCell",
                                                      for: indexPath) as! CampaignCell
        cell.imgCampaign.image = UIImage(named: campaigns[indexPath.item].imageName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let available = collectionView.bounds.width - 48
        let width = traitCollection.userInterfaceIdiom == .pad ? (available - 16) / 2 : available
        let height = min(190, collectionView.bounds.height)
        return CGSize(width: floor(width), height: floor(height))
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ongoing.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: OngoingDonationCell.reuseId,
                                                 for: indexPath) as! OngoingDonationCell
        cell.configure(with: ongoing[indexPath.row])
        return cell
    }
}
