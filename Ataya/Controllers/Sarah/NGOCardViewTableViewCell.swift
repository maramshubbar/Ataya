//
//  NGOCardViewTableViewCell.swift
//  Ataya
//
//  Created by BP-36-224-16 on 24/12/2025.
//

import UIKit

class NGOCardViewTableViewCell: UITableViewCell {

    @IBOutlet weak var NgoProfile: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var status: UIView!
    @IBOutlet weak var typetitle: UILabel!
    @IBOutlet weak var emailtitle: UILabel!
    @IBOutlet weak var phonetitle: UILabel!
    @IBOutlet weak var datatitle: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phonenumber: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
