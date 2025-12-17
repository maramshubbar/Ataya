//
//  NGOVerificationTableViewCell.swift
//  Ataya
//
//  Created by Maram on 02/12/2025.
//

import UIKit

class NGOVerificationTableViewCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var viewDetailsButton: UIButton!
    
    @IBOutlet weak var noteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        cardView.layer.cornerRadius = 8
           cardView.layer.borderWidth = 1
           cardView.layer.borderColor = UIColor.systemGray5.cgColor
           cardView.clipsToBounds = true
           
        viewDetailsButton.layer.cornerRadius = 4.6
           viewDetailsButton.clipsToBounds = true
           //viewDetailsButton.backgroundColor = UIColor(red: 0.98, green: 0.84, blue: 0.31, alpha: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
