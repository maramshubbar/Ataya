import UIKit

final class BasketDonationViewController: UIViewController {

    // MARK: - Constants
    private let atayaYellow = UIColor(red: 0xF7/255.0, green: 0xD4/255.0, blue: 0x4C/255.0, alpha: 1.0)

    // MARK: - UI (Skeleton)
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Basket Donation"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .black


        // ✅ 1) لازم نبني الlayout أول
        buildLayout()

        // ✅ 2) بعدين نضيف الكروت
        addBasketCard(
            title: "Basic Basket",
            descriptionText: """
            A simple basket with essential food items to support a small family's basic needs.
            Includes: Rice, lentils, canned beans, oil, and salt.
            Perfect for: Supporting individuals or small families with staple foods.
            """,
            imageName: "Basic basket",
            price: 10.0
        )

        addBasketCard(
            title: "Family Basket",
            descriptionText: """
            A variety of foods for a family of 4–6 people for several days.
            Includes: Rice, flour, canned vegetables, pasta, oil, lentils.
            Perfect for: Providing enough food for a family, offering a balanced mix of staples and meals.
            """,
            imageName: "Family Basket",
            price: 20.0
        )
        
        addBasketCard(
            title: "Emergency Basket",
            descriptionText: """
            A quick-prep basket for emergency situations, providing essentials for immediate needs.
            Includes: Canned goods, water, biscuits, juice.
            Perfect for: Providing immediate nourishment during crises or emergencies.
            """,
            imageName: "Emergency basket",
            price: 12.0
        )
        
        addBasketCard(
            title: "Healthy Basket",
            descriptionText: """
            A basket filled with fresh, wholesome foods to support a healthy lifestyle.
            Includes: Fruits, vegetables, whole grains, protein-rich items.
            Perfect for: Helping families maintain a nutritious, balanced diet with fresh ingredients.
            """,
            imageName: "Healthy baket",
            price: 18.0
        )
    }
    

    // MARK: - Layout
    private func buildLayout() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
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

            // IMPORTANT: contentView width equals scrollView frame width (vertical scroll)
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            // stackView pinned inside contentView
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    // MARK: - Cards
    private func addBasketCard(
        title: String,
        descriptionText: String,
        imageName: String,
        price: Double
    ) {

        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 24
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 10
        cardView.layer.masksToBounds = false

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .black

        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.attributedText = styledDescription(text: descriptionText)

        let priceLabel = UILabel()
        priceLabel.attributedText = styledPrice(amount: price)

        let donateButton = UIButton(type: .system)
        donateButton.setTitle("Donate", for: .normal)
        donateButton.backgroundColor = atayaYellow
        donateButton.setTitleColor(.black, for: .normal)
        donateButton.layer.cornerRadius = 4.6
        donateButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        donateButton.translatesAutoresizingMaskIntoConstraints = false
        donateButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        donateButton.widthAnchor.constraint(equalToConstant: 190).isActive = true

        // ✅ نخزن بيانات السلة داخل الزر
        donateButton.accessibilityIdentifier = title
        donateButton.tag = Int(price * 100) // 10 -> 1000
        donateButton.addTarget(self, action: #selector(donateBasketTapped(_:)), for: .touchUpInside)

        let buttonContainer = UIView()
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addSubview(donateButton)

        NSLayoutConstraint.activate([
            donateButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            donateButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            buttonContainer.heightAnchor.constraint(equalToConstant: 42)
        ])

        cardView.addSubview(imageView)
        cardView.addSubview(stack)

        stack.addArrangedSubview(titleLabel)
        stack.setCustomSpacing(12, after: titleLabel)

        stack.addArrangedSubview(descriptionLabel)

        stack.addArrangedSubview(priceLabel)
        stack.setCustomSpacing(16, after: priceLabel)

        stack.addArrangedSubview(buttonContainer)

        stackView.addArrangedSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.widthAnchor.constraint(equalToConstant: 352),
            cardView.heightAnchor.constraint(equalToConstant: 463),

            imageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 221),

            stack.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
    }

    // MARK: - Text styling
    private func styledDescription(text: String) -> NSAttributedString {
        let gray = UIColor(red: 0x5A/255, green: 0x5A/255, blue: 0x5A/255, alpha: 1)
        let regular = UIFont.systemFont(ofSize: 14)
        let bold = UIFont.systemFont(ofSize: 14, weight: .bold)

        let attr = NSMutableAttributedString(string: text, attributes: [
            .font: regular,
            .foregroundColor: gray
        ])

        ["Includes:", "Perfect for:"].forEach {
            let range = (text as NSString).range(of: $0)
            if range.location != NSNotFound {
                attr.setAttributes([.font: bold, .foregroundColor: UIColor.black], range: range)
            }
        }

        return attr
    }

    // ✅ صارت تستقبل Double
    private func styledPrice(amount: Double) -> NSAttributedString {
        let gray = UIColor(red: 0x5A/255, green: 0x5A/255, blue: 0x5A/255, alpha: 1)
        let regular = UIFont.systemFont(ofSize: 14)
        let bold = UIFont.systemFont(ofSize: 14, weight: .bold)

        let amountText = String(format: "$%.0f", amount)
        let full = "Price: \(amountText)"

        let attr = NSMutableAttributedString(string: full, attributes: [
            .font: regular,
            .foregroundColor: gray
        ])

        let range = (full as NSString).range(of: "Price:")
        if range.location != NSNotFound {
            attr.setAttributes([.font: bold, .foregroundColor: UIColor.black], range: range)
        }

        return attr
    }

    // MARK: - Action
    @objc private func donateBasketTapped(_ sender: UIButton) {
        let title = sender.accessibilityIdentifier ?? "Basket"
        let amount = Double(sender.tag) / 100.0

        let vc = DonateFundsViewController()
        vc.fixedAmount = amount
        vc.donationTitle = title
        navigationController?.pushViewController(vc, animated: true)
    }
}
