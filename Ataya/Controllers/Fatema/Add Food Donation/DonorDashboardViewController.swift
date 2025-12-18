//
//  DonorDashboardViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 26/11/2025.
//

import UIKit
final class DonorDashboardViewController: UIViewController,
    UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

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
    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let isPad = traitCollection.userInterfaceIdiom == .pad
//
//        let spacing: CGFloat = 16
//        let sideInset: CGFloat = 16
//
//        if isPad {
//            // 2 cards per row on iPad
//            let totalSpacing = sideInset * 2 + spacing
//            let width = (collectionView.bounds.width - totalSpacing) / 2
//            return CGSize(width: width, height: 420)
//        } else {
//            // 1 card per row on iPhone
//            let width = collectionView.bounds.width - (sideInset * 2)
//            return CGSize(width: width, height: 420)
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 16
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 16
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//    }


}
