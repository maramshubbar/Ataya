//
//  AddressCardCell.swift
//  Ataya
//
//  Created by BP-36-224-14 on 22/12/2025.
//

import Foundation

import UIKit

final class AddressCardCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
            super.awakeFromNib()

            // Card style
            contentView.backgroundColor = .clear
            backgroundColor = .clear

            layer.cornerRadius = 8
            layer.masksToBounds = true

            layer.borderWidth = 1
            layer.borderColor = UIColor.systemGray4.cgColor

            // white card
            self.backgroundColor = .white
        }
}
