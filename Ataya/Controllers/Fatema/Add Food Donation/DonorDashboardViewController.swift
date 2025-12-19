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
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let campaigns: [Campaign] = [
        .init(imageName: "campaign1", tag: "Emergency", title: "Food Aid for Families\nin Palestine"),
        .init(imageName: "campaign2", tag: "Climate Change", title: "Shallow Water Well"),
        .init(imageName: "campaign3", tag: "Emergency", title: "Medical Relief for\nInjured Palestinian")
    ]
    
    @IBOutlet weak var recurringStackView: UIStackView!
    @IBOutlet weak var discoverStackView: UIStackView!
    @IBOutlet weak var historyStackView: UIStackView!
    
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
        let width = collectionView.bounds.width - 80
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
}
