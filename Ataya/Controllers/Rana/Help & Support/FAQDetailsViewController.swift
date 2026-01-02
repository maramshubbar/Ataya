//
//  FAQDetailsViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 29/12/2025.
import UIKit

final class FAQDetailsViewController: UIViewController {

    private let item: FAQItem

    // Header
    private let headerContainer = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    // Scroll
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let questionLabel = UILabel()
    private let bodyLabel = UILabel()

    // Bottom button (only for first FAQ)
    private let submitButton = UIButton(type: .system)

    init(item: FAQItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupHeader()
        setupScroll()
        setupTexts()
        setupBottomButton()
        fill()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupHeader() {
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerContainer)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Frequently Asked Questions"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black

        headerContainer.addSubview(backButton)
        headerContainer.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 44),

            backButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: headerContainer.trailingAnchor, constant: -16)
        ])
    }

    @objc private func backTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

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
    }

    private func setupTexts() {
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        questionLabel.textColor = .black
        questionLabel.numberOfLines = 0

        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = UIColor(white: 0.20, alpha: 1)
        bodyLabel.numberOfLines = 0

        contentView.addSubview(questionLabel)
        contentView.addSubview(bodyLabel)

        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            questionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 36),
            questionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -36),

            bodyLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 10),
            bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 36),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -36),
            bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func setupBottomButton() {
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("Submit Support Ticket", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        submitButton.backgroundColor = UIColor(hex: "#F7D44C")
        submitButton.layer.cornerRadius = 12
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        view.addSubview(submitButton)

        let width = submitButton.widthAnchor.constraint(equalToConstant: 368)
        width.priority = UILayoutPriority(999)

        NSLayoutConstraint.activate([
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            width,
            submitButton.heightAnchor.constraint(equalToConstant: 54),

            submitButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 36),
            submitButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -36)
        ])
    }

    private func fill() {
        questionLabel.text = item.title
        bodyLabel.text = item.body

        submitButton.isHidden = !item.showsSubmitButton

        if item.showsSubmitButton {
            scrollView.contentInset.bottom = 54 + 16
            scrollView.verticalScrollIndicatorInsets.bottom = 54 + 16
        } else {
            scrollView.contentInset.bottom = 0
            scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }

    @objc private func submitTapped() {
        let vc = SubmitSupportTicketViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

//// MARK: - UIColor Hex
//private extension UIColor {
//    convenience init(hex: String) {
//        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//        if s.hasPrefix("#") { s.removeFirst() }
//        var rgb: UInt64 = 0
//        Scanner(string: s).scanHexInt64(&rgb)
//
//        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
//        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
//        let b = CGFloat(rgb & 0x0000FF) / 255
//
//        self.init(red: r, green: g, blue: b, alpha: 1)
//    }
//}
