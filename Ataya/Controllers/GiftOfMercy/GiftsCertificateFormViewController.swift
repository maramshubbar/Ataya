//
//  GiftsCertificateFormViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 24/12/2025.
//


// GiftsCertificateFormViewController.swift

import UIKit

final class GiftsCertificateFormViewController: UIViewController, UITextViewDelegate {

    var selection: GiftSelection!
    private let card: CardDesign

    private var form = GiftCertificateForm()

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStack = UIStackView()

    // Summary card
    private let summaryCard = UIView()
    private let summaryThumb = UIImageView()
    private let summaryTextStack = UIStackView()
    private let giftNameValue = UILabel()
    private let cardNameValue = UILabel()

    // Fields
    private let fromLabel = UILabel()
    private let fromField = UITextField()
    private let fromError = UILabel()

    private let msgLabel = UILabel()
    private let msgBox = UIView()
    private let msgTextView = UITextView()
    private let msgPlaceholder = UILabel()
    private let msgError = UILabel()

    // Recipient container
    private let recipientContainer = UIView()
    private let recipientTitle = UILabel()

    private let recNameLabel = UILabel()
    private let recNameField = UITextField()
    private let recNameError = UILabel()

    private let recEmailLabel = UILabel()
    private let recEmailField = UITextField()
    private let recEmailError = UILabel()

    private let addRecipientButton = UIButton(type: .system)

    private let proceedButton = UIButton(type: .system)

    // Toast
    private let toast = UIView()
    private let toastLabel = UILabel()
    private var toastBottom: NSLayoutConstraint?

    init(selection: GiftSelection, card: CardDesign) {
        self.selection = selection
        self.card = card
        super.init(nibName: nil, bundle: nil)
        self.form.selectedCard = card
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        setupConstraints()
        addDismissKeyboardTap()
    }

    private func setupNav() {
        title = "Step 3: Details"
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Scroll setup
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Main stack
        mainStack.axis = .vertical
        mainStack.spacing = 18
        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        // Summary card
        summaryCard.backgroundColor = .white
        summaryCard.layer.cornerRadius = 14
        summaryCard.applyCardShadow()

        summaryThumb.image = UIImage(named: card.imageName)
        summaryThumb.contentMode = .scaleAspectFill
        summaryThumb.clipsToBounds = true
        summaryThumb.layer.cornerRadius = 10

        summaryTextStack.axis = .vertical
        summaryTextStack.spacing = 8

        let giftTitle = UILabel()
        giftTitle.text = "Name of Gift:"
        giftTitle.font = .systemFont(ofSize: 16, weight: .semibold)

        giftNameValue.text = "\(selection.gift.title) $\(selection.amount.plainString)"
        giftNameValue.font = .systemFont(ofSize: 18, weight: .bold)
        giftNameValue.textColor = .systemGreen
        giftNameValue.numberOfLines = 2

        let cardTitle = UILabel()
        cardTitle.text = "Card Design:"
        cardTitle.font = .systemFont(ofSize: 16, weight: .semibold)

        cardNameValue.text = card.title
        cardNameValue.font = .systemFont(ofSize: 18, weight: .bold)
        cardNameValue.textColor = .systemGreen
        cardNameValue.numberOfLines = 2

        summaryTextStack.addArrangedSubview(giftTitle)
        summaryTextStack.addArrangedSubview(giftNameValue)
        summaryTextStack.addArrangedSubview(cardTitle)
        summaryTextStack.addArrangedSubview(cardNameValue)

        summaryCard.addSubview(summaryThumb)
        summaryCard.addSubview(summaryTextStack)
        summaryThumb.translatesAutoresizingMaskIntoConstraints = false
        summaryTextStack.translatesAutoresizingMaskIntoConstraints = false

        // From
        fromLabel.text = "From"
        fromLabel.font = .systemFont(ofSize: 18, weight: .regular)

        styleField(fromField, placeholder: "Type your name")

        fromError.textColor = .systemRed
        fromError.font = .systemFont(ofSize: 14, weight: .medium)
        fromError.text = ""
        fromError.numberOfLines = 0

        // Message
        msgLabel.text = "Personal Message"
        msgLabel.font = .systemFont(ofSize: 18, weight: .regular)

        msgBox.backgroundColor = .systemGray6
        msgBox.layer.cornerRadius = 14
        msgBox.clipsToBounds = true

        msgTextView.backgroundColor = .clear
        msgTextView.font = .systemFont(ofSize: 18, weight: .regular)
        msgTextView.textContainerInset = UIEdgeInsets(top: 18, left: 14, bottom: 18, right: 14)
        msgTextView.delegate = self

        msgPlaceholder.text = "This message will be displayed on the gift card\n(max. 150 characters)"
        msgPlaceholder.textColor = .secondaryLabel
        msgPlaceholder.font = .systemFont(ofSize: 18, weight: .regular)
        msgPlaceholder.numberOfLines = 0

        msgError.textColor = .systemRed
        msgError.font = .systemFont(ofSize: 14, weight: .medium)
        msgError.text = ""
        msgError.numberOfLines = 0

        msgBox.addSubview(msgTextView)
        msgBox.addSubview(msgPlaceholder)
        msgTextView.translatesAutoresizingMaskIntoConstraints = false
        msgPlaceholder.translatesAutoresizingMaskIntoConstraints = false

        // Recipient container
        recipientContainer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        recipientContainer.layer.cornerRadius = 16
        recipientContainer.clipsToBounds = true

        recipientTitle.text = "Send this certificate to (email):"
        recipientTitle.font = .systemFont(ofSize: 26, weight: .heavy)
        recipientTitle.textAlignment = .center

        recNameLabel.text = "Name"
        recNameLabel.font = .systemFont(ofSize: 18, weight: .regular)

        styleField(recNameField, placeholder: "Name")

        recNameError.textColor = .systemRed
        recNameError.font = .systemFont(ofSize: 14, weight: .medium)
        recNameError.text = ""
        recNameError.numberOfLines = 0

        recEmailLabel.text = "Email"
        recEmailLabel.font = .systemFont(ofSize: 18, weight: .regular)

        styleField(recEmailField, placeholder: "Email")
        recEmailField.keyboardType = .emailAddress
        recEmailField.autocapitalizationType = .none

        recEmailError.textColor = .systemRed
        recEmailError.font = .systemFont(ofSize: 14, weight: .medium)
        recEmailError.text = ""
        recEmailError.numberOfLines = 0

        addRecipientButton.setTitle("  Add recipient", for: .normal)
        addRecipientButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        addRecipientButton.setTitleColor(.systemGreen, for: .normal)
        addRecipientButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addRecipientButton.tintColor = .systemGreen
        addRecipientButton.layer.borderWidth = 2
        addRecipientButton.layer.borderColor = UIColor.systemGreen.cgColor
        addRecipientButton.layer.cornerRadius = 14
        addRecipientButton.backgroundColor = .white
        addRecipientButton.addTarget(self, action: #selector(addRecipientTapped), for: .touchUpInside)

        // Proceed button (green)
        proceedButton.setTitle("Proceed", for: .normal)
        proceedButton.setTitleColor(.white, for: .normal)
        proceedButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        proceedButton.backgroundColor = .systemGreen
        proceedButton.layer.cornerRadius = 14
        proceedButton.clipsToBounds = true
        proceedButton.addTarget(self, action: #selector(proceedTapped), for: .touchUpInside)

        // Toast
        toast.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.20)
        toast.layer.cornerRadius = 14
        toast.alpha = 0

        toastLabel.text = "Fill all required fields first!"
        toastLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        toastLabel.textAlignment = .center
        toastLabel.textColor = .label

        view.addSubview(toast)
        toast.addSubview(toastLabel)
        toast.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add arranged views
        mainStack.addArrangedSubview(summaryCard)
        mainStack.addArrangedSubview(fromLabel)
        mainStack.addArrangedSubview(fromField)
        mainStack.addArrangedSubview(fromError)

        mainStack.addArrangedSubview(msgLabel)
        mainStack.addArrangedSubview(msgBox)
        mainStack.addArrangedSubview(msgError)

        mainStack.addArrangedSubview(recipientContainer)

        // Recipient inner layout
        let recStack = UIStackView()
        recStack.axis = .vertical
        recStack.spacing = 12

        recipientContainer.addSubview(recStack)
        recStack.translatesAutoresizingMaskIntoConstraints = false

        recStack.addArrangedSubview(recipientTitle)
        recStack.addArrangedSubview(recNameLabel)
        recStack.addArrangedSubview(recNameField)
        recStack.addArrangedSubview(recNameError)
        recStack.addArrangedSubview(recEmailLabel)
        recStack.addArrangedSubview(recEmailField)
        recStack.addArrangedSubview(recEmailError)
        recStack.addArrangedSubview(addRecipientButton)

        // Bottom proceed
        view.addSubview(proceedButton)
        proceedButton.translatesAutoresizingMaskIntoConstraints = false

        // Constraints inside summary card
        NSLayoutConstraint.activate([
            summaryThumb.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 12),
            summaryThumb.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 12),
            summaryThumb.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -12),
            summaryThumb.widthAnchor.constraint(equalToConstant: 110),

            summaryTextStack.leadingAnchor.constraint(equalTo: summaryThumb.trailingAnchor, constant: 12),
            summaryTextStack.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -12),
            summaryTextStack.centerYAnchor.constraint(equalTo: summaryCard.centerYAnchor),

            summaryCard.heightAnchor.constraint(equalToConstant: 120),

            msgTextView.topAnchor.constraint(equalTo: msgBox.topAnchor),
            msgTextView.leadingAnchor.constraint(equalTo: msgBox.leadingAnchor),
            msgTextView.trailingAnchor.constraint(equalTo: msgBox.trailingAnchor),
            msgTextView.bottomAnchor.constraint(equalTo: msgBox.bottomAnchor),

            msgPlaceholder.leadingAnchor.constraint(equalTo: msgBox.leadingAnchor, constant: 16),
            msgPlaceholder.trailingAnchor.constraint(equalTo: msgBox.trailingAnchor, constant: -16),
            msgPlaceholder.topAnchor.constraint(equalTo: msgBox.topAnchor, constant: 18),
        ])

        // Recipient container constraints
        NSLayoutConstraint.activate([
            recStack.topAnchor.constraint(equalTo: recipientContainer.topAnchor, constant: 16),
            recStack.leadingAnchor.constraint(equalTo: recipientContainer.leadingAnchor, constant: 16),
            recStack.trailingAnchor.constraint(equalTo: recipientContainer.trailingAnchor, constant: -16),
            recStack.bottomAnchor.constraint(equalTo: recipientContainer.bottomAnchor, constant: -16),

            addRecipientButton.heightAnchor.constraint(equalToConstant: 54)
        ])

        // Toast constraints
        toastBottom = toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 80)
        NSLayoutConstraint.activate([
            toast.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            toast.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            toast.heightAnchor.constraint(equalToConstant: 54),
            toastBottom!,

            toastLabel.leadingAnchor.constraint(equalTo: toast.leadingAnchor, constant: 12),
            toastLabel.trailingAnchor.constraint(equalTo: toast.trailingAnchor, constant: -12),
            toastLabel.centerYAnchor.constraint(equalTo: toast.centerYAnchor),
        ])
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            proceedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            proceedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            proceedButton.heightAnchor.constraint(equalToConstant: 54),
            proceedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: proceedButton.topAnchor, constant: -12),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),

            msgBox.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    private func styleField(_ tf: UITextField, placeholder: String) {
        tf.placeholder = placeholder
        tf.backgroundColor = .systemGray6
        tf.layer.cornerRadius = 14
        tf.clipsToBounds = true
        tf.font = .systemFont(ofSize: 20, weight: .regular)
        tf.setLeftPadding(14)
        tf.heightAnchor.constraint(equalToConstant: 62).isActive = true
    }

    private func setInvalid(_ view: UIView, _ errorLabel: UILabel, message: String) {
        view.layer.borderWidth = 1.4
        view.layer.borderColor = UIColor.systemRed.cgColor
        errorLabel.text = message
    }

    private func clearInvalid(_ view: UIView, _ errorLabel: UILabel) {
        view.layer.borderWidth = 0
        view.layer.borderColor = UIColor.clear.cgColor
        errorLabel.text = ""
    }

    // MARK: - TextView
    func textViewDidChange(_ textView: UITextView) {
        msgPlaceholder.isHidden = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Actions
    @objc private func addRecipientTapped() {
        // optional: just validate recipient fields
        _ = validateRecipientOnly(showToastIfFail: true)
    }

    @objc private func proceedTapped() {
        let ok = validateAll(showToastIfFail: true)
        if ok {
            // هنا تكملين flow (مثلاً summary / submit)
            showToast(text: "Done ✅")
        }
    }

    private func validateRecipientOnly(showToastIfFail: Bool) -> Bool {
        var ok = true

        clearInvalid(recNameField, recNameError)
        clearInvalid(recEmailField, recEmailError)

        let name = recNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = recEmailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if name.isEmpty {
            ok = false
            setInvalid(recNameField, recNameError, message: "Please enter a recipient name!")
        }
        if !isValidEmail(email) {
            ok = false
            setInvalid(recEmailField, recEmailError, message: "Please enter a valid email address!")
        }

        if !ok, showToastIfFail { showToast(text: "Fill all required fields first!") }
        return ok
    }

    private func validateAll(showToastIfFail: Bool) -> Bool {
        var ok = true

        clearInvalid(fromField, fromError)
        clearInvalid(msgBox, msgError)
        _ = validateRecipientOnly(showToastIfFail: false)

        let from = fromField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let msg = msgTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        if from.isEmpty {
            ok = false
            setInvalid(fromField, fromError, message: "Please enter your name!")
        }
        if msg.isEmpty {
            ok = false
            setInvalid(msgBox, msgError, message: "Please enter a message!")
        }

        if validateRecipientOnly(showToastIfFail: false) == false { ok = false }
        if form.selectedCard == nil { ok = false }

        if !ok, showToastIfFail { showToast(text: "Fill all required fields first!") }
        return ok
    }

    private func isValidEmail(_ s: String) -> Bool {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return false }
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    private func showToast(text: String) {
        toastLabel.text = text
        toastBottom?.constant = -12
        UIView.animate(withDuration: 0.25) {
            self.toast.alpha = 1
            self.view.layoutIfNeeded()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.hideToast()
        }
    }

    private func hideToast() {
        toastBottom?.constant = 80
        UIView.animate(withDuration: 0.25) {
            self.toast.alpha = 0
            self.view.layoutIfNeeded()
        }
    }

    private func addDismissKeyboardTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
