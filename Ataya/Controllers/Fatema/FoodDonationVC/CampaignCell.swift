//
//  CampaignCellCollectionViewCell.swift
//  Ataya
//
//  Created by Fatema Maitham on 17/12/2025.
//

import UIKit

final class CampaignCell: UICollectionViewCell {
    @IBOutlet weak var imgCampaign: UIImageView!
    @IBOutlet weak var cardView: CampaignCell!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Safety check (prevents crash if outlet not connected)
               guard cardView != nil, imgCampaign != nil else {
                   print("❌ CampaignCell outlets NOT connected in storyboard")
                   return
               }
        
        cardView.layer.cornerRadius = 18
        cardView.layer.masksToBounds = false

        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowRadius = 12
        cardView.layer.shadowOffset = CGSize(width: 0, height: 6)

        // Image rounded only at top
        imgCampaign.layer.cornerRadius = 18
        imgCampaign.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imgCampaign.clipsToBounds = true
        imgCampaign.contentMode = .scaleAspectFill

    }
}
