import UIKit

final class RecurringDonationViewController: UIViewController {
    
    // MARK: - Storyboard Outlets (ONLY these)
    
    @IBOutlet weak var calendarView: UIDatePicker!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - Draft (shared data for the whole flow)
    var draft = RecurringDonationDraft()

    // MARK: - UI (built in code)
    private let selectLabel = UILabel()

    private let periodStack = UIStackView()
    private let dailyButton = UIButton(type: .system)
    private let weeklyButton = UIButton(type: .system)
    private let monthlyButton = UIButton(type: .system)

    private enum Period: String {
        case daily, weekly, monthly
    }
    private var selectedPeriod: Period = .monthly {
        didSet { updatePeriodUI(selectedPeriod) }
    }

    private let atayaYellow = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true

        // Hide tab bar for the whole recurring donation flow
        self.hidesBottomBarWhenPushed = true

        navigationItem.largeTitleDisplayMode = .never

        setupCalendar()
        styleNextButton()
        buildLabel()
        buildPeriodButtons()
        setupLayout()
        view.bringSubviewToFront(nextButton)


        // Default selection
        selectedPeriod = .monthly
    }

    // MARK: - Calendar
    private func setupCalendar() {
        // Ensure the date picker is in date-only mode
        calendarView.datePickerMode = .date

        // Listen to date changes
        calendarView.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }

    @objc private func dateChanged() {
        // No action needed here beyond keeping the selected date available
        // Data will be written to draft when Next is tapped
    }

    // MARK: - Label
    private func buildLabel() {
        selectLabel.text = "Select Relevant Period"
        selectLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        selectLabel.textColor = .label
        selectLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectLabel)
    }

    // MARK: - Next Button
    private func styleNextButton() {
        nextButton.layer.cornerRadius = 8
        nextButton.layer.masksToBounds = true
        nextButton.backgroundColor = atayaYellow
        nextButton.setTitleColor(.black, for: .normal)

        // Wire the button tap
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
    }

    @objc private func nextTapped() {
        // Build values from current UI state
        let frequency = selectedPeriod.rawValue
        let startDate = calendarView.date
        let nextPickupDate = calculateNextPickupDate(from: startDate, period: selectedPeriod)

        // Update the shared draft
        draft.frequency = frequency
        draft.startDate = startDate
        draft.nextPickupDate = nextPickupDate

        // Navigate to the next page (Storyboard-based)
        let storyboard = UIStoryboard(name: "Recurring", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "RecurringDonationDetailsViewController") as? RecurringDonationDetailsViewController else {
            assertionFailure("RecurringDonationDetailsViewController storyboard ID is missing or incorrect.")
            return
        }

        vc.draft = draft
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func calculateNextPickupDate(from start: Date, period: Period) -> Date {
        var components = DateComponents()

        switch period {
        case .daily:
            components.day = 1
        case .weekly:
            components.day = 7
        case .monthly:
            components.month = 1
        }

        return Calendar.current.date(byAdding: components, to: start) ?? start
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hidesBottomBarWhenPushed = true
    }

    // MARK: - Period Buttons
    private func buildPeriodButtons() {
        [dailyButton, weeklyButton, monthlyButton].forEach {
            $0.configuration = nil // Avoid iOS 15 configuration padding issues
            stylePeriodButton($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }

        dailyButton.setTitle("Daily", for: .normal)
        weeklyButton.setTitle("Weekly", for: .normal)
        monthlyButton.setTitle("Monthly", for: .normal)

        dailyButton.addTarget(self, action: #selector(dailyTapped), for: .touchUpInside)
        weeklyButton.addTarget(self, action: #selector(weeklyTapped), for: .touchUpInside)
        monthlyButton.addTarget(self, action: #selector(monthlyTapped), for: .touchUpInside)

        periodStack.axis = .horizontal
        periodStack.spacing = 12
        periodStack.distribution = .fillEqually
        periodStack.translatesAutoresizingMaskIntoConstraints = false

        periodStack.addArrangedSubview(dailyButton)
        periodStack.addArrangedSubview(weeklyButton)
        periodStack.addArrangedSubview(monthlyButton)

        view.addSubview(periodStack)
    }

    private func stylePeriodButton(_ button: UIButton) {
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = atayaYellow.withAlphaComponent(0.6).cgColor
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    }

    private func updatePeriodUI(_ selected: Period) {
        // Reset
        [dailyButton, weeklyButton, monthlyButton].forEach {
            $0.backgroundColor = .white
            $0.layer.borderColor = atayaYellow.withAlphaComponent(0.6).cgColor
            $0.setTitleColor(.black, for: .normal)
        }

        // Selected
        let target: UIButton
        switch selected {
        case .daily:
            target = dailyButton
        case .weekly:
            target = weeklyButton
        case .monthly:
            target = monthlyButton
        }

        target.backgroundColor = atayaYellow
        target.layer.borderColor = atayaYellow.cgColor
        target.setTitleColor(.black, for: .normal)
    }

    // MARK: - Layout
    private func setupLayout() {
        let safe = view.safeAreaLayoutGuide

        // Ensure storyboard outlets do not use autoresizing masks
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        calendarView.setContentHuggingPriority(.defaultLow, for: .vertical)
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        NSLayoutConstraint.activate([
            // Label
            selectLabel.topAnchor.constraint(equalTo: safe.topAnchor, constant: 24),
            selectLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            selectLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),

            // Period buttons
            periodStack.topAnchor.constraint(equalTo: selectLabel.bottomAnchor, constant: 30),
            periodStack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            periodStack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
            periodStack.heightAnchor.constraint(equalToConstant: 40),

            // Next button
            nextButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -16),
            nextButton.heightAnchor.constraint(equalToConstant: 54),

            // Calendar between period buttons and Next button
            calendarView.topAnchor.constraint(equalTo: periodStack.bottomAnchor, constant: 40),
            calendarView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            calendarView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
            calendarView.bottomAnchor.constraint(lessThanOrEqualTo: nextButton.topAnchor, constant: -20)
        ])
    }

    // MARK: - Actions
    @objc private func dailyTapped() { selectedPeriod = .daily; updatePeriodUI(.daily) }
    @objc private func weeklyTapped() { selectedPeriod = .weekly; updatePeriodUI(.weekly) }
    @objc private func monthlyTapped() { selectedPeriod = .monthly; updatePeriodUI(.monthly) }
}
