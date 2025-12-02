//
//  ReportCellTableViewCell.swift
//  Ataya
//
//  Created by Maram on 01/12/2025.
//

import UIKit

class ReportCellTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var statusBadgeView: UIView!
    
    @IBOutlet weak var locationLabel: UILabel!
   
    @IBOutlet weak var personLabel: UILabel!
    
    
    @IBOutlet weak var ngoLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var viewDetailsButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
       // cardView.layer.cornerRadius = 12
               // cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 8
           cardView.layer.borderWidth = 1
           cardView.layer.borderColor = UIColor.systemGray5.cgColor
           cardView.clipsToBounds = true
        
        
        // Status badge
        statusBadgeView.layer.cornerRadius = 8
            statusBadgeView.clipsToBounds = true
        statusBadgeView.backgroundColor = UIColor(red: 1.0, green: 0.984, blue: 0.8, alpha: 1.0) // #FFFBCC



        
        
        // Make the button rounded
        viewDetailsButton.layer.cornerRadius = 4.6
                viewDetailsButton.clipsToBounds = true
    }
    
    
    
        override func layoutSubviews() {
            super.layoutSubviews()
            
            // Apply the badge color AFTER layout (so nothing overrides it)
            statusBadgeView.backgroundColor = UIColor(red: 1.0, green: 0.984, blue: 0.8, alpha: 1.0) // #FFFBCC
        }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
