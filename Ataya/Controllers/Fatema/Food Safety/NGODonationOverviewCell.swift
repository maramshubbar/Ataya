//
//  DonationOverviewCell.swift
//  Ataya
//
//  Created by Fatema Maitham on 20/12/2025.
//

import UIKit

final class NGODonationOverviewCell: UITableViewCell {
    
    static let reuseId = "NGODonationOverviewCell"
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var donorLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var statusPillView: UIView!
    @IBOutlet weak var statusPillLabel: UILabel!
    
    @IBOutlet weak var donationImageView: UIImageView!
    @IBOutlet weak var btnViewDetails: UIButton!
    
 
        var onViewDetailsTapped: (() -> Void)?

        private var currentImageUrl: String?
        private var imageTask: URLSessionDataTask?

        override func awakeFromNib() {
            super.awakeFromNib()
            selectionStyle = .none
            styleUI()
        }

        private func styleUI() {
            shadowView.backgroundColor = .clear
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOpacity = 0.08
            shadowView.layer.shadowRadius = 10
            shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)

            cardView.layer.cornerRadius = 12
            cardView.layer.borderWidth = 1
            cardView.layer.borderColor = UIColor(white: 0.88, alpha: 1).cgColor
            cardView.clipsToBounds = true

            statusPillView.layer.cornerRadius = 10
            statusPillView.clipsToBounds = true

            donationImageView.contentMode = .scaleAspectFit
            donationImageView.clipsToBounds = true

            btnViewDetails.layer.cornerRadius = 10
            btnViewDetails.clipsToBounds = true
            btnViewDetails.backgroundColor = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1)
            btnViewDetails.setTitleColor(.black, for: .normal)
        }

        override func prepareForReuse() {
            super.prepareForReuse()

            titleLabel.text = nil
            donorLabel.text = nil
            locationLabel.text = nil
            dateLabel.text = nil

            statusPillLabel.text = nil
            statusPillView.backgroundColor = .clear

            currentImageUrl = nil
            imageTask?.cancel()
            imageTask = nil
            donationImageView.image = nil
        }

        @IBAction func viewDetailsTapped(_ sender: UIButton) {
            onViewDetailsTapped?()
        }

        func configure(title: String,
                       donorLine: String,
                       locationLine: String,
                       dateLine: String,
                       status: String,
                       imageUrl: String) {

            titleLabel.text = title
            donorLabel.text = donorLine
            locationLabel.text = locationLine
            dateLabel.text = dateLine

            applyStatus(status)
            loadImage(urlString: imageUrl)
        }

        private func applyStatus(_ status: String) {
            let s = status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            statusPillLabel.text = s.capitalized

            switch s {
            case "approved":
                statusPillView.backgroundColor = UIColor(red: 213/255, green: 244/255, blue: 214/255, alpha: 1)
            case "rejected":
                statusPillView.backgroundColor = UIColor(red: 242/255, green: 156/255, blue: 148/255, alpha: 1)
            default:
                statusPillView.backgroundColor = UIColor(red: 255/255, green: 244/255, blue: 191/255, alpha: 1)
            }
            statusPillLabel.textColor = .black
        }

        private func loadImage(urlString: String) {
            let clean = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
            currentImageUrl = clean
            donationImageView.image = nil

            guard !clean.isEmpty, let url = URL(string: clean) else { return }

            imageTask?.cancel()
            imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self, let data, let img = UIImage(data: data) else { return }

                DispatchQueue.main.async {
                    guard self.currentImageUrl == clean else { return }
                    self.donationImageView.image = img
                }
            }
            imageTask?.resume()
        }
    }
