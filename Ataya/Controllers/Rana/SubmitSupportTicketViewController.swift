//
//  SubmitSupportTicketViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 29/12/2025.
//

import UIKit

final class SubmitSupportTicketViewController: UIViewController,
                                              UIPickerViewDataSource, UIPickerViewDelegate,
                                              UITextViewDelegate {

    // MARK: - Constants
    private let sidePadding: CGFloat = 36
    private let buttonWidth: CGFloat = 368
    private let buttonHeight: CGFloat = 54
    private let yellow = UIColor(hex: "#F7D44C")

    private let categories = ["Donations", "Accounts", "Other"]
    private var selectedCategory: String?

    // MARK: - Header
    private let headerContainer = UIView()
    private let backButton = UIButton(type: .system)
    private let headerTitleLabel = UILabel()

    // MARK: - Form
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let issueCategoryLabel = UILabel()
    private let categoryContainer = UIView()
    private let categoryTextField = UITextField()
    private let chevronIcon = UIImageView()

    private let describeLabel = UILabel()
    private let issueTextContainer = UIView()
    private let issueTextView = UITextView()
    private let placeholderLabel = UILabel()

    // NOTE (must be above button - NOT inside scroll)
    private let noteLabel = UILabel()

    // MARK: - Picker
    private let pickerView = UIPickerView()
    private let pickerToolbar = UIToolbar()

    // MARK: - Button
    private let submitButton = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupHeader()
        setupScroll()
        setupForm()
        setupPicker()
        setupSubmitButton()
        setupNoteAboveButton()
        setupKeyboardDismiss()

        // default selection
        selectedCategory = categories.first
        categoryTextField.text = selectedCategory
    }

    // MARK: - Header (NO NAV TITLE)
    private func setupHeader() {
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerContainer)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.text = "Submit Support Ticket"
        headerTitleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        headerTitleLabel.textAlignment = .center
        headerTitleLabel.textColor = .black

        headerContainer.addSubview(backButton)
        headerContainer.addSubview(headerTitleLabel)

        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 44),

            backButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            headerTitleLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            headerTitleLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor)
        ])
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Scroll
    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // space so content doesn't hide behind note + button
        scrollView.contentInset.bottom = buttonHeight + 70
        scrollView.verticalScrollIndicatorInsets.bottom = buttonHeight + 70
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }


    // MARK: - Form UI (NO note here)
    private func setupForm() {
        // Issue Category title
        issueCategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        issueCategoryLabel.text = "Issue Category"
        issueCategoryLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        issueCategoryLabel.textColor = .black

        // Category container
        categoryContainer.translatesAutoresizingMaskIntoConstraints = false
        categoryContainer.backgroundColor = .white
        categoryContainer.layer.cornerRadius = 10
        categoryContainer.layer.borderWidth = 1
        categoryContainer.layer.borderColor = UIColor(white: 0.85, alpha: 1).cgColor

        categoryTextField.translatesAutoresizingMaskIntoConstraints = false
        categoryTextField.borderStyle = .none
        categoryTextField.textColor = .black
        categoryTextField.font = .systemFont(ofSize: 14, weight: .regular)
        categoryTextField.tintColor = .clear
        categoryTextField.inputView = pickerView
        categoryTextField.inputAccessoryView = pickerToolbar

        chevronIcon.translatesAutoresizingMaskIntoConstraints = false
        chevronIcon.image = UIImage(systemName: "chevron.down")
        chevronIcon.tintColor = UIColor(white: 0.35, alpha: 1)

        // Describe title
        describeLabel.translatesAutoresizingMaskIntoConstraints = false
        describeLabel.text = "Describe Your Issue"
        describeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        describeLabel.textColor = .black

        // Text area container
        issueTextContainer.translatesAutoresizingMaskIntoConstraints = false
        issueTextContainer.backgroundColor = .white
        issueTextContainer.layer.cornerRadius = 10
        issueTextContainer.layer.borderWidth = 1
        issueTextContainer.layer.borderColor = UIColor(white: 0.85, alpha: 1).cgColor

        issueTextView.translatesAutoresizingMaskIntoConstraints = false
        issueTextView.font = .systemFont(ofSize: 14, weight: .regular)
        issueTextView.textColor = .black
        issueTextView.backgroundColor = .clear
        issueTextView.delegate = self
        issueTextView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.text = "Write your issue here..."
        placeholderLabel.font = .systemFont(ofSize: 14, weight: .regular)
        placeholderLabel.textColor = UIColor(white: 0.65, alpha: 1)

        contentView.addSubview(issueCategoryLabel)
        contentView.addSubview(categoryContainer)
        categoryContainer.addSubview(categoryTextField)
        categoryContainer.addSubview(chevronIcon)

        contentView.addSubview(describeLabel)
        contentView.addSubview(issueTextContainer)
        issueTextContainer.addSubview(issueTextView)
        issueTextContainer.addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            issueCategoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            issueCategoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sidePadding),
            issueCategoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sidePadding),

            categoryContainer.topAnchor.constraint(equalTo: issueCategoryLabel.bottomAnchor, constant: 10),
            categoryContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sidePadding),
            categoryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sidePadding),
            categoryContainer.heightAnchor.constraint(equalToConstant: 44),

            categoryTextField.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor, constant: 14),
            categoryTextField.trailingAnchor.constraint(equalTo: chevronIcon.leadingAnchor, constant: -10),
            categoryTextField.centerYAnchor.constraint(equalTo: categoryContainer.centerYAnchor),

            chevronIcon.trailingAnchor.constraint(equalTo: categoryContainer.trailingAnchor, constant: -14),
            chevronIcon.centerYAnchor.constraint(equalTo: categoryContainer.centerYAnchor),
            chevronIcon.widthAnchor.constraint(equalToConstant: 16),
            chevronIcon.heightAnchor.constraint(equalToConstant: 16),

            describeLabel.topAnchor.constraint(equalTo: categoryContainer.bottomAnchor, constant: 18),
            describeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sidePadding),
            describeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sidePadding),

            issueTextContainer.topAnchor.constraint(equalTo: describeLabel.bottomAnchor, constant: 10),
            issueTextContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sidePadding),
            issueTextContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sidePadding),
            issueTextContainer.heightAnchor.constraint(equalToConstant: 360),

            issueTextView.topAnchor.constraint(equalTo: issueTextContainer.topAnchor),
            issueTextView.leadingAnchor.constraint(equalTo: issueTextContainer.leadingAnchor),
            issueTextView.trailingAnchor.constraint(equalTo: issueTextContainer.trailingAnchor),
            issueTextView.bottomAnchor.constraint(equalTo: issueTextContainer.bottomAnchor),

            placeholderLabel.topAnchor.constraint(equalTo: issueTextContainer.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: issueTextContainer.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: issueTextContainer.trailingAnchor, constant: -16),

            // content ends here (note is NOT inside scroll)
            issueTextContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18)
        ])

        // Tap to open picker
        let tap = UITapGestureRecognizer(target: self, action: #selector(openCategoryPicker))
        categoryContainer.addGestureRecognizer(tap)
        categoryContainer.isUserInteractionEnabled = true
    }

    // MARK: - Picker setup
    private func setupPicker() {
        pickerView.dataSource = self
        pickerView.delegate = self

        pickerToolbar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(pickerDone))
        pickerToolbar.items = [flex, done]
    }

    @objc private func openCategoryPicker() {
        categoryTextField.becomeFirstResponder()
    }

    @objc private func pickerDone() {
        categoryTextField.resignFirstResponder()
    }

    // MARK: - Button (fixed bottom)
    private func setupSubmitButton() {
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("Submit Support Ticket", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        submitButton.backgroundColor = yellow
        submitButton.layer.cornerRadius = 12
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        view.addSubview(submitButton)

        NSLayoutConstraint.activate([
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            submitButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
    }

    // MARK: - NOTE ABOVE BUTTON (the fix)
    private func setupNoteAboveButton() {
        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        noteLabel.text = "Note: You will receive a notification when the admin replies."
        noteLabel.font = .systemFont(ofSize: 12, weight: .regular)
        noteLabel.textColor = UIColor(white: 0.55, alpha: 1)
        noteLabel.numberOfLines = 0
        noteLabel.textAlignment = .center

        view.addSubview(noteLabel)

        NSLayoutConstraint.activate([
            noteLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            noteLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            noteLabel.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -12)
        ])
    }

    // MARK: - Actions
    @objc private func submitTapped() {
        let text = issueTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let category = selectedCategory, !category.isEmpty else {
            showInfoAlert(title: "Missing Category", message: "Please choose an issue category.")
            return
        }
        guard !text.isEmpty else {
            showInfoAlert(title: "Missing Issue", message: "Please describe your issue before submitting.")
            return
        }

        let alert = UIAlertController(title: "Confirm Submission",
                                      message: "Do you want to submit this support ticket?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self?.sendTicketToAdmin(category: category, message: text)
        }))

        present(alert, animated: true)
    }

    private func sendTicketToAdmin(category: String, message: String) {
        let success = UIAlertController(title: "Successfully Submitted",
                                        message: "Your support ticket has been submitted to the admin.",
                                        preferredStyle: .alert)
        success.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        present(success, animated: true)
    }

    private func showInfoAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    // MARK: - UITextView placeholder
    func textViewDidChange(_ textView: UITextView) {
        let t = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        placeholderLabel.isHidden = !t.isEmpty
    }

    // MARK: - UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        categories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        categories[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
        categoryTextField.text = selectedCategory
    }

    // MARK: - Keyboard dismiss
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingAll))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func endEditingAll() {
        view.endEditing(true)
    }
}

// MARK: - UIColor Hex

private extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") { hexString.removeFirst() }

        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
