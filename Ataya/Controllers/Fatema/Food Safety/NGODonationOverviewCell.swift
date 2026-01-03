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
    private var lastStatusKey: String?   // ✅ عشان نعمل animation فقط لو تغير

    // ✅ badge colors
    private let pendingBg  = UIColor(red: 0xFF/255, green: 0xFB/255, blue: 0xCC/255, alpha: 1) // #FFFBCC
    private let approvedBg = UIColor(red: 0xD2/255, green: 0xF2/255, blue: 0xC1/255, alpha: 1) // #D2F2C1
    private let rejectedBg = UIColor(red: 0xF6/255, green: 0x6C/255, blue: 0x62/255, alpha: 1) // #F66C62

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
        statusPillLabel.textColor = .black
        lastStatusKey = nil

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

        applyStatus(status, animated: true)
        loadImage(urlString: imageUrl)
    }

    private func applyStatus(_ status: String, animated: Bool) {
        let key = status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // ✅ display text (تبين "Approved" حتى لو stored "successful")
        let displayText: String
        let bg: UIColor
        let textColor: UIColor

        switch key {
        case "pending":
            displayText = "Pending"
            bg = pendingBg
            textColor = .black

        case "approved", "successful":
            displayText = "Approved"
            bg = approvedBg
            textColor = .black

        case "rejected", "reject":
            displayText = "Rejected"
            bg = rejectedBg
            textColor = .white

        default:
            displayText = key.isEmpty ? "—" : key.capitalized
            bg = pendingBg
            textColor = .black
        }

        // ✅ إذا ما تغير، لا تسوي animation
        let shouldAnimate = animated && (lastStatusKey != nil) && (lastStatusKey != key)
        lastStatusKey = key

        let applyUI = {
            self.statusPillLabel.text = displayText
            self.statusPillView.backgroundColor = bg
            self.statusPillLabel.textColor = textColor
        }

        if shouldAnimate {
            UIView.transition(with: statusPillView, duration: 0.22, options: .transitionCrossDissolve, animations: applyUI)
        } else {
            applyUI()
        }
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
