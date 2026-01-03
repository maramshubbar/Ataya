//
//  CampaignCellDashboard.swift
//  Ataya
//
//  Created by Fatema Maitham on 19/12/2025.
//

import UIKit

final class CampaignCellDashboard: UICollectionViewCell {

    static let reuseId = "CampaignCellDashboard"

    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var imgCampaign: UIImageView!
    @IBOutlet private weak var badgeLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!

    private let cardRadius: CGFloat = 24
    private let imageRadius: CGFloat = 16

    private var imageTask: URLSessionDataTask?
    private var currentImageURL: String?

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        clipsToBounds = false
        contentView.clipsToBounds = false

        // Card
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = cardRadius
        cardView.clipsToBounds = true

        // Image
        imgCampaign.clipsToBounds = true
        imgCampaign.contentMode = .scaleAspectFill
        imgCampaign.layer.cornerRadius = imageRadius

        // Badge (pill)
        badgeLabel.clipsToBounds = true
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
        badgeLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        badgeLabel.numberOfLines = 1

        // Shadow
        shadowView.backgroundColor = .clear
        shadowView.clipsToBounds = false
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.08
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowView.layer.shadowRadius = 8
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale

        // Title
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Badge pill shape
        badgeLabel.layer.cornerRadius = badgeLabel.bounds.height / 2

        // Shadow path (use shadowView bounds)
        let path = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: cardRadius)
        shadowView.layer.shadowPath = path.cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageTask?.cancel()
        imageTask = nil
        currentImageURL = nil

        imgCampaign.image = nil
        badgeLabel.text = nil
        badgeLabel.backgroundColor = .systemGray
        titleLabel.text = nil
    }

    func configure(with item: DashboardCampaign) {
        badgeLabel.text = item.tag
        titleLabel.text = item.title

        applyBadgeColor(tag: item.tag)

        // Local fallback first
        if !item.imageName.isEmpty, let local = UIImage(named: item.imageName) {
            imgCampaign.image = local
        } else {
            imgCampaign.image = UIImage(named: "campaign1")
        }

        // Remote overrides if exists
        if let urlStr = item.imageUrl, !urlStr.isEmpty {
            loadImage(from: urlStr)
        }
    }

    private func applyBadgeColor(tag: String) {
        let t = tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        switch t {
        case "critical":
            badgeLabel.backgroundColor = color(hex: "#FFA525")
        case "climate change":
            badgeLabel.backgroundColor = color(hex: "#278EFF")
        case "emergency":
            badgeLabel.backgroundColor = color(hex: "#FF584F")
        default:
            badgeLabel.backgroundColor = color(hex: "#999999")
        }
    }

    private func loadImage(from urlString: String) {
        currentImageURL = urlString
        imageTask?.cancel()

        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }
            guard self.currentImageURL == urlString else { return }
            guard let data, let img = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self.imgCampaign.image = img
            }
        }

        imageTask = task
        task.resume()
    }

    // Local helper (no global UIColor extension needed)
    private func color(hex: String) -> UIColor {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = Int(s, radix: 16) else { return .systemGray }

        let r = CGFloat((v >> 16) & 0xFF) / 255.0
        let g = CGFloat((v >> 8) & 0xFF) / 255.0
        let b = CGFloat(v & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
