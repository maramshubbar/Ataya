import UIKit

final class ImpactDetailsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    private let atayaYellow = UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Impact Dashboard"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground

        configureScrollBehavior()
        configureStackView()
        buildCards()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }

    private func configureScrollBehavior() {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .automatic
        }
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
    }

    private func configureStackView() {
        mainStackView.axis = .vertical
        mainStackView.spacing = 24
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
    }

    private func buildCards() {
        mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let mealsCard = makeBigCard(
            title: "Meals Provided",
            description: "You have shared 145 meals with people in need ……",
            chartType: .bar
        )

        let wasteCard = makeBigCard(
            title: "Food Waste Prevented",
            description: "Your consistent donations have prevented 32% of food ……",
            chartType: .line
        )

        let envCard = makeBigCard(
            title: "Environmental Equivalent",
            description: "Your donations didn’t just help people — they helped the environment too……",
            chartType: .pie
        )

        mainStackView.addArrangedSubview(mealsCard)
        mainStackView.addArrangedSubview(wasteCard)
        mainStackView.addArrangedSubview(envCard)
    }

    // MARK: - Card Factory

    private enum ChartType { case bar, line, pie }

    private func makeBigCard(title: String, description: String, chartType: ChartType) -> UIView {

        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.10
        card.layer.shadowRadius = 10
        card.layer.shadowOffset = CGSize(width: 0, height: 6)

        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 12
        vStack.alignment = .fill
        vStack.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 1

        let chartContainer = UIView()
        chartContainer.backgroundColor = UIColor.systemGray6
        chartContainer.layer.cornerRadius = 12
        chartContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartContainer.heightAnchor.constraint(equalToConstant: 220)
        ])

        let bottomTitle = UILabel()
        bottomTitle.text = title
        bottomTitle.font = .systemFont(ofSize: 18, weight: .bold)
        bottomTitle.numberOfLines = 1

        let body = UILabel()
        body.text = description
        body.font = .systemFont(ofSize: 14, weight: .regular)
        body.textColor = .secondaryLabel
        body.numberOfLines = 0

        let readMore = UIButton(type: .system)
        readMore.setTitle("Read More", for: .normal)
        readMore.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        readMore.contentHorizontalAlignment = .right
        readMore.addTarget(self, action: #selector(readMoreTapped(_:)), for: .touchUpInside)

        readMore.tag = (chartType == .bar ? 1 : chartType == .line ? 2 : 3)

        let bottomRow = UIStackView(arrangedSubviews: [body, readMore])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .bottom
        bottomRow.spacing = 12

        body.setContentHuggingPriority(.defaultLow, for: .horizontal)
        readMore.setContentHuggingPriority(.required, for: .horizontal)
        readMore.setContentCompressionResistancePriority(.required, for: .horizontal)

        vStack.addArrangedSubview(titleLabel)
        vStack.addArrangedSubview(chartContainer)
        vStack.addArrangedSubview(bottomTitle)
        vStack.addArrangedSubview(bottomRow)

        card.addSubview(vStack)

        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            vStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            vStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }

    @objc private func readMoreTapped(_ sender: UIButton) {
        // 1 = meals, 2 = waste, 3 = env
        print("Read More tapped for card:", sender.tag)

        // If you want to force-scroll to top before pushing a details screen:
        // scrollView.setContentOffset(.zero, animated: true)
    }
}
