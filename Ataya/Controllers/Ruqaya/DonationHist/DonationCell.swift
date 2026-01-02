//
//  DonationCell.swift
//  DonationHistory
//
//  Created by Ruqaya Habib on 31/12/2025.
//

import UIKit
final class DonationCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var ngoLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    
    
    
    @IBOutlet weak var detailsButton: UIButton!
    
    // ✅ لازم تكون var عشان نستخدمها من الـ VC
       var onTapDetails: (() -> Void)?

       private let atayaYellow  = UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 1)
       private let completedBg  = UIColor(red: 0xD2/255, green: 0xF2/255, blue: 0xC1/255, alpha: 1)
       private let rejectedBg   = UIColor(red: 0xF4/255, green: 0x43/255, blue: 0x36/255, alpha: 0.85)

       override func awakeFromNib() {
           super.awakeFromNib()

           selectionStyle = .none
           backgroundColor = .clear
           contentView.backgroundColor = .clear

           styleCard()
           styleTexts()
           styleStatus()
           styleButton()
       }

       override func prepareForReuse() {
           super.prepareForReuse()
           onTapDetails = nil
       }

       override func layoutSubviews() {
           super.layoutSubviews()

           // pill
           statusLabel.layer.cornerRadius = 8

           // stable shadow
           cardView.layer.shadowPath = UIBezierPath(
               roundedRect: cardView.bounds,
               cornerRadius: cardView.layer.cornerRadius
           ).cgPath
       }

       private func styleCard() {
           cardView.backgroundColor = .white
           cardView.layer.cornerRadius = 12
           cardView.layer.borderWidth = 1
           cardView.layer.borderColor = UIColor.systemGray5.cgColor

           cardView.layer.masksToBounds = false
           cardView.layer.shadowColor = UIColor.black.cgColor
           cardView.layer.shadowOpacity = 0.06
           cardView.layer.shadowRadius = 10
           cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
       }

       private func styleTexts() {
           titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
           titleLabel.textColor = .black
           titleLabel.numberOfLines = 1

           [ngoLabel, locationLabel, dateLabel].forEach {
               $0?.font = .systemFont(ofSize: 12, weight: .regular)
               $0?.textColor = UIColor(white: 0.35, alpha: 1)
               $0?.numberOfLines = 1
           }
       }

       private func styleStatus() {
           statusLabel.font = .systemFont(ofSize: 12, weight: .semibold)
           statusLabel.textAlignment = .center
           statusLabel.clipsToBounds = true
       }

       private func styleButton() {
           detailsButton.setTitle("View Details", for: .normal)
           detailsButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
           detailsButton.setTitleColor(.black, for: .normal)
           detailsButton.backgroundColor = atayaYellow
           detailsButton.layer.cornerRadius = 8
           detailsButton.layer.masksToBounds = true
       }

       // ✅ configure بدون closure (عشان ما يطلع Extra trailing closure)
       func configure(with item: DonationHistoryItem) {
           titleLabel.text = item.title
           ngoLabel.text = "NGO: \(item.ngoName)"
           locationLabel.text = item.location
           dateLabel.text = item.dateText

           statusLabel.text = item.status.rawValue
           switch item.status {
           case .completed:
               statusLabel.backgroundColor = completedBg
               statusLabel.textColor = .black
           case .rejected:
               statusLabel.backgroundColor = rejectedBg
               statusLabel.textColor = .black
           }
       }

    @IBAction func detailsTapped(_ sender: UIButton) {
        onTapDetails?()

    }
    

    
}



