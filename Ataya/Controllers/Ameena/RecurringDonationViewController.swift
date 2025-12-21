import UIKit

final class recurringDonationViewController: UIViewController {
    
    // MARK: - Storyboard Outlets (ONLY these)
    @IBOutlet weak var nextButton: UIButton!
    
    
    @IBOutlet weak var calendarView: UIDatePicker!
    
    // MARK: - Code UI
    private let selectLabel = UILabel()
    
    private let periodStack = UIStackView()
    private let dailyButton = UIButton(type: .system)
    private let weeklyButton = UIButton(type: .system)
    private let monthlyButton = UIButton(type: .system)
    
    private enum Period { case daily, weekly, monthly }
    private var selectedPeriod: Period?
    
    private let yellow = UIColor(red: 0xF7/255.0, green: 0xD4/255.0, blue: 0x4C/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation title (if you want it in code too; otherwise set in storyboard)
        // self.title = "Recurring Donation"
        navigationItem.largeTitleDisplayMode = .never
        styleNextButton()
        buildLabel()
        buildPeriodButtons()
        setupLayout()
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
        
    // Turn off autoresizing masks
    selectLabel.translatesAutoresizingMaskIntoConstraints = false
    periodStack.translatesAutoresizingMaskIntoConstraints = false
    calendarView.translatesAutoresizingMaskIntoConstraints = false
    nextButton.translatesAutoresizingMaskIntoConstraints = false
    
    // Make calendar willing to stretch
    calendarView.setContentHuggingPriority(.defaultLow, for: .vertical)
    calendarView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    
    NSLayoutConstraint.activate([
        // Label (will sit correctly under the nav bar)
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
        
        // Calendar fills between buttons and Next (no big gap)
        calendarView.topAnchor.constraint(equalTo: periodStack.bottomAnchor, constant: 40),
        calendarView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
        calendarView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
        calendarView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -70)
    ])
}
    
    // MARK: - Actions
    @objc private func dailyTapped() { selectedPeriod = .daily; updatePeriodUI(.daily) }
    @objc private func weeklyTapped() { selectedPeriod = .weekly; updatePeriodUI(.weekly) }
    @objc private func monthlyTapped() { selectedPeriod = .monthly; updatePeriodUI(.monthly) }
}
