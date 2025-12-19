//
//  DonorDashboardViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 26/11/2025.
//


import UIKit

struct Campaign {
    let imageName: String
    let tag: String
    let title: String
}


final class DonorDashboardViewController: UIViewController,
    UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
                                          UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var campaignsCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var tableHeightConstraint: NSLayoutConstraint!
    
    private let campaigns: [Campaign] = [
        .init(imageName: "campaign1", tag: "Emergency", title: "Food Aid for Families\nin Palestine"),
        .init(imageName: "campaign2", tag: "Emergency", title: "Winter Relief\nCampaign"),
        .init(imageName: "campaign3", tag: "Urgent", title: "Meals for Families\nThis Week"),
        .init(imageName: "campaign4", tag: "Emergency", title: "Community Support\nProgram")
    ]
    
    
    private let ongoing: [OngoingDonationItem] = [
        .init(title: "Bananas",     ngoName: "HopePal",      status: "Ready Pickup", imageName: "banana"),
        .init(title: "Baby Formula", ngoName: "Light of Gaza", status: "In Progress", imageName: "baby_formula"),
        .init(title: "Flour",       ngoName: "Meal of Hope", status: "Completed",    imageName: "flour")
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none


        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        campaigns.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CampaignCell.reuseId,
            for: indexPath
        ) as! CampaignCell
        
        cell.configure(with: campaigns[indexPath.item])
        return cell
    }

    
    // ✅ NEW: set the size of each card based on the collectionView height
    // This prevents the bottom white area (badge/title) from being CUT OFF.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let layout = campaignsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let h = campaignsCollectionView.bounds.height   // ✅ full height available
        let w: CGFloat
        
        if traitCollection.userInterfaceIdiom == .pad {
            // ✅ iPad: 2 cards per row
            let available = campaignsCollectionView.bounds.width
            - layout.sectionInset.left - layout.sectionInset.right
            - layout.minimumLineSpacing
            w = floor(available / 2)
        } else {
            // ✅ iPhone: show a “peek” of the next card
            w = floor(campaignsCollectionView.bounds.width * 0.86)
        }
        
        layout.itemSize = CGSize(width: w, height: h)
        layout.invalidateLayout()
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ongoing.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: OngoingDonationCell.reuseId,
                                                 for: indexPath) as! OngoingDonationCell
        cell.configure(with: ongoing[indexPath.row])
        return cell
    }
}
