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
        
        cardView.layer.cornerRadius = 12
                cardView.clipsToBounds = true
       
        
        
        // Status badge
        statusBadgeView.layer.cornerRadius = 8
            statusBadgeView.clipsToBounds = true

        
        
        // Make the button rounded
        viewDetailsButton.layer.cornerRadius = 4.6
                viewDetailsButton.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
