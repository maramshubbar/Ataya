//
//  NGOCardCell.swift
//  Ataya
//
//  Created by BP-36-224-14 on 28/12/2025.
//

import UIKit

class NGOCardCell: UITableViewCell {

    @IBOutlet weak var ngoImage: UIImageView!
    
    @IBOutlet weak var ngoName: UILabel!
    
    @IBOutlet weak var ngoType: UILabel!
    
    @IBOutlet weak var ngoEmail: UILabel!
    
    @IBOutlet weak var ngoLocation: UILabel!
    
    @IBOutlet weak var ratingValue: UILabel!
    
    static let reuseId = "NGOCardCell"

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ngoImage.layer.cornerRadius = 12
               ngoImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with ngo: NGO) {
           ngoName.text = ngo.name
           ngoType.text = ngo.category
           ngoEmail.text = ngo.email
           ngoLocation.text = ngo.location
           ratingValue.text = "⭐️ \(ngo.rating)"

           ngoImage.image = UIImage(systemName: "heart.circle.fill")
           ngoImage.tintColor = .systemGreen
       }
}
