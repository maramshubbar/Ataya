//
//  CampaignCellCollectionViewCell.swift
//  Ataya
//
//  Created by Fatema Maitham on 17/12/2025.
//

import UIKit

final class CampaignCell: UICollectionViewCell {
    
    static let reuseId = "CampaignCell"
    private let radius: CGFloat = 18
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var imgCampaign: UIImageView!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    private let badgeColor = UIColor(red: 246/255, green: 108/255, blue: 98/255, alpha: 1) // #F66C62

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if shadowView == nil || cardView == nil || imgCampaign == nil ||
           badgeView == nil || badgeLabel == nil || titleLabel == nil {

            print("❌ NIL OUTLETS",
                  "\nshadowView:", shadowView as Any,
                  "\ncardView:", cardView as Any,
                  "\nimgCampaign:", imgCampaign as Any,
                  "\nbadgeView:", badgeView as Any,
                  "\nbadgeLabel:", badgeLabel as Any,
                  "\ntitleLabel:", titleLabel as Any)
            return
        }
        badgeView.backgroundColor = badgeColor
        badgeView.layer.cornerRadius = badgeView.bounds.height / 2   // pill
        badgeView.clipsToBounds = true

        // ❌ no border (because your design is filled)
        badgeView.layer.borderWidth = 0

        badgeLabel.textColor = .white
        badgeLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        
        // Shadow OUTSIDE
        shadowView.backgroundColor = .clear
        shadowView.layer.cornerRadius = radius
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.12
        shadowView.layer.shadowRadius = 12
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 6)
        
        // Rounded card INSIDE (clips)
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = radius
        cardView.clipsToBounds = true
        
        // Image top corners only
        imgCampaign.contentMode = .scaleAspectFill
        imgCampaign.clipsToBounds = true
        imgCampaign.layer.cornerRadius = radius
        imgCampaign.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        

        
        // Title like design (2 lines)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .center
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false

        // ✅ Card must clip to show rounded corners
        cardView.layer.cornerRadius = 18
        cardView.clipsToBounds = true

        // ✅ Shadow container should NOT clip
        shadowView.layer.cornerRadius = 18
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.12
        shadowView.layer.shadowRadius = 12
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 6)

        imgCampaign.contentMode = .scaleAspectFill
        imgCampaign.clipsToBounds = true
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard shadowView != nil else { return }
        cardView.layer.cornerRadius = 18

        shadowView.layer.shadowPath = UIBezierPath(
            roundedRect: shadowView.bounds,
            cornerRadius: radius
        ).cgPath
        badgeView.layer.cornerRadius = badgeView.bounds.height / 2

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgCampaign.image = nil
        badgeLabel.text = nil
        titleLabel.text = nil
    }
    
    
    func configure(with campaign: Campaign) {
        imgCampaign.image = UIImage(named: campaign.imageName)
        badgeLabel.text = campaign.tag
        titleLabel.text = campaign.title
    }
}
