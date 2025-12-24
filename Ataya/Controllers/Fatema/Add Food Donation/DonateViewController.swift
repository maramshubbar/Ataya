import UIKit

final class DonateViewController: UIViewController {
    
    @IBOutlet weak var foodDonationCardView: UIView!
    @IBOutlet weak var basketDonationCardView: UIView!
    @IBOutlet weak var fundsDonationCardView: UIView!
    @IBOutlet weak var campaignsCardView: UIView!
    @IBOutlet weak var advocacyCardView: UIView!
    @IBOutlet weak var giftOfMercyCardView: UIView!
    
    var onSelect: ((DonateOption) -> Void)?
    
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
        // هذا بس للـ X
        dismiss(animated: true)
    }
    
    // MARK: - Helpers
    private func didPick(_ option: DonateOption) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // ✅ لا تسوين dismiss هنا نهائياً
        // بس رجّعي الخيار… TabBarController هو اللي بيسكر الشيت ويفتح الصفحة
        onSelect?(option)
    }
    
    private func addTap(_ view: UIView, action: Selector) {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
    }
    
    private func styleCard(_ card: UIView) {
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = false
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        card.layer.shadowRadius = 14
    }
    
    // MARK: - Actions
    @objc private func foodTapped()      { didPick(.food) }
    @objc private func basketTapped()    { didPick(.basket) }
    @objc private func fundsTapped()     { didPick(.funds) }
    @objc private func campaignsTapped() { didPick(.campaigns) }
    @objc private func advocacyTapped()  { didPick(.advocacy) }
    @objc private func giftTapped()      { didPick(.giftOfMercy) }
}
