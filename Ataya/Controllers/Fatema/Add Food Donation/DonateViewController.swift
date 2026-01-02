import UIKit

final class DonateViewController: UIViewController {
    
    @IBOutlet weak var foodDonationCardView: UIView!
    @IBOutlet weak var basketDonationCardView: UIView!
    @IBOutlet weak var fundsDonationCardView: UIView!
    @IBOutlet weak var campaignsCardView: UIView!
    @IBOutlet weak var advocacyCardView: UIView!
    @IBOutlet weak var giftOfMercyCardView: UIView!
    
    var onSelect: ((DonateOption) -> Void)?
    var onClose: (() -> Void)? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Donate"
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(close)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemGray
        
        let cards: [UIView] = [
            foodDonationCardView,
            basketDonationCardView,
            fundsDonationCardView,
            campaignsCardView,
            advocacyCardView,
            giftOfMercyCardView
        ]

        cards.forEach { styleCard($0) }

        
        addTap(foodDonationCardView, action: #selector(foodTapped))
        addTap(basketDonationCardView, action: #selector(basketTapped))
        addTap(fundsDonationCardView, action: #selector(fundsTapped))
        addTap(campaignsCardView, action: #selector(campaignsTapped))
        addTap(advocacyCardView, action: #selector(advocacyTapped))
        addTap(giftOfMercyCardView, action: #selector(giftTapped))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let cards: [UIView] = [
            foodDonationCardView,
            basketDonationCardView,
            fundsDonationCardView,
            campaignsCardView,
            advocacyCardView,
            giftOfMercyCardView
        ]
        
        for card in cards {
            card.layer.shadowPath = UIBezierPath(
                roundedRect: card.bounds,
                cornerRadius: card.layer.cornerRadius
            ).cgPath
        }
    }
    
    // MARK: - Close
    @objc private func close() {
        dismiss(animated: true) { [weak self] in
            self?.onClose?()
        }
    }
    
    // MARK: - Selection
    private func didPick(_ option: DonateOption) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onSelect?(option)
    }
    
    // MARK: - Helpers
    private func addTap(_ view: UIView, action: Selector) {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
    }
    
    private func styleCard(_ card: UIView) {

        card.layer.cornerRadius = 24
        card.layer.masksToBounds = false

        card.layer.borderWidth = 0.0
        card.layer.borderColor = UIColor.clear.cgColor

        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.16
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.layer.shadowRadius = 6
    }


    
    // MARK: - Actions
    @objc private func foodTapped()      { didPick(.food) }
    @objc private func basketTapped()    { didPick(.basket) }
    @objc private func fundsTapped()     { didPick(.funds) }
    @objc private func campaignsTapped() { didPick(.campaigns) }
    @objc private func advocacyTapped()  { didPick(.advocacy) }
    @objc private func giftTapped()      { didPick(.giftOfMercy) }
}

    // MARK: - Find first UIImageView inside card
private extension UIView {
    func findFirstImageView() -> UIImageView? {
        if let iv = self as? UIImageView { return iv }
        for sub in subviews {
            if let found = sub.findFirstImageView() { return found }
        }
        return nil
    }
}
