//
//  GiftCertificateDetailsViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//

import UIKit

final class GiftCertificateDetailsViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    // MARK: - Inputs (set these from previous screen)
    var giftNameText: String?
    var cardDesignText: String?
    var topPreviewImage: UIImage?
    var bottomPreviewImage: UIImage?

    // MARK: - Theme
    private let accentGreen = UIColor(atayaHex: "00A85C")              // للكتابة (مثل المثال)
    private let softGreen   = UIColor(atayaHex: "00A85C", alpha: 0.10) // خلفية الكرت الأخضر الخفيف
    private let brandYellow = UIColor(atayaHex: "F7D44C")              // للأزرار (Proceed / Add recipient)

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()

    // Summary card
    private let summaryCard = UIView()
    private let previewStack = UIStackView()
    private let previewTop = UIImageView()
    private let previewBottom = UIImageView()
    private let summaryTextStack = UIStackView()

    private let giftTitleLabel = UILabel()
    private let giftValueLabel = UILabel()

    private let cardTitleLabel = UILabel()
    private let cardValueLabel = UILabel()

    // From
    private let fromTitle = UILabel()
    private let fromField = UITextField()
    private let fromError = UILabel()

    // Message
    private let messageTitle = UILabel()
    private let messageBox = UITextView()
    private let messagePlaceholder = UILabel()
    private let messageError = UILabel()
    private let messageLimitHint = UILabel()

    // Recipient section
    private let recipientCard = UIView()
    private let recipientStack = UIStackView()

    private let recipientHeader = UILabel()

    private let rNameTitle = UILabel()
    private let rNameField = UITextField()
    private let rNameError = UILabel()

    private let rEmailTitle = UILabel()
    private let rEmailField = UITextField()
    private let rEmailError = UILabel()

    private let addRecipientButton = UIButton(type: .system)

    // Bottom
    private let bottomBar = UIView()
    private let proceedButton = UIButton(type: .system)
    private let toastView = UIView()
    private let toastLabel = UILabel()
    private var toastBottom: NSLayoutConstraint?

    // State
    private var recipientEnabled = false
    private let maxMessageChars = 150

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        setupConstraints()
        setupActions()
        applyInitialState()
        addDismissKeyboardTap()
    }

    // ✅ يثبت لون الـ Back أسود وما يتغير من صفحات ثانية
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .label // أسود (لايت) / أبيض (دارك)
        // إذا تبينه أسود دايم حتى بالدارك:
        // navigationController?.navigationBar.tintColor = .black
    }

    private func setupNav() {
        title = "Step 2: Choose a card"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        // ❌ لا تحطين tintColor هنا عشان ما يرجع أخضر/غيره
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Scroll
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stack)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive

        stack.axis = .vertical
        stack.spacing = 18

        // Summary Card (top)
        summaryCard.backgroundColor = .white
        summaryCard.layer.cornerRadius = 14
        summaryCard.layer.borderWidth = 1
        summaryCard.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
        summaryCard.clipsToBounds = true

        previewStack.axis = .vertical
        previewStack.spacing = 8
        previewStack.alignment = .fill
        previewStack.distribution = .fillEqually

        [previewTop, previewBottom].forEach {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 10
            $0.backgroundColor = UIColor.systemGray6
        }

        // ✅ نبي صورة وحده مثل المثال (حسب اختيار اليوزر)
        previewTop.isHidden = true
        previewBottom.image = bottomPreviewImage ?? topPreviewImage

        summaryTextStack.axis = .vertical
        summaryTextStack.spacing = 10

        giftTitleLabel.text = "Name of Gift:"
        giftTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        giftTitleLabel.textColor = .label

        giftValueLabel.font = .systemFont(ofSize: 18, weight: .bold)
        giftValueLabel.textColor = brandYellow
        giftValueLabel.numberOfLines = 0

        cardTitleLabel.text = "Card Design:"
        cardTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        cardTitleLabel.textColor = .label

        cardValueLabel.font = .systemFont(ofSize: 18, weight: .bold)
        cardValueLabel.textColor = brandYellow
        cardValueLabel.numberOfLines = 0

        // Fill values
        giftValueLabel.text = giftNameText ?? ""
        cardValueLabel.text = cardDesignText ?? ""

        // Layout inside summary
        let summaryHStack = UIStackView()
        summaryHStack.axis = .horizontal
        summaryHStack.spacing = 14
        summaryHStack.alignment = .top

        summaryTextStack.addArrangedSubview(makePairRow(left: giftTitleLabel, right: giftValueLabel))
        summaryTextStack.addArrangedSubview(makePairRow(left: cardTitleLabel, right: cardValueLabel))

        summaryHStack.addArrangedSubview(previewStack)
        summaryHStack.addArrangedSubview(summaryTextStack)

        summaryCard.addSubview(summaryHStack)
        summaryHStack.translatesAutoresizingMaskIntoConstraints = false
        previewStack.translatesAutoresizingMaskIntoConstraints = false
        summaryTextStack.translatesAutoresizingMaskIntoConstraints = false

        // ✅ نخلي بس صورة وحده في الستاكد
        previewStack.addArrangedSubview(previewBottom)

        // From
        fromTitle.text = "From"
        fromTitle.font = .systemFont(ofSize: 18, weight: .regular)
        fromTitle.textColor = .label

        styleTextField(fromField, placeholder: "Type your name")
        fromErrorLabelStyle(fromError)

        // Message
        messageTitle.text = "Personal Message"
        messageTitle.font = .systemFont(ofSize: 18, weight: .regular)
        messageTitle.textColor = .label

        messageBox.delegate = self
        messageBox.font = .systemFont(ofSize: 17, weight: .regular)
        messageBox.backgroundColor = UIColor.systemGray6
        messageBox.layer.cornerRadius = 14
        messageBox.clipsToBounds = true
        messageBox.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        messageBox.isScrollEnabled = false
        messageBox.keyboardType = .default
        messageBox.returnKeyType = .done

        messagePlaceholder.text = "This message will be displayed on the gift card\n(max. 150 characters)"
        messagePlaceholder.textColor = .secondaryLabel
        messagePlaceholder.font = .systemFont(ofSize: 16, weight: .regular)
        messagePlaceholder.numberOfLines = 0

        messageErrorLabelStyle(messageError)

        messageLimitHint.text = ""
        messageLimitHint.font = .systemFont(ofSize: 12, weight: .regular)
        messageLimitHint.textColor = .secondaryLabel

        // Recipient card
        recipientCard.backgroundColor = UIColor(atayaHex: "FFF8E8")
        recipientCard.layer.cornerRadius = 16
        recipientCard.clipsToBounds = true

        recipientStack.axis = .vertical
        recipientStack.spacing = 14

        recipientHeader.text = "Send this certificate to (email):"
        recipientHeader.font = .systemFont(ofSize: 24, weight: .heavy)
        recipientHeader.textAlignment = .center
        recipientHeader.textColor = .label

        rNameTitle.text = "Name"
        rNameTitle.font = .systemFont(ofSize: 16, weight: .regular)

        styleTextField(rNameField, placeholder: "Name")
        fromErrorLabelStyle(rNameError)

        rEmailTitle.text = "Email"
        rEmailTitle.font = .systemFont(ofSize: 16, weight: .regular)

        styleTextField(rEmailField, placeholder: "Email")
        rEmailField.keyboardType = .emailAddress
        rEmailField.autocapitalizationType = .none
        rEmailField.autocorrectionType = .no
        fromErrorLabelStyle(rEmailError)

        // ✅ Add recipient = أصفر
        var cfg = UIButton.Configuration.plain()
        cfg.title = "Add recipient"
        cfg.image = UIImage(systemName: "plus")
        cfg.imagePlacement = .trailing
        cfg.imagePadding = 12
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
        cfg.baseForegroundColor = brandYellow

        addRecipientButton.configuration = cfg
        addRecipientButton.layer.cornerRadius = 14
        addRecipientButton.layer.borderWidth = 2
        addRecipientButton.layer.borderColor = brandYellow.cgColor
        addRecipientButton.backgroundColor = .clear

        // Bottom bar
        bottomBar.backgroundColor = .systemBackground

        // ✅ Proceed = أصفر + كتابة سوداء (أوضح على الأصفر)
        var pCfg = UIButton.Configuration.filled()
        pCfg.title = "Proceed"
        pCfg.baseBackgroundColor = brandYellow
        pCfg.baseForegroundColor = .black
        pCfg.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)

        proceedButton.configuration = pCfg
        proceedButton.layer.cornerRadius = 16
        proceedButton.clipsToBounds = true

        // Toast

        toastView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
        toastView.layer.cornerRadius = 12
        toastView.clipsToBounds = true
        toastView.alpha = 0
        toastLabel.text = "Fill all required fields first!"
        toastLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        toastLabel.textAlignment = .center
        toastLabel.textColor = .systemRed

        toastView.addSubview(toastLabel)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastLabel.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 10),
            toastLabel.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -10),
            toastLabel.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 14),
            toastLabel.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -14),
        ])

        // Put everything in stack
        stack.addArrangedSubview(summaryCard)

        stack.addArrangedSubview(fromTitle)
        stack.addArrangedSubview(fromField)
        stack.addArrangedSubview(fromError)

        stack.addArrangedSubview(messageTitle)

        let msgContainer = UIView()
        msgContainer.addSubview(messageBox)
        msgContainer.addSubview(messagePlaceholder)
        msgContainer.translatesAutoresizingMaskIntoConstraints = false
        messageBox.translatesAutoresizingMaskIntoConstraints = false
        messagePlaceholder.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            messageBox.topAnchor.constraint(equalTo: msgContainer.topAnchor),
            messageBox.leadingAnchor.constraint(equalTo: msgContainer.leadingAnchor),
            messageBox.trailingAnchor.constraint(equalTo: msgContainer.trailingAnchor),
            messageBox.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),
            messageBox.bottomAnchor.constraint(equalTo: msgContainer.bottomAnchor),

            messagePlaceholder.topAnchor.constraint(equalTo: messageBox.topAnchor, constant: 16),
            messagePlaceholder.leadingAnchor.constraint(equalTo: messageBox.leadingAnchor, constant: 16),
            messagePlaceholder.trailingAnchor.constraint(equalTo: messageBox.trailingAnchor, constant: -16),
        ])

        stack.addArrangedSubview(msgContainer)
        stack.addArrangedSubview(messageError)

        // Recipient content
        recipientCard.addSubview(recipientStack)
        recipientStack.translatesAutoresizingMaskIntoConstraints = false

        recipientStack.addArrangedSubview(spacer(8))
        recipientStack.addArrangedSubview(recipientHeader)
        recipientStack.addArrangedSubview(spacer(6))

        recipientStack.addArrangedSubview(rNameTitle)
        recipientStack.addArrangedSubview(rNameField)
        recipientStack.addArrangedSubview(rNameError)

        recipientStack.addArrangedSubview(rEmailTitle)
        recipientStack.addArrangedSubview(rEmailField)
        recipientStack.addArrangedSubview(rEmailError)

        recipientStack.addArrangedSubview(spacer(6))
        recipientStack.addArrangedSubview(addRecipientButton)
        recipientStack.addArrangedSubview(spacer(10))

        stack.addArrangedSubview(recipientCard)

        // Bottom bar + toast
        stack.addArrangedSubview(proceedButton)
        proceedButton.heightAnchor.constraint(equalToConstant: 56).isActive = true

        view.addSubview(toastView)

        proceedButton.translatesAutoresizingMaskIntoConstraints = false
        toastView.translatesAutoresizingMaskIntoConstraints = false

        // Summary internal constraints
        NSLayoutConstraint.activate([
            summaryHStack.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 14),
            summaryHStack.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -14),
            summaryHStack.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 14),
            summaryHStack.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -14),

            previewStack.widthAnchor.constraint(equalToConstant: 78),
            previewStack.heightAnchor.constraint(equalToConstant: 78),

            recipientStack.topAnchor.constraint(equalTo: recipientCard.topAnchor, constant: 18),
            recipientStack.bottomAnchor.constraint(equalTo: recipientCard.bottomAnchor, constant: -18),
            recipientStack.leadingAnchor.constraint(equalTo: recipientCard.leadingAnchor, constant: 18),
            recipientStack.trailingAnchor.constraint(equalTo: recipientCard.trailingAnchor, constant: -18),
        ])
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll fills the screen
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // ContentView ties to scroll content layout
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            // Content width = scroll frame width
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            // Stack inside contentView
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),
        ])

        // ✅ Toast position (bottom)
        toastBottom = toastView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        toastBottom?.isActive = true

        NSLayoutConstraint.activate([
            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -40),
        ])

        // ✅ الحين proceed داخل الـ stack، فـ لا تحتاجين inset كبير
        scrollView.contentInset.bottom = 18
        scrollView.verticalScrollIndicatorInsets.bottom = 18
    }


    private func setupActions() {
        proceedButton.addTarget(self, action: #selector(proceedTapped), for: .touchUpInside)
        addRecipientButton.addTarget(self, action: #selector(addRecipientTapped), for: .touchUpInside)

        fromField.delegate = self
        rNameField.delegate = self
        rEmailField.delegate = self
    }

    private func applyInitialState() {
        setRecipientEnabled(false)

        // hide all error labels initially
        setError(for: fromField, label: fromError, message: nil)
        setTextViewError(message: nil)
        setError(for: rNameField, label: rNameError, message: nil)
        setError(for: rEmailField, label: rEmailError, message: nil)

        let gift = (giftNameText ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        giftTitleLabel.isHidden = false
        giftValueLabel.isHidden = false
        giftValueLabel.text = gift.isEmpty ? "—" : gift

    }

    // MARK: - Validation
    @objc private func addRecipientTapped() {
        setRecipientEnabled(true)
        rNameField.becomeFirstResponder()
    }

    @objc private func proceedTapped() {
        view.endEditing(true)

        var ok = true

        if fromField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            setError(for: fromField, label: fromError, message: "Please enter your name")
            ok = false
        } else {
            setError(for: fromField, label: fromError, message: nil)
        }

        let msg = messageBox.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if msg.isEmpty {
            setTextViewError(message: "Please enter a message")
            ok = false
        } else if msg.count > maxMessageChars {
            setTextViewError(message: "Message must be \(maxMessageChars) characters or less")
            ok = false
        } else {
            setTextViewError(message: nil)
        }

        if !recipientEnabled {
            ok = false
        }

        if recipientEnabled {
            if rNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
                setError(for: rNameField, label: rNameError, message: "Please enter a recipient name")
                ok = false
            } else {
                setError(for: rNameField, label: rNameError, message: nil)
            }

            let email = (rEmailField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if email.isEmpty || !isValidEmail(email) {
                setError(for: rEmailField, label: rEmailError, message: "Please enter a valid email address")
                ok = false
            } else {
                setError(for: rEmailField, label: rEmailError, message: nil)
            }
        }

        if ok {
            print("✅ OK -> Go next")
        } else {
            showToast("Fill all required fields first")
        }
    }

    // MARK: - UITextView
    func textViewDidChange(_ textView: UITextView) {
        messagePlaceholder.isHidden = !textView.text.isEmpty
        if !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            setTextViewError(message: nil)
        }
    }

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {

        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }

        let current = textView.text ?? ""
        guard let r = Range(range, in: current) else { return true }
        let updated = current.replacingCharacters(in: r, with: text)
        return updated.count <= maxMessageChars
    }

    // MARK: - TextField delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === fromField { setError(for: fromField, label: fromError, message: nil) }
        if textField === rNameField { setError(for: rNameField, label: rNameError, message: nil) }
        if textField === rEmailField { setError(for: rEmailField, label: rEmailError, message: nil) }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Helpers
    private func styleTextField(_ tf: UITextField, placeholder: String) {
        tf.backgroundColor = UIColor.systemGray6
        tf.layer.cornerRadius = 14
        tf.clipsToBounds = true
        tf.font = .systemFont(ofSize: 18, weight: .semibold)
        tf.textColor = .label
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: UIColor.tertiaryLabel
            ]
        )
        tf.heightAnchor.constraint(equalToConstant: 56).isActive = true

        let pad = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf.leftView = pad
        tf.leftViewMode = .always

        // ✅ لا نحط حدود/ألوان تتغير مع الايرور
        tf.layer.borderWidth = 0
        tf.layer.borderColor = UIColor.clear.cgColor
    }

    private func fromErrorLabelStyle(_ lbl: UILabel) {
        lbl.textColor = .systemRed
        lbl.font = .systemFont(ofSize: 16, weight: .semibold)
        lbl.numberOfLines = 0
        lbl.isHidden = true
    }

    private func messageErrorLabelStyle(_ lbl: UILabel) {
        lbl.textColor = .systemRed
        lbl.font = .systemFont(ofSize: 16, weight: .semibold)
        lbl.numberOfLines = 0
        lbl.isHidden = true
    }

    // ✅ فقط الليبل يظهر/يختفي — بدون تحديد الأحمر على الحقول
    private func setError(for tf: UITextField, label: UILabel, message: String?) {
        if let message, !message.isEmpty {
            label.text = message
            label.isHidden = false
        } else {
            label.text = nil
            label.isHidden = true
        }
    }

    // ✅ فقط الليبل — بدون إطار أحمر على الـ TextView
    private func setTextViewError(message: String?) {
        if let message, !message.isEmpty {
            messageError.text = message
            messageError.isHidden = false
        } else {
            messageError.text = nil
            messageError.isHidden = true
        }
    }

    private func setRecipientEnabled(_ enabled: Bool) {
        recipientEnabled = enabled

        rNameField.isEnabled = enabled
        rEmailField.isEnabled = enabled

        let alpha: CGFloat = enabled ? 1.0 : 0.55
        rNameField.alpha = alpha
        rEmailField.alpha = alpha

        if !enabled {
            setError(for: rNameField, label: rNameError, message: nil)
            setError(for: rEmailField, label: rEmailError, message: nil)
        }
    }

    private func showToast(_ text: String) {
        toastLabel.text = text
        toastView.alpha = 0
        toastView.transform = CGAffineTransform(translationX: 0, y: 12)

        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut]) {
            self.toastView.alpha = 1
            self.toastView.transform = .identity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [weak self] in
            guard let self else { return }
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn]) {
                self.toastView.alpha = 0
                self.toastView.transform = CGAffineTransform(translationX: 0, y: 12)
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    private func spacer(_ h: CGFloat) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: h).isActive = true
        return v
    }

    private func makePairRow(left: UILabel, right: UILabel) -> UIView {
        let v = UIView()
        let s = UIStackView(arrangedSubviews: [left, right])
        s.axis = .vertical
        s.spacing = 4
        v.addSubview(s)
        s.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            s.topAnchor.constraint(equalTo: v.topAnchor),
            s.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            s.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            s.bottomAnchor.constraint(equalTo: v.bottomAnchor),
        ])
        return v
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
