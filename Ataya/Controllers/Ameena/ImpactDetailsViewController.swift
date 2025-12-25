import UIKit

final class ImpactDetailsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!

    private let atayaYellow = UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 1)

    private enum ChartType { case bar, line, pie }
    private enum Period: Int { case daily = 0, monthly = 1, yearly = 2 }

    private var currentPeriod: Period = .daily

    private lazy var periodControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Daily", "Monthly", "Yearly"])
        sc.selectedSegmentIndex = Period.daily.rawValue
        sc.selectedSegmentTintColor = atayaYellow
        sc.addTarget(self, action: #selector(periodChanged(_:)), for: .valueChanged)
        return sc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Impact Dashboard"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground

        configureScrollBehavior()
        configureStackView()

        scrollView.contentInset.bottom = 24
        scrollView.verticalScrollIndicatorInsets.bottom = 24

        mainStackView.addArrangedSubview(periodControl)
        periodControl.heightAnchor.constraint(equalToConstant: 36).isActive = true

        buildCards(for: currentPeriod)
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

    @objc private func periodChanged(_ sender: UISegmentedControl) {
        currentPeriod = Period(rawValue: sender.selectedSegmentIndex) ?? .daily
        buildCards(for: currentPeriod)
        scrollView.setContentOffset(.zero, animated: true)
    }

    private func buildCards(for period: Period) {
        mainStackView.arrangedSubviews
            .filter { $0 !== periodControl }
            .forEach {
                mainStackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }

        let meals = contentMeals(for: period)
        let waste = contentWaste(for: period)
        let env = contentEnv(for: period)

        let mealsCard = makeBigCard(
            title: "Meals Provided",
            description: meals.description,
            chartType: .bar
        )

        let wasteCard = makeBigCard(
            title: "Food Waste Prevented",
            description: waste.description,
            chartType: .line
        )

        let envCard = makeBigCard(
            title: "Environmental Equivalent",
            description: env.description,
            chartType: .pie
        )

        mainStackView.addArrangedSubview(mealsCard)
        mainStackView.addArrangedSubview(wasteCard)
        mainStackView.addArrangedSubview(envCard)
    }

    // MARK: - Period content (replace with your real calculations)

    private func contentMeals(for period: Period) -> (description: String, value: Int) {
        switch period {
        case .daily:   return ("You have shared 5 meals with people in need ……", 5)
        case .monthly: return ("You have shared 145 meals with people in need ……", 145)
        case .yearly:  return ("You have shared 1,420 meals with people in need ……", 1420)
        }
    }

    private func contentWaste(for period: Period) -> (description: String, value: Int) {
        switch period {
        case .daily:   return ("Your consistent donations have prevented 2% of food ……", 2)
        case .monthly: return ("Your consistent donations have prevented 32% of food ……", 32)
        case .yearly:  return ("Your consistent donations have prevented 58% of food ……", 58)
        }
    }

    private func contentEnv(for period: Period) -> (description: String, value: Int) {
        switch period {
        case .daily:   return ("Your donations helped reduce emissions equivalent to 1 short trip ……", 1)
        case .monthly: return ("Your donations helped reduce emissions equivalent to 12 short trips ……", 12)
        case .yearly:  return ("Your donations helped reduce emissions equivalent to 140 short trips ……", 140)
        }
    }

    // MARK: - Card Factory

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
        print("Read More tapped for card:", sender.tag)
    }
}
