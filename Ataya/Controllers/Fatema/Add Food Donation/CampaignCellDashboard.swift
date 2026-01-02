import UIKit

final class CampaignCellDashboard: UICollectionViewCell {

    static let reuseId = "CampaignCellDashboard"

    @IBOutlet weak var imgCampaign: UIImageView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var cardView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()

        imgCampaign.clipsToBounds = true
        imgCampaign.contentMode = .scaleAspectFill
        imgCampaign.layer.cornerRadius = 16

        badgeLabel.layer.cornerRadius = 10
        badgeLabel.clipsToBounds = true
    }

    func configure(with item: DashboardCampaign) {
        badgeLabel.text = item.tag
        titleLabel.text = item.title

        // 1) If you have local asset name
        if !item.imageName.isEmpty, let local = UIImage(named: item.imageName) {
            imgCampaign.image = local
        } else {
            imgCampaign.image = UIImage(named: "campaign1") // fallback asset if you have
        }

        // 2) If Firestore has URL
        if let urlStr = item.imageUrl, !urlStr.isEmpty {
            loadImage(urlStr)
        }
    }

    private func loadImage(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.imgCampaign.image = img
            }
        }.resume()
    }
}
