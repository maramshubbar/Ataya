import UIKit

final class RecurringDonationDetailsViewController: UIViewController {

    // MARK: - Storyboard Outlets (connect these)
    @IBOutlet weak var foodCategoryButton: UIButton!
    @IBOutlet weak var foodItemButton: UIButton!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var unitsButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var nextButton: UIButton!

    // MARK: - Colors
    private let yellow = UIColor(red: 0xF7/255.0, green: 0xD4/255.0, blue: 0x4C/255.0, alpha: 1.0)

    // MARK: - Data
    private let categoryOptions = ["Dairy", "Bread & Bakery", "Fruits & Vegetables", "Meals", "Canned Food"]
    private let itemOptions = ["Milk", "Cheese", "Yogurt", "Bread", "Dates"]
    private let unitsOptions = ["Packets", "Kg", "Pieces", "Boxes"]

    // MARK: - TextView Placeholder
    private let descriptionPlaceholderLabel = UILabel()

    // MARK: - Placeholders
    private let categoryPlaceholder = "Tap to select"
    private let itemPlaceholder = "Tap to select"
    private let unitsPlaceholder = "Units"

    // MARK: - Stored values (saved when Next tapped)
    private(set) var selectedCategory: String?
    private(set) var selectedItem: String?
    private(set) var selectedUnit: String?
    private(set) var selectedQuantity: Int?
    private(set) var donationNotes: String?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Recurring Donation"
        navigationItem.backButtonTitle = ""
        navigationItem.largeTitleDisplayMode = .never

        // UI
        setupDropdownButton(foodCategoryButton, placeholder: categoryPlaceholder)
        setupDropdownButton(foodItemButton, placeholder: itemPlaceholder)
        setupDropdownButton(unitsButton, placeholder: unitsPlaceholder)

        setupQuantityField(quantityTextField, placeholder: "Enter quantity")
        setupDescriptionTextView(descriptionTextView, placeholder: "Add notes")

        styleNextButton()

        attachMenu(to: foodCategoryButton, options: categoryOptions, placeholder: categoryPlaceholder)
        attachMenu(to: foodItemButton, options: itemOptions, placeholder: itemPlaceholder)
        attachMenu(to: unitsButton, options: unitsOptions, placeholder: unitsPlaceholder)

        quantityTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        quantityTextField.delegate = self

        NotificationCenter.default.addObserver(self,
                                              selector: #selector(textViewChanged),
                                              name: UITextView.textDidChangeNotification,
                                              object: descriptionTextView)

        // Sizes (do AFTER outlets exist)
        applySizingConstraints()

        updateNextState()
    }

    // MARK: - Styling

    private func setupDropdownButton(_ button: UIButton, placeholder: String) {
        var config = UIButton.Configuration.plain()
        config.title = placeholder
        config.baseForegroundColor = .systemGray
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14)
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 10

        button.configuration = config
        button.showsMenuAsPrimaryAction = true
        button.contentHorizontalAlignment = .fill

        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.backgroundColor = .clear
        button.tintColor = .systemGray
    }

    private func setupQuantityField(_ tf: UITextField, placeholder: String) {
        tf.placeholder = placeholder
        tf.keyboardType = .numberPad
        tf.font = .systemFont(ofSize: 16)

        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray4.cgColor
        tf.backgroundColor = .clear

        let pad = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf.leftView = pad
        tf.leftViewMode = .always
    }

    private func setupDescriptionTextView(_ tv: UITextView, placeholder: String) {
        tv.text = ""
        tv.font = .systemFont(ofSize: 16)
        tv.textColor = .label
        tv.backgroundColor = .clear

        tv.layer.cornerRadius = 10
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)

        descriptionPlaceholderLabel.text = placeholder
        descriptionPlaceholderLabel.textColor = .systemGray3
        descriptionPlaceholderLabel.font = .systemFont(ofSize: 16)
        descriptionPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false

        tv.addSubview(descriptionPlaceholderLabel)
        NSLayoutConstraint.activate([
            descriptionPlaceholderLabel.leadingAnchor.constraint(equalTo: tv.leadingAnchor, constant: 14),
            descriptionPlaceholderLabel.topAnchor.constraint(equalTo: tv.topAnchor, constant: 12)
        ])

        descriptionPlaceholderLabel.isHidden = !tv.text.isEmpty
    }

    private var sizingConstraints: [NSLayoutConstraint] = []

    private func applySizingConstraints() {
        NSLayoutConstraint.deactivate(sizingConstraints)
        sizingConstraints.removeAll()

        sizingConstraints.append(foodCategoryButton.heightAnchor.constraint(equalToConstant: 60))
        sizingConstraints.append(foodItemButton.heightAnchor.constraint(equalToConstant: 60))
        sizingConstraints.append(unitsButton.heightAnchor.constraint(equalToConstant: 60))
        sizingConstraints.append(quantityTextField.heightAnchor.constraint(equalToConstant: 60))
        sizingConstraints.append(descriptionTextView.heightAnchor.constraint(equalToConstant: 140))
        sizingConstraints.append(nextButton.heightAnchor.constraint(equalToConstant: 54))

        // ❗️REMOVE this: unitsButton.widthAnchor = 60 (too small)
        // If you really need a fixed width, use something like 140-200.
        // sizingConstraints.append(unitsButton.widthAnchor.constraint(equalToConstant: 160))

        NSLayoutConstraint.activate(sizingConstraints)
    }

    private func styleNextButton() {
        nextButton.configuration = nil
        nextButton.setTitle("Next", for: .normal)

        nextButton.layer.cornerRadius = 10
        nextButton.layer.masksToBounds = true
        nextButton.backgroundColor = yellow

        nextButton.setTitleColor(.black, for: .normal)
        nextButton.setTitleColor(.black, for: .disabled)
        nextButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
    }

    // MARK: - Menus

    private func attachMenu(to button: UIButton, options: [String], placeholder: String) {
        let actions = options.map { option in
            UIAction(title: option) { [weak self] _ in
                guard let self else { return }
                var c = button.configuration ?? UIButton.Configuration.plain()
                c.title = option
                c.baseForegroundColor = .label
                button.configuration = c
                self.updateNextState()
            }
        }
        button.menu = UIMenu(children: actions)

        // keep placeholder gray
        if button.configuration?.title == placeholder {
            var c = button.configuration!
            c.baseForegroundColor = .systemGray
            button.configuration = c
        }
    }

    // MARK: - Alert

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Validation helpers

    private func currentTitle(of button: UIButton) -> String {
        button.configuration?.title ?? ""
    }

    private func isPlaceholderSelected() -> Bool {
        let cat = currentTitle(of: foodCategoryButton)
        let item = currentTitle(of: foodItemButton)
        let unit = currentTitle(of: unitsButton)

        return (cat == categoryPlaceholder) || (item == itemPlaceholder) || (unit == unitsPlaceholder)
    }

    private func updateNextState() {
        let cat = foodCategoryButton.configuration?.title ?? ""
        let item = foodItemButton.configuration?.title ?? ""
        let unit = unitsButton.configuration?.title ?? ""
        let qty = (quantityTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        let ok =
            cat != "Tap to select" &&
            item != "Tap to select" &&
            unit != "Units" &&
            !qty.isEmpty

        // ✅ keep it clickable always
        nextButton.isEnabled = true

        // just visual feedback
        nextButton.alpha = ok ? 1.0 : 0.6
    }
    
    @objc private func textChanged() {
        updateNextState()
    }

    @objc private func textViewChanged() {
        descriptionPlaceholderLabel.isHidden = !descriptionTextView.text.isEmpty
        updateNextState()
    }

    // MARK: - Actions

    @IBAction func nextTapped(_ sender: UIButton) {
        print("✅ nextTapped fired")
        view.endEditing(true)

        // ✅ Validate again (even if button disabled, still safe)
        if isPlaceholderSelected() {
            showAlert(title: "Missing info", message: "Please select Category, Item, and Units.")
            return
        }

        let qtyText = (quantityTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let qty = Int(qtyText), qty > 0 else {
            showAlert(title: "Invalid quantity", message: "Please enter a valid quantity (numbers only).")
            return
        }

        // ✅ Save values
        selectedCategory = currentTitle(of: foodCategoryButton)
        selectedItem = currentTitle(of: foodItemButton)
        selectedUnit = currentTitle(of: unitsButton)
        selectedQuantity = qty

        let notes = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        donationNotes = notes.isEmpty ? nil : notes

        // Optional: store to UserDefaults (if you want)
        // UserDefaults.standard.set(selectedCategory, forKey: "don_category")
        // UserDefaults.standard.set(selectedItem, forKey: "don_item")
        // UserDefaults.standard.set(selectedUnit, forKey: "don_unit")
        // UserDefaults.standard.set(selectedQuantity, forKey: "don_qty")
        // UserDefaults.standard.set(donationNotes, forKey: "don_notes")

        // ✅ Go next (change identifier to yours)
        performSegue(withIdentifier: "goToSummary", sender: self)
    }

    // MARK: - Pass data forward (optional)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "goToSummary" else { return }

        // Example:
        // let vc = segue.destination as! RecurringSummaryViewController
        // vc.category = selectedCategory
        // vc.item = selectedItem
        // vc.unit = selectedUnit
        // vc.quantity = selectedQuantity
        // vc.notes = donationNotes
    }
}

// MARK: - UITextFieldDelegate (optional: block non-numbers)
extension RecurringDonationDetailsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow backspace
        if string.isEmpty { return true }
        // Only digits
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
    }
}
