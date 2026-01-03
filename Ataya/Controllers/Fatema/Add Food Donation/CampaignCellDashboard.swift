import UIKit

final class CampaignCellDashboard: UICollectionViewCell {

    static let reuseId = "CampaignCellDashboard"

    @IBOutlet weak var imgCampaign: UIImageView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!

    private var imageTask: URLSessionDataTask?
    private var currentImageURL: String?

    override func awakeFromNib() {
        super.awakeFromNib()

        // Image
        imgCampaign.clipsToBounds = true
        imgCampaign.contentMode = .scaleAspectFill
        imgCampaign.layer.cornerRadius = 16

        // Badge label (now it's the badge itself)
        badgeLabel.clipsToBounds = true
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center

        // Card
        cardView.layer.cornerRadius = 18
        cardView.clipsToBounds = true

        // Shadow (optional)
        shadowView.layer.shadowOpacity = 0.12
        shadowView.layer.shadowRadius = 12
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 6)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Make the label pill-shaped
        badgeLabel.layer.cornerRadius = badgeLabel.bounds.height / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        currentImageURL = nil
        imgCampaign.image = nil
        badgeLabel.backgroundColor = .systemGray
        badgeLabel.text = nil
    }

    func configure(with item: DashboardCampaign) {
        badgeLabel.text = item.tag
        titleLabel.text = item.title

        // ✅ color based on tag text
        applyBadgeColor(tag: item.tag)

        // Local image fallback
        if !item.imageName.isEmpty, let local = UIImage(named: item.imageName) {
            imgCampaign.image = local
        } else {
            imgCampaign.image = UIImage(named: "campaign1")
        }

        // Firestore URL overrides local if exists
        if let urlStr = item.imageUrl, !urlStr.isEmpty {
            loadImage(urlStr)
        }
    }

    private func applyBadgeColor(tag: String) {
        let t = tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if t == "critical" {
            badgeLabel.backgroundColor = UIColor(hex: "#FFA525")
        } else if t == "climate change" {
            badgeLabel.backgroundColor = UIColor(hex: "#278EFF")
        } else if t == "emergency" {
            badgeLabel.backgroundColor = UIColor(hex: "#FF584F")
        } else {
            badgeLabel.backgroundColor = UIColor(hex: "#999999")
        }
    }

    private func loadImage(_ urlString: String) {
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
}
