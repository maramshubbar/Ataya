import UIKit

final class AddPaymentMethodViewController: UIViewController {

    // MARK: - Colors
    private let atayaYellow = UIColor(red: 0xF7/255.0, green: 0xD4/255.0, blue: 0x4C/255.0, alpha: 1.0)

    // MARK: - Data
    private let methods = ["Visa Card", "Master Card", "Apple Pay"]
    private var selectedMethod: String = "Visa Card" {
        didSet { methodField.setValue(selectedMethod) }
    }

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let methodLabel = UILabel()
    private let methodField = DropdownField()

    private let cardNumberLabel = UILabel()
    private let cardNumberField = StyledTextField()

    private let expiryLabel = UILabel()
    private let expiryField = StyledTextField()
    private let monthYearPicker = MonthYearPickerView()

    private let nameLabel = UILabel()
    private let nameField = StyledTextField()

    private let cvvLabel = UILabel()
    private let cvvField = StyledTextField()

    private let confirmButton = UIButton(type: .system)
    private let expiryToolbar = UIToolbar()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .black

        buildUI()
        setupLayout()
        bind()
        applyDefaults()
    }

    // MARK: - Build UI
    private func buildUI() {
        // Navigation
        navigationItem.title = "Payment"
        navigationItem.largeTitleDisplayMode = .never

        // Scroll
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Labels style (15 black)
        func styleLabel(_ label: UILabel, _ text: String) {
            label.text = text
            label.font = .systemFont(ofSize: 15, weight: .regular)
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
        }

        styleLabel(methodLabel, "Payment Method")
        styleLabel(cardNumberLabel, "Card Number")
        styleLabel(expiryLabel, "Expiry Date")
        styleLabel(nameLabel, "Name On Card")
        styleLabel(cvvLabel, "CVV")

        // Fields style (60x362, radius 8)
        methodField.translatesAutoresizingMaskIntoConstraints = false
        methodField.chevronSize = 18
        methodField.setValue(selectedMethod)

        cardNumberField.translatesAutoresizingMaskIntoConstraints = false
        cardNumberField.placeholder = "0000 0000 0000 0000"
        cardNumberField.keyboardType = .numberPad

        expiryField.translatesAutoresizingMaskIntoConstraints = false
        expiryField.placeholder = "MM / YYYY"
        expiryField.keyboardType = .numberPad

        nameField.translatesAutoresizingMaskIntoConstraints = false
        nameField.placeholder = "Full name"
        nameField.autocapitalizationType = .words

        cvvField.translatesAutoresizingMaskIntoConstraints = false
        cvvField.placeholder = "123"
        cvvField.keyboardType = .numberPad
        cvvField.isSecureTextEntry = true

        // Confirm button (54x340, radius 8)
        confirmButton.setTitle("Confirm Payment", for: .normal)
        confirmButton.backgroundColor = atayaYellow
        confirmButton.setTitleColor(.black, for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        confirmButton.layer.cornerRadius = 8
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(confirmButton)

        // Add subviews to content
        [
            methodLabel, methodField,
            cardNumberLabel, cardNumberField,
            expiryLabel, expiryField,
            nameLabel, nameField,
            cvvLabel, cvvField
        ].forEach { contentView.addSubview($0) }

        // Expiry Month/Year picker
        let monthYearPicker = MonthYearPickerView()
        monthYearPicker.onPick = { [weak self] month, year in
            self?.expiryField.text = String(format: "%02d / %d", month, year)
        }
        expiryField.inputView = monthYearPicker
        expiryField.inputAccessoryView = expiryToolbar


        // Toolbar for picker
        expiryToolbar.sizeToFit()
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(expiryCancel))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(expiryDone))
        expiryToolbar.items = [cancel, flex, done]

        // Expiry picker attach
        monthYearPicker.onPick = { [weak self] month, year in
            self?.expiryField.text = String(format: "%02d / %d", month, year)
        }
        expiryField.inputView = monthYearPicker
        expiryField.inputAccessoryView = expiryToolbar
    }

    // MARK: - Layout
    private func setupLayout() {
        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // Confirm button pinned to bottom safe area
            confirmButton.widthAnchor.constraint(equalToConstant: 362),
            confirmButton.heightAnchor.constraint(equalToConstant: 54),
            confirmButton.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -16),

            // ScrollView fills above confirm button
            scrollView.topAnchor.constraint(equalTo: safe.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -12),

            // Content view inside scroll
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            // Match width to scroll frame
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])

        // Fields size: 60x362
        [methodField, cardNumberField, expiryField, nameField, cvvField].forEach { field in
            field.widthAnchor.constraint(equalToConstant: 362).isActive = true
            field.heightAnchor.constraint(equalToConstant: 60).isActive = true
            field.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        }

        // Vertical layout (spacing similar to screenshot)
        NSLayoutConstraint.activate([
            methodLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            methodLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            methodField.topAnchor.constraint(equalTo: methodLabel.bottomAnchor, constant: 10),

            cardNumberLabel.topAnchor.constraint(equalTo: methodField.bottomAnchor, constant: 20),
            cardNumberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            cardNumberField.topAnchor.constraint(equalTo: cardNumberLabel.bottomAnchor, constant: 10),

            expiryLabel.topAnchor.constraint(equalTo: cardNumberField.bottomAnchor, constant: 20),
            expiryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            expiryField.topAnchor.constraint(equalTo: expiryLabel.bottomAnchor, constant: 10),

            nameLabel.topAnchor.constraint(equalTo: expiryField.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            nameField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),

            cvvLabel.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 20),
            cvvLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            cvvField.topAnchor.constraint(equalTo: cvvLabel.bottomAnchor, constant: 10),
            cvvField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    // MARK: - Bind
    private func bind() {
        // Payment method dropdown (action sheet)
        methodField.onTap = { [weak self] in
            guard let self else { return }
            self.presentOptions(title: "Payment Method", options: self.methods, selected: self.selectedMethod) { picked in
                self.selectedMethod = picked
            }
        }

        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
    }

    private func applyDefaults() {
        methodField.setValue(selectedMethod)
    }

    // MARK: - Actions
    @objc private func confirmTapped() {
        // Present success popup screen
        let vc = DonationSuccessViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
    @objc private func expiryCancel() {
        expiryField.resignFirstResponder()
    }
    
    @objc private func expiryDone() {
        expiryField.resignFirstResponder()
    }
    @objc private func openExpiryPicker() {
        expiryField.becomeFirstResponder()
    }



    // MARK: - Helper (ActionSheet)
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
            pop.sourceView = methodField
            pop.sourceRect = methodField.bounds
        }

        present(ac, animated: true)
    }
}

// MARK: - StyledTextField (60 height, 362 width from constraints, radius 8)

private final class StyledTextField: UITextField {

    // Right accessory view slot (calendar icon)
    var rightAccessoryView: UIView? {
        didSet { setupRightAccessory() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor

        font = .systemFont(ofSize: 15, weight: .regular)
        textColor = .black

        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        leftViewMode = .always
        clearButtonMode = .whileEditing
    }

    private func setupRightAccessory() {
        guard let v = rightAccessoryView else {
            rightView = nil
            rightViewMode = .never
            return
        }

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            v.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            v.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        // Fixed padding area on the right
        let wrapper = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 60))
        wrapper.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            container.topAnchor.constraint(equalTo: wrapper.topAnchor),
            container.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
        ])

        rightView = wrapper
        rightViewMode = .always
    }
}

// MARK: - DropdownField (same style: 60 height, radius 8)

private final class DropdownField: UIControl {

    var onTap: (() -> Void)?

    // Chevron size control
    var chevronSize: CGFloat = 16 {
        didSet {
            chevronW?.constant = chevronSize
            chevronH?.constant = chevronSize
            layoutIfNeeded()
        }
    }

    private let container = UIView()
    private let valueLabel = UILabel()
    private let chevron = UIImageView()

    private var chevronW: NSLayoutConstraint?
    private var chevronH: NSLayoutConstraint?

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
        container.layer.borderColor = UIColor.systemGray4.cgColor

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 15, weight: .regular)
        valueLabel.textColor = .black

        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
        chevron.tintColor = .black
        chevron.contentMode = .scaleAspectFit

        // Important: do not block touches
        container.isUserInteractionEnabled = false
        valueLabel.isUserInteractionEnabled = false
        chevron.isUserInteractionEnabled = false

        addSubview(container)
        container.addSubview(valueLabel)
        container.addSubview(chevron)

        chevronW = chevron.widthAnchor.constraint(equalToConstant: chevronSize)
        chevronH = chevron.heightAnchor.constraint(equalToConstant: chevronSize)

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

            chevronW!, chevronH!
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
// MARK: - MonthYearPickerView
private final class MonthYearPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {

    var onPick: ((Int, Int) -> Void)?

    private let months = Array(1...12)
    private let years: [Int] = {
        let current = Calendar.current.component(.year, from: Date())
        return Array(current...(current + 15))
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        dataSource = self

        // Default selection: current month/year
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear  = Calendar.current.component(.year, from: Date())

        if let mIndex = months.firstIndex(of: currentMonth) {
            selectRow(mIndex, inComponent: 0, animated: false)
        }
        if let yIndex = years.firstIndex(of: currentYear) {
            selectRow(yIndex, inComponent: 1, animated: false)
        }

        onPick?(currentMonth, currentYear)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
        dataSource = self
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        component == 0 ? months.count : years.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(format: "%02d", months[row])
        } else {
            return "\(years[row])"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let month = months[selectedRow(inComponent: 0)]
        let year = years[selectedRow(inComponent: 1)]
        onPick?(month, year)
    }
}

