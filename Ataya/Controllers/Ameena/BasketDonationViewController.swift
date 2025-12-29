import UIKit

final class BasketDonationViewController: UIViewController {

    // MARK: - Constants
    private let atayaYellow = UIColor(red: 0xF7/255.0, green: 0xD4/255.0, blue: 0x4C/255.0, alpha: 1.0)

    // MARK: - UI (Skeleton)
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    // MARK: - Card UI
    private let cardView = UIView()
    private let cardStack = UIStackView()

    private let basketImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let priceLabel = UILabel()
    private let donateButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Basket Donation"
        navigationItem.backButtonTitle = ""

        buildLayout()
        buildBasicBasketCard()
    }

    // MARK: - Layout
    private func buildLayout() {
        // ScrollView
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        // ContentView
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // StackView
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center // so we can set card width = 352 and center it
        stackView.distribution = .fill

        NSLayoutConstraint.activate([
            // scrollView fills screen
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // contentView pinned to scrollView
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),

            // IMPORTANT: contentView width equals scrollView frame width (scrolling vertical)
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            // stackView pinned inside contentView
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    // MARK: - Card (Basic Basket)
    private func buildBasicBasketCard() {
        // Card container
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 24
        cardView.layer.masksToBounds = false

        // Shadow
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 10

        // Card stack
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardStack.axis = .vertical
        cardStack.spacing = 12
        cardStack.alignment = .fill
        cardStack.distribution = .fill
        cardStack.isLayoutMarginsRelativeArrangement = true
        cardStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        // Image
        basketImageView.translatesAutoresizingMaskIntoConstraints = false
        basketImageView.image = UIImage(named: "Basic basket")
        basketImageView.contentMode = .scaleAspectFill
        basketImageView.clipsToBounds = true

        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Basic Basket"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 1

        // Description
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text =
        """
        A simple basket with essential food items to support a small family's basic needs.
        Includes: Rice, lentils, canned beans, oil, and salt.
        Perfect for: Supporting individuals or small families with staple foods.
        """
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0

        // Price
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.text = "Price: $10"
        priceLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        priceLabel.textColor = .black
        priceLabel.numberOfLines = 1

        // Donate button
        donateButton.translatesAutoresizingMaskIntoConstraints = false
        donateButton.setTitle("Donate", for: .normal)
        donateButton.setTitleColor(.black, for: .normal)
        donateButton.backgroundColor = atayaYellow
        donateButton.layer.cornerRadius = 4.6
        donateButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        donateButton.addTarget(self, action: #selector(donateTapped), for: .touchUpInside)

        // Assemble
        cardView.addSubview(cardStack)
        cardStack.addArrangedSubview(titleLabel)
        let imageContainer = UIView()
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.addSubview(basketImageView)

        basketImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            basketImageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            basketImageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            basketImageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            basketImageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            imageContainer.heightAnchor.constraint(equalToConstant: 180)
        ])

        cardStack.addArrangedSubview(imageContainer)
        cardStack.addArrangedSubview(descriptionLabel)
        cardStack.addArrangedSubview(priceLabel)

        // Button needs to be centered with fixed width
        let buttonRow = UIView()
        buttonRow.translatesAutoresizingMaskIntoConstraints = false
        buttonRow.addSubview(donateButton)
        cardStack.addArrangedSubview(buttonRow)

        stackView.addArrangedSubview(cardView)

        // Constraints
        NSLayoutConstraint.activate([
            // Card size (from you)
            cardView.widthAnchor.constraint(equalToConstant: 352),
            cardView.heightAnchor.constraint(equalToConstant: 463),

            // Card stack fills card
            cardStack.topAnchor.constraint(equalTo: cardView.topAnchor),
            cardStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            cardStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            cardStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),

            // Image height
            basketImageView.heightAnchor.constraint(equalToConstant: 180),

            // Button center + size (from you)
            donateButton.widthAnchor.constraint(equalToConstant: 190),
            donateButton.heightAnchor.constraint(equalToConstant: 42),
            donateButton.centerXAnchor.constraint(equalTo: buttonRow.centerXAnchor),
            donateButton.topAnchor.constraint(equalTo: buttonRow.topAnchor),
            donateButton.bottomAnchor.constraint(equalTo: buttonRow.bottomAnchor),

            // Give a little space in buttonRow
            buttonRow.heightAnchor.constraint(greaterThanOrEqualToConstant: 42)
        ])
    }

    // MARK: - Action
    @objc private func donateTapped() {
        // If DonateFundsViewController is in storyboard:
        // let vc = storyboard?.instantiateViewController(withIdentifier: "DonateFundsViewController") as! DonateFundsViewController
        // navigationController?.pushViewController(vc, animated: true)

        // If it's code-only:
        let vc = DonateFundsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
