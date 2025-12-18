//
//  DonationOverviewCellTableViewCell.swift
//  Ataya
//
//  Created by Maram on 18/12/2025.
//
import UIKit

final class DonationOverviewCell: UITableViewCell {

    static let reuseId = "DonationOverviewCell"

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!

    @IBOutlet weak var donorLabel: UILabel!
    @IBOutlet weak var ngoLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var btnViewDetails: UIButton!

    var onViewDetailsTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        styleUI()
    }

    private func styleUI() {
        // Card (border only)
        cardView.layer.cornerRadius = 14
        cardView.clipsToBounds = true
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor

        // Badge
        badgeView.layer.cornerRadius = 13
        badgeView.clipsToBounds = true
        badgeLabel.textAlignment = .center

        // Button
        btnViewDetails.layer.cornerRadius = 8
        btnViewDetails.clipsToBounds = true
        btnViewDetails.backgroundColor = UIColor(red: 255/255, green: 216/255, blue: 63/255, alpha: 1)
        btnViewDetails.setTitleColor(.black, for: .normal)
    }

    @IBAction func viewDetailsTapped(_ sender: UIButton) {
        onViewDetailsTapped?()
    }

    func configure(item: DonationItem) {
        titleLabel.text = item.title
        donorLabel.text = item.donorText
        ngoLabel.text = item.ngoText
        locationLabel.text = item.locationText
        dateLabel.text = item.dateText
        badgeLabel.text = item.status.rawValue

        switch item.status {
        case .pending:
            badgeView.backgroundColor = UIColor(red: 255/255, green: 244/255, blue: 191/255, alpha: 1)
        case .approved:
            badgeView.backgroundColor = UIColor(red: 213/255, green: 244/255, blue: 214/255, alpha: 1)
        case .rejected:
            badgeView.backgroundColor = UIColor(red: 242/255, green: 156/255, blue: 148/255, alpha: 1)
        }

        itemImageView.image = UIImage(named: item.imageName) // حطي الصور في Assets
    }
}

