import UIKit
import FirebaseFirestore
import FirebaseAuth

// MARK: - Donate Funds (UIKit / built by code)
final class DonateFundsViewController: UIViewController {

    // MARK: - Colors (Ataya)
    private let atayaYellow = UIColor(red: 0xF7/255.0, green: 0xD4/255.0, blue: 0x4C/255.0, alpha: 1.0)
    private let optionBG    = UIColor(red: 0xFF/255.0, green: 0xFB/255.0, blue: 0xE7/255.0, alpha: 1.0)
    private let textGray    = UIColor(red: 90/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1.0)
    private let iconGray    = UIColor.systemGray2

    // MARK: - Firestore
    private let db = Firestore.firestore()

    // MARK: - Data (NGOs from Firestore)
    private var ngoItems: [NGOItem] = []          // loaded from Firebase
    private var ngoNames: [String] { ngoItems.map { $0.name } }  // names only for dropdown

    private let paymentMethods: [PaymentMethod] = [
        .init(type: .visa, title: "**** **** **** 8970", subtitle: "Expires: 12/26"),
        .init(type: .applePay, title: "Apple Pay", subtitle: nil)
    ]

    private var selectedNGO: NGOItem? {
        didSet { ngoDropdown.setValue(selectedNGO?.name ?? "Select NGO") }
    }

    private var amount: Int = 10 {
        didSet { amountField.setAmount(amount) }
    }

    private var selectedPayment: PaymentMethodType = .visa {
        didSet { updatePaymentSelectionUI() }
    }

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let amountLabel = UILabel()
    private let amountField = AmountDropdownField()

    private let ngoLabel = UILabel()
    private let ngoDropdown = DropdownField()

    private let addPaymentButton = UIButton(type: .system)

    private let selectPaymentLabel = UILabel()
    private let paymentStack = UIStackView()

    private let confirmButton = UIButton(type: .system)

    // Payment rows
    private var paymentRows: [PaymentOptionView] = []

    // MARK: - State
    private var isNGOLoading = false
    private var isSubmitting = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .black
        navigationItem.backButtonTitle = ""

        buildUI()
        setupLayout()
        bind()
        applyInitialState()

        // Fetch NGOs from Firestore after UI is ready
        fetchNGOs()
    }

    var fixedAmount: Double = 0
    var donationTitle: String = ""

    // MARK: - Build UI
    private func buildUI() {
        // Scroll setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Title in nav bar
        navigationItem.title = "Donate"
        navigationItem.largeTitleDisplayMode = .never

        // Label helper
        func styleFieldLabel(_ l: UILabel, text: String) {
            l.text = text
            l.font = .systemFont(ofSize: 15, weight: .semibold)
            l.textColor = .black
            l.translatesAutoresizingMaskIntoConstraints = false
        }

        styleFieldLabel(amountLabel, text: "Enter Amount")
        styleFieldLabel(ngoLabel, text: "NGO Name")

        // Amount field (dropdown-like with arrows)
        amountField.translatesAutoresizingMaskIntoConstraints = false
        amountField.setAmount(amount)
        amountField.minimumAmount = 5
        amountField.textGray = .black
        amountField.arrowTint = iconGray

        // NGO dropdown field
        ngoDropdown.translatesAutoresizingMaskIntoConstraints = false
        ngoDropdown.textGray = textGray
        ngoDropdown.setValue("Loading NGOs...")
        ngoDropdown.chevronSize = 18

        // Add payment method button
        addPaymentButton.setTitle("Add payment Method", for: .normal)
        addPaymentButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        addPaymentButton.setTitleColor(.systemBlue, for: .normal)
        addPaymentButton.contentHorizontalAlignment = .right
        addPaymentButton.translatesAutoresizingMaskIntoConstraints = false

        // Select payment label
        selectPaymentLabel.text = "Select Payment Method"
        selectPaymentLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        selectPaymentLabel.textColor = .black
        selectPaymentLabel.textAlignment = .left
        selectPaymentLabel.translatesAutoresizingMaskIntoConstraints = false

        // Payment stack
        paymentStack.axis = .vertical
        paymentStack.spacing = 12
        paymentStack.translatesAutoresizingMaskIntoConstraints = false

        // Build payment rows
        paymentRows = paymentMethods.map { method in
            let v = PaymentOptionView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.configure(
                iconType: method.type,
                title: method.title,
                subtitle: method.subtitle,
                optionBG: optionBG,
                borderColor: atayaYellow,
                textGray: textGray
            )
            v.onTap = { [weak self] in
                self?.selectedPayment = method.type
            }
            return v
        }
        paymentRows.forEach { paymentStack.addArrangedSubview($0) }

        // Confirm button pinned to bottom
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.backgroundColor = atayaYellow
        confirmButton.setTitleColor(.black, for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        confirmButton.layer.cornerRadius = 8
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(confirmButton)

        // Add all subviews
        [amountLabel, amountField,
         ngoLabel, ngoDropdown, addPaymentButton,
         selectPaymentLabel, paymentStack
        ].forEach { contentView.addSubview($0) }
    }

    // MARK: - Layout
    private func setupLayout() {
        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            confirmButton.widthAnchor.constraint(equalToConstant: 362),
            confirmButton.heightAnchor.constraint(equalToConstant: 54),
            confirmButton.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -16),

            scrollView.topAnchor.constraint(equalTo: safe.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -12),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])

        NSLayoutConstraint.activate([
            amountField.widthAnchor.constraint(equalToConstant: 370),
            amountField.heightAnchor.constraint(equalToConstant: 60),
            ngoDropdown.widthAnchor.constraint(equalToConstant: 370),
            ngoDropdown.heightAnchor.constraint(equalToConstant: 60),
        ])

        paymentRows.forEach { row in
            row.heightAnchor.constraint(equalToConstant: 56).isActive = true
            row.widthAnchor.constraint(equalToConstant: 362).isActive = true
        }

        NSLayoutConstraint.activate([
            amountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            amountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            amountField.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 8),
            amountField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            ngoLabel.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 18),
            ngoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            ngoDropdown.topAnchor.constraint(equalTo: ngoLabel.bottomAnchor, constant: 8),
            ngoDropdown.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            addPaymentButton.topAnchor.constraint(equalTo: ngoDropdown.bottomAnchor, constant: 8),
            addPaymentButton.trailingAnchor.constraint(equalTo: ngoDropdown.trailingAnchor),
            addPaymentButton.heightAnchor.constraint(equalToConstant: 18),

            selectPaymentLabel.topAnchor.constraint(equalTo: addPaymentButton.bottomAnchor, constant: 24),
            selectPaymentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            selectPaymentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            paymentStack.topAnchor.constraint(equalTo: selectPaymentLabel.bottomAnchor, constant: 12),
            paymentStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            paymentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Bind
    private func bind() {
        // NGO dropdown tap -> action sheet
        ngoDropdown.onTap = { [weak self] in
            guard let self else { return }

            // If NGOs are still loading, do nothing (or show message)
            if self.isNGOLoading {
                self.showAlert(title: "Please wait", message: "NGOs are still loading.")
                return
            }

            // If there are no NGOs, show message
            if self.ngoItems.isEmpty {
                self.showAlert(title: "No NGOs", message: "No NGOs found in the database.")
                return
            }

            let current = self.selectedNGO?.name ?? ""
            self.presentOptions(title: "NGO", options: self.ngoNames, selected: current) { pickedName in
                self.selectedNGO = self.ngoItems.first(where: { $0.name == pickedName })
            }
        }

        // Amount arrows changes
        amountField.onChange = { [weak self] newValue in
            self?.amount = newValue
        }

        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        addPaymentButton.addTarget(self, action: #selector(addPaymentTapped), for: .touchUpInside)
    }

    private func applyInitialState() {
        amount = max(10, 5)
        selectedPayment = .visa
        updatePaymentSelectionUI()
        confirmButton.isEnabled = true
    }

    private func updatePaymentSelectionUI() {
        for row in paymentRows {
            row.setSelected(row.iconType == selectedPayment)
        }
    }

    // MARK: - Firestore: Fetch NGOs
    private func fetchNGOs() {
        isNGOLoading = true
        ngoDropdown.setValue("Loading NGOs...")

        // NOTE: Adjust field names if your NGO docs use a different key than "name"
        db.collection("ngos")
            .getDocuments { [weak self] snap, err in
                guard let self else { return }
                self.isNGOLoading = false

                if let err {
                    self.ngoDropdown.setValue("Failed to load NGOs")
                    self.showAlert(title: "Error", message: "Failed to load NGOs: \(err.localizedDescription)")
                    return
                }

                let docs = snap?.documents ?? []
                self.ngoItems = docs.compactMap { doc in
                    let data = doc.data()
                    let name = (data["name"] as? String) ?? (data["ngoName"] as? String) ?? ""
                    guard !name.isEmpty else { return nil }
                    return NGOItem(id: doc.documentID, name: name)
                }.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })

                // Set default selection
                if let first = self.ngoItems.first {
                    self.selectedNGO = first
                } else {
                    self.selectedNGO = nil
                    self.ngoDropdown.setValue("No NGOs")
                }
            }
    }

    // MARK: - Actions
    @objc private func addPaymentTapped() {
        let vc = AddPaymentMethodViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func confirmTapped() {
        // Prevent double tap
        guard !isSubmitting else { return }
        isSubmitting = true
        confirmButton.isEnabled = false

        // Basic validation
        guard let ngo = selectedNGO else {
            isSubmitting = false
            confirmButton.isEnabled = true
            showAlert(title: "Missing NGO", message: "Please select an NGO.")
            return
        }

        // Create donation record (simulation)
        let donorId = Auth.auth().currentUser?.uid ?? "USER_UID"
        let amountBHD = Double(amount) // store as Number in Firestore
        let paymentMethod = selectedPayment.rawValue

        let payload: [String: Any] = [
            "amountBHD": amountBHD,                        // Number ✅
            "createdAt": FieldValue.serverTimestamp(),     // Timestamp ✅
            "donorId": donorId,
            "ngoId": ngo.id,
            "ngoName": ngo.name,
            "paymentMethod": paymentMethod,
            "status": "success"                            // simulation ✅
        ]

        db.collection("fund_donations").addDocument(data: payload) { [weak self] err in
            guard let self else { return }
            self.isSubmitting = false
            self.confirmButton.isEnabled = true

            if let err {
                self.showAlert(title: "Failed", message: "Could not save donation: \(err.localizedDescription)")
                return
            }

            // Show success popup ONLY after Firestore write succeeds
            let vc = DonationSuccessViewController()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
        }
    }

    // MARK: - Helpers
    private func presentOptions(title: String, options: [String], selected: String, onPick: @escaping (String) -> Void) {
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)

        options.forEach { opt in
            let action = UIAlertAction(title: opt + (opt == selected ? " ✓" : ""), style: .default) { _ in
                onPick(opt)
            }
            ac.addAction(action)
        }

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // iPad safety
        if let pop = ac.popoverPresentationController {
            pop.sourceView = ngoDropdown
            pop.sourceRect = ngoDropdown.bounds
        }

        present(ac, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

// MARK: - Firestore NGO model
private struct NGOItem {
    let id: String
    let name: String
}

// MARK: - Models
private enum PaymentMethodType: String {
    case visa = "Visa"
    case applePay = "Apple Pay"
}

private struct PaymentMethod {
    let type: PaymentMethodType
    let title: String
    let subtitle: String?
}

// MARK: - DropdownField (textfield-like with chevron)
private final class DropdownField: UIControl {

    var onTap: (() -> Void)?

    var textGray: UIColor = .darkGray {
        didSet { valueLabel.textColor = textGray }
    }

    var chevronSize: CGFloat = 14 {
        didSet {
            chevronWidthConstraint?.constant = chevronSize
            chevronHeightConstraint?.constant = chevronSize
            layoutIfNeeded()
        }
    }

    private let container = UIView()
    private let valueLabel = UILabel()
    private let chevron = UIImageView()

    private var chevronWidthConstraint: NSLayoutConstraint?
    private var chevronHeightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray5.cgColor

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 15, weight: .medium)
        valueLabel.textColor = textGray

        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
        chevron.tintColor = .black
        chevron.contentMode = .scaleAspectFit

        container.isUserInteractionEnabled = false
        valueLabel.isUserInteractionEnabled = false
        chevron.isUserInteractionEnabled = false

        addSubview(container)
        container.addSubview(valueLabel)
        container.addSubview(chevron)

        chevronWidthConstraint = chevron.widthAnchor.constraint(equalToConstant: chevronSize)
        chevronHeightConstraint = chevron.heightAnchor.constraint(equalToConstant: chevronSize)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),

            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),

            chevronWidthConstraint!,
            chevronHeightConstraint!,
        ])

        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    func setValue(_ text: String) {
        valueLabel.text = text
    }

    @objc private func tapped() {
        onTap?()
    }
}

// MARK: - AmountDropdownField (textfield-like + up/down arrows, min 5$)
private final class AmountDropdownField: UIControl {

    var onChange: ((Int) -> Void)?

    var minimumAmount: Int = 5
    var maximumAmount: Int = 9999

    var textGray: UIColor = .darkGray {
        didSet { valueLabel.textColor = textGray }
    }

    var arrowTint: UIColor = .systemGray2 {
        didSet {
            upButton.tintColor = arrowTint
            downButton.tintColor = arrowTint
        }
    }

    private let container = UIView()
    private let valueLabel = UILabel()

    private let upButton = UIButton(type: .system)
    private let downButton = UIButton(type: .system)
    private let arrowsStack = UIStackView()

    private var currentAmount: Int = 5

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray5.cgColor

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 15, weight: .medium)
        valueLabel.textColor = textGray

        upButton.translatesAutoresizingMaskIntoConstraints = false
        downButton.translatesAutoresizingMaskIntoConstraints = false

        upButton.setImage(UIImage(systemName: "chevron.up")?.withRenderingMode(.alwaysTemplate), for: .normal)
        downButton.setImage(UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate), for: .normal)

        upButton.tintColor = arrowTint
        downButton.tintColor = arrowTint

        upButton.addTarget(self, action: #selector(increase), for: .touchUpInside)
        downButton.addTarget(self, action: #selector(decrease), for: .touchUpInside)

        arrowsStack.axis = .vertical
        arrowsStack.spacing = 2
        arrowsStack.alignment = .center
        arrowsStack.distribution = .fillEqually
        arrowsStack.translatesAutoresizingMaskIntoConstraints = false
        arrowsStack.addArrangedSubview(upButton)
        arrowsStack.addArrangedSubview(downButton)

        container.isUserInteractionEnabled = true
        valueLabel.isUserInteractionEnabled = true
        arrowsStack.isUserInteractionEnabled = true

        addSubview(container)
        container.addSubview(valueLabel)
        container.addSubview(arrowsStack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),

            arrowsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            arrowsStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            arrowsStack.widthAnchor.constraint(equalToConstant: 24),
            arrowsStack.heightAnchor.constraint(equalToConstant: 24),
        ])
    }

    func setAmount(_ value: Int) {
        currentAmount = max(minimumAmount, min(maximumAmount, value))
        valueLabel.text = "\(currentAmount)$"
    }

    @objc private func increase() {
        let newValue = min(maximumAmount, currentAmount + 1)
        setAmount(newValue)
        onChange?(currentAmount)
    }

    @objc private func decrease() {
        let newValue = max(minimumAmount, currentAmount - 1)
        setAmount(newValue)
        onChange?(currentAmount)
    }
}

// MARK: - PaymentOptionView (card row)
private final class PaymentOptionView: UIControl {

    var onTap: (() -> Void)?

    private(set) var iconType: PaymentMethodType = .visa

    private let container = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let labelsStack = UIStackView()

    private var borderColor: UIColor = .systemYellow
    private var optionBG: UIColor = .systemGray6

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.clear.cgColor
        container.backgroundColor = optionBG

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .black

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.numberOfLines = 1

        labelsStack.axis = .vertical
        labelsStack.spacing = 2
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        labelsStack.addArrangedSubview(titleLabel)
        labelsStack.addArrangedSubview(subtitleLabel)

        container.isUserInteractionEnabled = false
        iconView.isUserInteractionEnabled = false
        labelsStack.isUserInteractionEnabled = false
        titleLabel.isUserInteractionEnabled = false
        subtitleLabel.isUserInteractionEnabled = false

        addSubview(container)
        container.addSubview(iconView)
        container.addSubview(labelsStack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 26),
            iconView.heightAnchor.constraint(equalToConstant: 26),

            labelsStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            labelsStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            labelsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
        ])

        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    func configure(iconType: PaymentMethodType,
                   title: String,
                   subtitle: String?,
                   optionBG: UIColor,
                   borderColor: UIColor,
                   textGray: UIColor) {

        self.iconType = iconType
        self.borderColor = borderColor
        self.optionBG = optionBG

        container.backgroundColor = optionBG

        titleLabel.textColor = textGray
        titleLabel.text = title

        if let subtitle, !subtitle.isEmpty {
            subtitleLabel.isHidden = false
            subtitleLabel.text = subtitle
        } else {
            subtitleLabel.isHidden = true
        }

        switch iconType {
        case .visa:
            iconView.image = UIImage(systemName: "creditcard")?.withRenderingMode(.alwaysTemplate)
        case .applePay:
            iconView.image = UIImage(systemName: "apple.logo")?.withRenderingMode(.alwaysTemplate)
        }
        iconView.tintColor = .black
    }

    func setSelected(_ isSelected: Bool) {
        container.layer.borderColor = isSelected ? borderColor.cgColor : UIColor.clear.cgColor
        container.backgroundColor = optionBG
    }

    @objc private func tapped() {
        onTap?()
    }
}
