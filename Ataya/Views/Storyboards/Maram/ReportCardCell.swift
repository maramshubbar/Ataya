//
//  ReportCardCell.swift
//  Ataya
//
//  Created by Maram on 18/12/2025.
//

import UIKit

final class ReportCardCell: UITableViewCell {

    static let reuseId = "ReportCardCell"

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var reporterLabel: UILabel!
    @IBOutlet weak var ngoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var btnViewDetails: UIButton!

    var onViewDetailsTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        styleUI()
    }

    private func styleUI() {
        // Card
        cardView.layer.cornerRadius = 14
        cardView.clipsToBounds = true

        // ✅ Border instead of shadow
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor

        // ❌ Remove shadow (إذا عندج shadowView)
        shadowView.layer.shadowOpacity = 0
        shadowView.layer.shadowRadius = 0
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowColor = UIColor.clear.cgColor

        // Badge
        badgeView.layer.cornerRadius = 8
        badgeView.clipsToBounds = true

        // Button
        btnViewDetails.layer.cornerRadius = 4.6
        btnViewDetails.clipsToBounds = true
        btnViewDetails.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)

    }


    @IBAction func viewDetailsTapped(_ sender: UIButton) {
        onViewDetailsTapped?()
    }

    func configure(title: String,
                   location: String,
                   reporter: String,
                   ngo: String,
                   date: String,
                   status: String) {

        titleLabel.text = title
        locationLabel.text = location
        reporterLabel.text = reporter
        ngoLabel.text = ngo
        dateLabel.text = date

        badgeLabel.text = status

        if status.lowercased() == "resolved" {
            badgeView.backgroundColor = UIColor(red: 213/255, green: 244/255, blue: 214/255, alpha: 1)
        } else {
            badgeView.backgroundColor = UIColor(red: 255/255, green: 244/255, blue: 191/255, alpha: 1)
        }
    }
}

