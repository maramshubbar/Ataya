import UIKit

final class ImpactDetailsViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    private let atayaYellow = UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 1)

    private enum ChartType { case bar, line, pie }

    private enum Period: Int { case daily = 0, monthly = 1, yearly = 2 }

    private var currentPeriod: Period = .daily
    private var pendingSection: Int = 1

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

        configureScroll()
        configureStack()

        if periodControl.superview == nil {
            mainStackView.insertArrangedSubview(periodControl, at: 0)
            periodControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
        }

        buildCards(for: currentPeriod)
    }

    private func configureScroll() {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .automatic
        }
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        scrollView.contentInset.bottom = 24
        scrollView.verticalScrollIndicatorInsets.bottom = 24
    }

    private func configureStack() {
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

        let mealsCard = makeBigCard(
            title: "Meals Provided",
            description: mealsDescription(for: period),
            chartType: .bar
        )

        let wasteCard = makeBigCard(
            title: "Food Waste Prevented",
            description: wasteDescription(for: period),
            chartType: .line
        )

        let envCard = makeBigCard(
            title: "Environmental Equivalent",
            description: envDescription(for: period),
            chartType: .pie
        )

        mainStackView.addArrangedSubview(mealsCard)
        mainStackView.addArrangedSubview(wasteCard)
        mainStackView.addArrangedSubview(envCard)
    }

    private func mealsDescription(for period: Period) -> String {
        switch period {
        case .daily: return "You have shared 5 meals with people in need ……"
        case .monthly: return "You have shared 145 meals with people in need ……"
        case .yearly: return "You have shared 1,420 meals with people in need ……"
        }
    }

    private func wasteDescription(for period: Period) -> String {
        switch period {
        case .daily: return "Your consistent donations have prevented 2% of food ……"
        case .monthly: return "Your consistent donations have prevented 32% of food ……"
        case .yearly: return "Your consistent donations have prevented 58% of food ……"
        }
    }

    private func envDescription(for period: Period) -> String {
        switch period {
        case .daily: return "Your donations helped the environment too ……"
        case .monthly: return "Your donations helped the environment too ……"
        case .yearly: return "Your donations helped the environment too ……"
        }
    }

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

        let topTitle = UILabel()
        topTitle.text = title
        topTitle.textAlignment = .center
        topTitle.font = .systemFont(ofSize: 16, weight: .semibold)

        let chartContainer = UIView()
        chartContainer.backgroundColor = UIColor.systemGray6
        chartContainer.layer.cornerRadius = 12
        chartContainer.translatesAutoresizingMaskIntoConstraints = false
        chartContainer.heightAnchor.constraint(equalToConstant: 220).isActive = true

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

        let tag: Int
        switch chartType {
        case .bar: tag = 1
        case .line: tag = 2
        case .pie: tag = 3
        }
        readMore.tag = tag

        let bottomRow = UIStackView(arrangedSubviews: [body, readMore])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .bottom
        bottomRow.spacing = 12

        body.setContentHuggingPriority(.defaultLow, for: .horizontal)
        readMore.setContentHuggingPriority(.required, for: .horizontal)
        readMore.setContentCompressionResistancePriority(.required, for: .horizontal)

        vStack.addArrangedSubview(topTitle)
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
        let sb = UIStoryboard(name: "Main", bundle: nil)

        let rawVC = sb.instantiateViewController(withIdentifier: "SharePreviewViewController")

        guard let vc = rawVC as? SharePreviewViewController else {
            assertionFailure("Storyboard ID exists but class is not SharePreviewViewController. Check Identity Inspector (Class/Module).")
            return
        }

        vc.selectedSection = sender.tag
        vc.selectedPeriod = currentPeriod.rawValue

        navigationController?.pushViewController(vc, animated: true)
    }
}
            
