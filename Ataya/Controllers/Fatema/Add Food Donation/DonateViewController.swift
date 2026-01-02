import UIKit

final class DonateViewController: UIViewController, UIAdaptivePresentationControllerDelegate {

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
        print("✅ DonateViewController loaded")

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let nav = navigationController {
            nav.presentationController?.delegate = self
        } else {
            presentationController?.delegate = self
        }
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

    @objc private func close() {
        dismiss(animated: true) { [weak self] in
            self?.onClose?()
        }
    }

    private func didPick(_ option: DonateOption) {
        print("✅ didPick:", option)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        dismiss(animated: true) { [weak self] in
            print("✅ onSelect fired:", option)
            self?.onSelect?(option)
        }
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onClose?()
    }

    private func addTap(_ view: UIView, action: Selector) {
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: action)
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
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

    @objc private func foodTapped()      { didPick(.food) }
    @objc private func basketTapped()    { didPick(.basket) }
    @objc private func fundsTapped()     { didPick(.funds) }
    @objc private func campaignsTapped() { didPick(.campaigns) }
    @objc private func advocacyTapped()  { didPick(.advocacy) }
    @objc private func giftTapped()      { didPick(.giftOfMercy) }
}
