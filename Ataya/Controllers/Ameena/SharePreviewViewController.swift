import UIKit

final class SharePreviewViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chartContainerView: UIView!

    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var shareButton: UIButton!

    var selectedSection: Int = 1   // 1 meals, 2 waste, 3 env
    var selectedPeriod: Int = 0    // 0 daily, 1 monthly, 2 yearly

    private let atayaYellow = UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 1)
    private let cardBeige = UIColor(red: 0xF6/255, green: 0xF2/255, blue: 0xD8/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Impact Dashboard"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground

        styleUI()
        applyContent()
    }

    private func styleUI() {
        // Title label (matches the mock)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.85

        // Chart placeholder
        chartContainerView.backgroundColor = UIColor.systemGray6
        chartContainerView.layer.cornerRadius = 12
        chartContainerView.clipsToBounds = true

        // Message card
        messageContainerView.backgroundColor = cardBeige
        messageContainerView.layer.cornerRadius = 18
        messageContainerView.layer.borderWidth = 1
        messageContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        messageContainerView.clipsToBounds = true

        // Message text
        messageLabel.textColor = .label
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        messageLabel.lineBreakMode = .byWordWrapping

        // Share button
        shareButton.setTitle("Share Impact", for: .normal)
        shareButton.backgroundColor = atayaYellow
        shareButton.setTitleColor(.black, for: .normal)
        shareButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        shareButton.layer.cornerRadius = 14
        shareButton.clipsToBounds = true
    }

    private func applyContent() {
        switch selectedSection {
        case 1:
            titleLabel.text = "Meals Provided"
            messageLabel.text = mealsMessage(period: selectedPeriod)
        case 2:
            titleLabel.text = "Food Waste Prevented"
            messageLabel.text = wasteMessage(period: selectedPeriod)
        default:
            titleLabel.text = "Environmental Equivalent"
            messageLabel.text = envMessage(period: selectedPeriod)
        }
    }

    private func mealsMessage(period: Int) -> String {
        return """
        You have shared 145 meals with people in need — a beautiful contribution that brought real change to your community.
        Your impact peaked in July with 42 meals, showing amazing generosity during that month.

        Every meal you donated helped reduce hunger and spread kindness.
        """
    }

    private func wasteMessage(period: Int) -> String {
        return """
        Your consistent donations helped prevent food waste and support sustainability.
        Your strongest period showed steady giving that made a meaningful difference.

        Small actions add up to big environmental change.
        """
    }

    private func envMessage(period: Int) -> String {
        return """
        Your donations didn’t just help people — they helped the environment too.
        Your impact contributed to a greener community and reduced environmental strain.

        Thank you for making a difference.
        """
    }

    @IBAction func shareTapped(_ sender: UIButton) {
        let shareText = "\(titleLabel.text ?? "")\n\n\(messageLabel.text ?? "")"
        let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(vc, animated: true)
    }
}
