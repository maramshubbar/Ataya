//
//  DonationCell.swift
//  Ataya
//
//  Created by Fatema Maitham on 01/12/2025.
//

import Foundation
import UIKit

class DonationCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var donorLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var statusBadgeView: UIView!
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var productImageView: UIImageView!

    @IBOutlet weak var detailsButton: UIButton!
}
