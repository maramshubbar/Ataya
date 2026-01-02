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
    
    
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var verificationIcon: UIImageView!
    
    
    // Reuse identifier for this cell type
    static let reuseId = "NGOCardCell"

    @IBOutlet weak var cardContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Make the image circular
        ngoImage.layer.cornerRadius = ngoImage.frame.size.width / 2
        ngoImage.layer.masksToBounds = true
        ngoImage.clipsToBounds = true
        ngoImage.contentMode = .scaleAspectFill

        
        //Round the rating stack view
        ratingStackView.layer.cornerRadius = 5
        ratingStackView.layer.masksToBounds = true
        
        //to make the name expand and the badge to stay next to the name
        ngoName.setContentHuggingPriority(.defaultLow, for: .horizontal)
        ngoName.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        verificationIcon.setContentHuggingPriority(.required, for: .horizontal)
        verificationIcon.setContentCompressionResistancePriority(.required, for: .horizontal)

        //Card styling
        cardContainerView.backgroundColor = .white
        cardContainerView.layer.cornerRadius = 12
        cardContainerView.layer.borderWidth = 1
        cardContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        cardContainerView.layer.masksToBounds = false
        
        // Prevent default gray highlight on selection
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
    }

    //Fill the cell with NGO data
    func configure(with ngo: NGOdiscover) {
           ngoName.text = ngo.name
           ngoType.text = ngo.category
           ngoEmail.text = ngo.email
           ngoLocation.text = ngo.location
           ratingValue.text = "\(ngo.rating)"
        ngoImage.image = UIImage(named: ngo.imageName)
        ngoImage.contentMode = .scaleAspectFill
        ngoImage.clipsToBounds = true

           
        
       }
    
    override func setSelected(_ selected: Bool, animated: Bool) { super.setSelected(selected, animated: animated) // Only highlight the card, not the whole cell
        cardContainerView.backgroundColor = selected ? UIColor.systemGray5 : UIColor.white }
}
