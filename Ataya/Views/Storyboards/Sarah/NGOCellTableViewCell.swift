//
//  NGOCellTableViewCell.swift
//  Ataya
//
//  Created by BP-36-224-09 on 27/12/2025.
//

import UIKit

class NGOCellTableViewCell: UITableViewCell {

    @IBOutlet weak var NgoProfile: UIImageView!
    
    @IBOutlet weak var NgoName: UILabel!
    
    @IBOutlet weak var verificationIcon: UIImageView!
    
    @IBOutlet weak var typeValue: UILabel!
    
    @IBOutlet weak var emailValue: UILabel!
    
    @IBOutlet weak var locationValue: UILabel!
    
    @IBOutlet weak var ratingIcon: UIImageView!
    
    @IBOutlet weak var ratingValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configure(with ngo: NGO) {
        NgoName.text = ngo.name
        typeValue.text = ngo.category
        emailValue.text = ngo.email
        locationValue.text = ngo.location
        ratingValue.text = "⭐ \(ngo.rating)"
    }
}
