//
//  DonorDashboardViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 26/11/2025.
//

import UIKit
final class DonorDashboardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var campaignsCollectionView: UICollectionView!
    private let demoImages = ["campaign1", "campaign2", "campaign3","campaign4"]

    override func viewDidLoad() {
        super.viewDidLoad()

        campaignsCollectionView.dataSource = self
        campaignsCollectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return demoImages.count
        }

        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CampaignCell",
                                                          for: indexPath) as! CampaignCell

            cell.imgCampaign.image = UIImage(named: demoImages[indexPath.item])
            return cell
        }
}
