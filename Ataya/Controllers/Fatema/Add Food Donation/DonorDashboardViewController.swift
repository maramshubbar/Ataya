//
//  DonorDashboardViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 19/12/2025.
//

import UIKit

struct Campaign {
    let imageName: String
    let tag: String
    let title: String
}

final class DonorDashboardViewController: UIViewController,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
    UITableViewDataSource, UITableViewDelegate {
    private let campaigns: [Campaign] = [
        .init(imageName: "campaign1", tag: "Emergency", title: "Food Aid for Families\nin Palestine"),
        .init(imageName: "campaign2", tag: "Climate Change", title: "Shallow Water Well"),
        .init(imageName: "campaign3", tag: "Emergency", title: "Medical Relief for\nInjured Palestinian")
    ]
    
    private let ongoing: [OngoingDonationItem] = [
        .init(title: "Bananas", ngoName: "HopePal", status: "Ready Pickup", imageName: "banana"),
        .init(title: "Baby Formula", ngoName: "Light of Gaza", status: "In Progress", imageName: "baby_formula"),
        .init(title: "Flour", ngoName: "Meal of Hope", status: "Completed", imageName: "flour")
    ]

    
    @IBOutlet weak var recurringStackView: UIStackView!
    @IBOutlet weak var discoverStackView: UIStackView!
    @IBOutlet weak var historyStackView: UIStackView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var quickToolsTitleLabel: UILabel!
    @IBOutlet weak var ongoingDonationTitleLabel: UILabel!

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ongoing.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OngoingDonationCell.reuseId,
                                                 for: indexPath) as! OngoingDonationCell
        cell.configure(with: ongoing[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped ongoing: \(ongoing[indexPath.row].title)")
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        campaigns.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CampaignCell.reuseId, for: indexPath) as! CampaignCell
        cell.configure(with: campaigns[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 35
        return CGSize(width: width, height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.layer.zPosition = 10
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.layer.zPosition = 0
    }

    
    @IBOutlet weak var campaignsCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        quickToolsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        quickToolsTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
//
//        ongoingDonationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        ongoingDonationTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true

        
        campaignsCollectionView.dataSource = self
        campaignsCollectionView.delegate = self
        campaignsCollectionView.backgroundColor = .clear
        campaignsCollectionView.showsHorizontalScrollIndicator = false
        
        // Register XIB
        campaignsCollectionView.register(
            UINib(nibName: "CampaignCell", bundle: nil),
            forCellWithReuseIdentifier: CampaignCell.reuseId)
        
        if let layout = campaignsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 24
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            layout.estimatedItemSize = .zero
        }
        
        makeTappable(recurringStackView, action: #selector(tapRecurring))
        makeTappable(discoverStackView, action: #selector(tapDiscover))
        makeTappable(historyStackView, action: #selector(tapHistory))
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false

        tableView.register(UINib(nibName: "OngoingDonationCell", bundle: nil),
                           forCellReuseIdentifier: OngoingDonationCell.reuseId)

        tableView.rowHeight = 120
        tableView.reloadData()
        DispatchQueue.main.async {
            self.tableView.layoutIfNeeded()
            self.tableHeightConstraint.constant = self.tableView.contentSize.height
        }
        
        updateTableHeight()
        
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero

        print("ongoing count =", ongoing.count)

//        scrollView.alwaysBounceVertical = false
//        scrollView.bounces = false


    }
    private func makeTappable(_ view: UIView, action: Selector) {
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(tap)
    }

    @objc private func tapRecurring() {
        print("Tapped Recurring")
    }

    @objc private func tapDiscover() {
        print("Tapped Discover")
    }

    @objc private func tapHistory() {
        print("Tapped History")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.layoutIfNeeded()
        tableHeightConstraint.constant = tableView.contentSize.height
    }

    private func updateTableHeight() {
        tableView.layoutIfNeeded()
            let h = tableView.contentSize.height
            if tableHeightConstraint.constant != h {
                tableHeightConstraint.constant = h
                view.layoutIfNeeded()
            }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.setContentOffset(.zero, animated: false)
    }
    
    
    
}
