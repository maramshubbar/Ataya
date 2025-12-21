import UIKit

final class RecurringDonationViewController: UIViewController {

    // MARK: - Storyboard Outlets (ONLY these)
    @IBOutlet weak var calendarView: UIDatePicker!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - Code UI
    private let selectLabel = UILabel()

    private let periodStack = UIStackView()
    private let dailyButton = UIButton(type: .system)
    private let weeklyButton = UIButton(type: .system)
    private let monthlyButton = UIButton(type: .system)

    private enum Period: String { case daily, weekly, monthly }
    private var selectedPeriod: Period?

    // If you want to store chosen date too:
    private var selectedDate: Date { calendarView.date }

    private let yellow = UIColor(red: 0xF7/255.0, green: 0xD4/255.0, blue: 0x4C/255.0, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        styleNextButton()
        buildLabel()
        buildPeriodButtons()
        setupLayout()

        // ✅ Make sure Next triggers our validation (works even if storyboard action not connected)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
    }

    // MARK: - Label
    private func buildLabel() {
        selectLabel.text = "Select Relevant Period"
        selectLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        selectLabel.textColor = .label
        selectLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectLabel)
    }

    // MARK: - Next button style
    private func styleNextButton() {
        nextButton.layer.cornerRadius = 8
        nextButton.layer.masksToBounds = true
        nextButton.backgroundColor = yellow
        nextButton.setTitleColor(.black, for: .normal)
        nextButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    // MARK: - Period buttons
    private func buildPeriodButtons() {
        [dailyButton, weeklyButton, monthlyButton].forEach {
            $0.configuration = nil // avoid iOS15 configuration padding issues
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

        updatePeriodUI(nil)
    }

    private func stylePeriodButton(_ button: UIButton) {
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = yellow.cgColor
        button.layer.masksToBounds = true
        button.backgroundColor = .clear
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    }

    private func updatePeriodUI(_ selected: Period?) {
        [dailyButton, weeklyButton, monthlyButton].forEach {
            $0.backgroundColor = .clear
            $0.layer.borderColor = yellow.cgColor
        }

        let target: UIButton?
        switch selected {
        case .daily: target = dailyButton
        case .weekly: target = weeklyButton
        case .monthly: target = monthlyButton
        case .none: target = nil
        }

        target?.backgroundColor = yellow
        target?.layer.borderColor = yellow.cgColor
    }

    // MARK: - Layout
    private func setupLayout() {
        let safe = view.safeAreaLayoutGuide

        selectLabel.translatesAutoresizingMaskIntoConstraints = false
        periodStack.translatesAutoresizingMaskIntoConstraints = false
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        calendarView.setContentHuggingPriority(.defaultLow, for: .vertical)
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        NSLayoutConstraint.activate([
            // Label
            selectLabel.topAnchor.constraint(equalTo: safe.topAnchor, constant: 24),
            selectLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            selectLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),

            // Buttons
            periodStack.topAnchor.constraint(equalTo: selectLabel.bottomAnchor, constant: 30),
            periodStack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            periodStack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
            periodStack.heightAnchor.constraint(equalToConstant: 40),

            // Next button bottom
            nextButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -16),
            nextButton.heightAnchor.constraint(equalToConstant: 54),

            // Calendar
            calendarView.topAnchor.constraint(equalTo: periodStack.bottomAnchor, constant: 40),
            calendarView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            calendarView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
            calendarView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -70)
        ])
    }

    // MARK: - Alert
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Actions
    @objc private func dailyTapped() {
        selectedPeriod = .daily
        updatePeriodUI(.daily)
    }

    @objc private func weeklyTapped() {
        selectedPeriod = .weekly
        updatePeriodUI(.weekly)
    }

    @objc private func monthlyTapped() {
        selectedPeriod = .monthly
        updatePeriodUI(.monthly)
    }

    // ✅ Next button: validate then go next
    @objc private func nextTapped() {
        print("✅ Next tapped")
        guard let period = selectedPeriod else {
            showAlert(title: "Select a period", message: "Please choose Daily, Weekly, or Monthly before continuing.")
            return
        }

        // ✅ Save your chosen option (if you want to store it)
        // UserDefaults.standard.set(period.rawValue, forKey: "recurring_period")

        // ✅ Save your chosen date (optional)
        // UserDefaults.standard.set(selectedDate.timeIntervalSince1970, forKey: "recurring_date")

        // ✅ Go to next page (segue)
        performSegue(withIdentifier: "goToRecurringDetails", sender: self)

        // If you use navigation push instead, tell me and I’ll change it.
        print("Selected Period:", period.rawValue, "Selected Date:", selectedDate)
    }

    // MARK: - Pass data to next page (optional but ready)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "goToRecurringDetails" else { return }
        guard let period = selectedPeriod else { return }

        // Example:
        // let vc = segue.destination as! RecurringDonationDetailsViewController
        // vc.selectedPeriod = period.rawValue
        // vc.selectedDate = selectedDate
    }
}
