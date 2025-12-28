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

    @IBOutlet weak var cardContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Round image
        ngoImage.layer.cornerRadius = 12
        ngoImage.clipsToBounds = true
        
        // Card styling
        cardContainerView.layer.cornerRadius = 16
        cardContainerView.layer.shadowColor = UIColor.black.cgColor
        cardContainerView.layer.shadowOpacity = 0.1
        cardContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardContainerView.layer.shadowRadius = 6
        cardContainerView.layer.masksToBounds = false
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180 // or whatever fits your card height
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.cornerRadius = 16
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
    }

}
