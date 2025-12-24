//
//  NGOPendingRequestDetailsViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//


import UIKit

final class NGOPendingRequestDetailsViewController: UIViewController, UITextViewDelegate {

    private let request: PendingRequest

    // MARK: - Local colors (بدون UIColor(hex:))
    private func color(hex: String, alpha: CGFloat = 1) -> UIColor {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6 else { return .systemYellow.withAlphaComponent(alpha) }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }

    private lazy var accentYellow = color(hex: "F7D44C")
    private lazy var softYellow   = color(hex: "FFF8E8")

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()

    private let summaryCard = UIView()
    private let thumb = UIImageView()
    private let line1 = UILabel()
    private let line2 = UILabel()

    private let fromTitle = UILabel()
    private let fromField = UITextField()

    private let msgTitle = UILabel()
    private let msgBox = UITextView()
    private let msgPlaceholder = UILabel()

    private let recipientCard = UIView()
    private let recipientHeader = UILabel()
    private let rNameField = UITextField()
    private let rEmailField = UITextField()
    private let addRecipientButton = UIButton(type: .system)

    private let bottomBar = UIView()
    private let previewButton = UIButton(type: .system)
    private let rejectButton  = UIButton(type: .system)
    private let approveButton = UIButton(type: .system)

    // MARK: - Init
    init(request: PendingRequest) {
        self.request = request
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        buildUI()
        fillData()
    }

    private func setupNav() {
        title = "Request details"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .black
        navigationItem.largeTitleDisplayMode = .never
    }

    private func buildUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stack)
        view.addSubview(bottomBar)

        [scrollView, contentView, stack, bottomBar].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        // Stack
        stack.axis = .vertical
        stack.spacing = 16

        // Scroll constraints
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])

        buildSummary()
        buildFrom()
        buildMessage()
        buildRecipient()
        buildBottomButtons()

        // Add arranged
        stack.addArrangedSubview(summaryCard)
        stack.addArrangedSubview(fromTitle)
        stack.addArrangedSubview(fromField)
        stack.addArrangedSubview(msgTitle)
        stack.addArrangedSubview(msgBox)
        stack.addArrangedSubview(recipientCard)
    }

    // MARK: - Sections
    private func buildSummary() {
        summaryCard.backgroundColor = .white
        summaryCard.layer.cornerRadius = 16
        summaryCard.layer.borderWidth = 1
        summaryCard.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
        summaryCard.layer.shadowColor = UIColor.black.cgColor
        summaryCard.layer.shadowOpacity = 0.06
        summaryCard.layer.shadowRadius = 10
        summaryCard.layer.shadowOffset = CGSize(width: 0, height: 6)
        summaryCard.layer.masksToBounds = false

        thumb.backgroundColor = UIColor.secondarySystemBackground
        thumb.layer.cornerRadius = 12
        thumb.clipsToBounds = true
        thumb.contentMode = .scaleAspectFill
        thumb.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumb.widthAnchor.constraint(equalToConstant: 56),
            thumb.heightAnchor.constraint(equalToConstant: 56),
        ])

        line1.numberOfLines = 0
        line2.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [line1, line2])
        textStack.axis = .vertical
        textStack.spacing = 10

        let row = UIStackView(arrangedSubviews: [thumb, textStack])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center

        summaryCard.addSubview(row)
        row.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 14),
            row.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 14),
            row.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -14),
            row.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -14)
        ])
    }

    private func buildFrom() {
        fromTitle.text = "From"
        fromTitle.font = .systemFont(ofSize: 16, weight: .regular)

        fromField.placeholder = "Type your name"
        fromField.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.6)
        fromField.layer.cornerRadius = 14
        fromField.setLeftPadding(14)
        fromField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    private func buildMessage() {
        msgTitle.text = "Personal Message"
        msgTitle.font = .systemFont(ofSize: 16, weight: .regular)

        msgBox.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.6)
        msgBox.layer.cornerRadius = 14
        msgBox.font = .systemFont(ofSize: 16)
        msgBox.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
        msgBox.heightAnchor.constraint(equalToConstant: 140).isActive = true
        msgBox.delegate = self

        msgPlaceholder.text = "This message will be displayed on the gift card\n(max. 150 characters)"
        msgPlaceholder.textColor = .secondaryLabel
        msgPlaceholder.font = .systemFont(ofSize: 15)
        msgPlaceholder.numberOfLines = 2

        msgBox.addSubview(msgPlaceholder)
        msgPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            msgPlaceholder.topAnchor.constraint(equalTo: msgBox.topAnchor, constant: 14),
            msgPlaceholder.leadingAnchor.constraint(equalTo: msgBox.leadingAnchor, constant: 14),
            msgPlaceholder.trailingAnchor.constraint(lessThanOrEqualTo: msgBox.trailingAnchor, constant: -14)
        ])
    }

    private func buildRecipient() {
        recipientCard.backgroundColor = softYellow
        recipientCard.layer.cornerRadius = 18
        recipientCard.layer.borderWidth = 1
        recipientCard.layer.borderColor = UIColor.black.withAlphaComponent(0.03).cgColor

        recipientHeader.text = "Send this certificate to (email):"
        recipientHeader.font = .systemFont(ofSize: 26, weight: .heavy)
        recipientHeader.numberOfLines = 2

        rNameField.placeholder = "Name"
        rNameField.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        rNameField.layer.cornerRadius = 14
        rNameField.setLeftPadding(14)
        rNameField.heightAnchor.constraint(equalToConstant: 50).isActive = true

        rEmailField.placeholder = "Email"
        rEmailField.keyboardType = .emailAddress
        rEmailField.autocapitalizationType = .none
        rEmailField.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        rEmailField.layer.cornerRadius = 14
        rEmailField.setLeftPadding(14)
        rEmailField.heightAnchor.constraint(equalToConstant: 50).isActive = true

        // Button: outline yellow
        var cfg = UIButton.Configuration.plain()
        cfg.title = "Add recipient"
        cfg.image = UIImage(systemName: "plus")
        cfg.imagePadding = 10
        cfg.baseForegroundColor = accentYellow
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
        addRecipientButton.configuration = cfg
        addRecipientButton.layer.cornerRadius = 16
        addRecipientButton.layer.borderWidth = 2
        addRecipientButton.layer.borderColor = accentYellow.cgColor
        addRecipientButton.backgroundColor = .clear

        let inner = UIStackView(arrangedSubviews: [
            recipientHeader,
            rNameField,
            rEmailField,
            addRecipientButton
        ])
        inner.axis = .vertical
        inner.spacing = 12

        recipientCard.addSubview(inner)
        inner.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: recipientCard.topAnchor, constant: 18),
            inner.leadingAnchor.constraint(equalTo: recipientCard.leadingAnchor, constant: 18),
            inner.trailingAnchor.constraint(equalTo: recipientCard.trailingAnchor, constant: -18),
            inner.bottomAnchor.constraint(equalTo: recipientCard.bottomAnchor, constant: -18)
        ])
    }

    private func buildBottomButtons() {
        bottomBar.backgroundColor = .systemBackground
        bottomBar.layer.shadowColor = UIColor.black.cgColor
        bottomBar.layer.shadowOpacity = 0.06
        bottomBar.layer.shadowRadius = 10
        bottomBar.layer.shadowOffset = CGSize(width: 0, height: -4)

        previewButton.setTitle("Preview", for: .normal)
        previewButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        previewButton.setTitleColor(.label, for: .normal)
        previewButton.layer.cornerRadius = 16
        previewButton.layer.borderWidth = 1
        previewButton.layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
        previewButton.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.6)

        rejectButton.setTitle("Reject", for: .normal)
        rejectButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        rejectButton.setTitleColor(.systemRed, for: .normal)
        rejectButton.layer.cornerRadius = 16
        rejectButton.layer.borderWidth = 1
        rejectButton.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.25).cgColor
        rejectButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.06)

        approveButton.setTitle("Approve", for: .normal)
        approveButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        approveButton.setTitleColor(.black, for: .normal)
        approveButton.layer.cornerRadius = 16
        approveButton.backgroundColor = accentYellow

        let row = UIStackView(arrangedSubviews: [previewButton, rejectButton, approveButton])
        row.axis = .horizontal
        row.spacing = 10
        row.distribution = .fillEqually

        bottomBar.addSubview(row)
        row.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bottomBar.heightAnchor.constraint(equalToConstant: 110),

            row.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 14),
            row.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            row.heightAnchor.constraint(equalToConstant: 52),
            row.bottomAnchor.constraint(lessThanOrEqualTo: bottomBar.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    private func fillData() {
        // green highlight like your screenshot
        line1.attributedText = twoLine(title: "Name of Gift:", value: "\(request.giftName) \(request.amountText)", valueColor: .systemGreen)
        line2.attributedText = twoLine(title: "Card Design:", value: request.cardDesign, valueColor: .systemGreen)

        // optional thumbnail based on design
        thumb.image = UIImage(named: "c1") // change later to match design

        fromField.text = ""
        msgBox.text = ""
        msgPlaceholder.isHidden = false

        rNameField.text = ""
        rEmailField.text = request.toEmail  // prefill from request
    }

    private func twoLine(title: String, value: String, valueColor: UIColor) -> NSAttributedString {
        let a = NSMutableAttributedString(
            string: "\(title)\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                .foregroundColor: UIColor.label
            ]
        )
        a.append(NSAttributedString(
            string: value,
            attributes: [
                .font: UIFont.systemFont(ofSize: 18, weight: .heavy),
                .foregroundColor: valueColor
            ]
        ))
        return a
    }

    // MARK: - Placeholder behavior
    func textViewDidChange(_ textView: UITextView) {
        msgPlaceholder.isHidden = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
