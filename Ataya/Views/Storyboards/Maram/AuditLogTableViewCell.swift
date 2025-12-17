//
//  AuditLogTableViewCell.swift
//  Ataya
//
//  Created by Maram on 02/12/2025.
//

import UIKit

class AuditLogTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var userTitleLabel: UILabel!
    
    @IBOutlet weak var userValueLabel: UILabel!
    
    @IBOutlet weak var actionTitleLabel: UILabel!
    
    @IBOutlet weak var actionValueLabel: UILabel!
    
    @IBOutlet weak var locationTitleLabel: UILabel!
    
    @IBOutlet weak var locationValueLabel: UILabel!
    
    @IBOutlet weak var dateTitleLabel: UILabel!
    
    @IBOutlet weak var dateValueLabel: UILabel!
    
    @IBOutlet weak var statusTitleLabel: UILabel!
    
    @IBOutlet weak var statusValueLabel: UILabel!
    
    
    override func awakeFromNib() {
        
        selectionStyle = .none
        super.awakeFromNib()
        cardView.layer.cornerRadius = 12
            cardView.layer.borderWidth = 1
            cardView.layer.borderColor = UIColor.systemGray5.cgColor
        
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
