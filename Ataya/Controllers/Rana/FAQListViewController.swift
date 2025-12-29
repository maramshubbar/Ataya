//
//  FAQListViewViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 29/12/2025.
//
import UIKit

// ✅ MUST be outside any class (so FAQDetails can see it)
struct FAQItem {
    let title: String
    let preview: String
    let body: String
    let showsSubmitButton: Bool

    static let all: [FAQItem] = [
        FAQItem(
            title: "How can I contact support if I face an issue?",
            preview: "Find out how to reach the Ataya support team through the in-app Help & Support section.",
            body:
"""
If you encounter any problem — such as scheduling errors, pickup delays, or technical issues — you can easily reach the Ataya support team through the in-app Help & Support section.

Follow these steps:
1- Scroll to the bottom of the page and select Submit Support Ticket.
2- Fill in the required fields:
• Issue Category: Choose from options like Pickup Issue, Verification Problem, Technical Error, or Others.
• Describe Your Issue: Write a clear explanation of what went wrong.
• Attach Screenshot (optional): You can upload an image to help the admin understand the problem.
• Contact Email: Confirm your email for follow-up.

- Tap Submit Ticket to send your request.
- You will receive a notification once the admin replies to your ticket.
- You can also check your previous requests anytime by opening My Support Tickets.

📩 Tip: For faster responses, always include screenshots and describe what steps you took before the issue happened.

Note: You will receive a notification when the admin replies.
""",
            showsSubmitButton: true
        ),
        FAQItem(
            title: "How do I know if my donation has been collected?",
            preview: "Find out how to check your donation status and confirm when it’s been successfully collected.",
            body:
"""
You can easily check whether your donation has been collected through the Donation Status or Donation History pages.
The system automatically updates your donation progress in real time as the collector completes each step.

Follow these steps:
1- Go to your Donation History or Ongoing Donations from your dashboard.
2- Tap the donation you want to check.
3- Look at the Status Tracker — it shows all stages:
• Pending – waiting for NGO or collector confirmation.
• Accepted – pickup has been approved and scheduled.
• In Transit – the collector is on the way to pick up the donation.
• Collected – your donation has been successfully picked up.

- When the collector marks your item as Collected, the status bar automatically updates to Collected.
- You’ll also receive a notification confirming the collection and showing the number of meals provided through your donation.

💡 Tip: You can view the full collection details — such as collector name, pickup time, and delivery location — by tapping View Details on the donation card.
""",
            showsSubmitButton: false
        ),
        FAQItem(
            title: "How can I track my overall impact?",
            preview: "Find out how to view your total meals provided and waste prevented in the Impact Dashboard.",
            body:
"""
You can view your personal contribution and community impact through the Impact Dashboard, which is connected to several parts of the Ataya system.
This dashboard collects live data from your donations and displays visual statistics showing how much difference you’ve made.

Steps:
1- Open the Impact Dashboard from the bottom navigation bar or the Home screen.
2- The system automatically retrieves your verified donation data and calculates your total results.
3- You’ll see key indicators such as:
• Meals Provided – the number of people or families fed.
• Food Waste Prevented – total kilograms or portions saved from expiry.
• Environmental Equivalent – for example, CO₂ saved or resources preserved.
4- Use the time filters (weekly, monthly, yearly) to compare your performance.
5- Tap Share Impact to post your results on social media or download your stats as an image.
6- Your achievements are also linked to your Reward Points and Badges in the Gamification system.
""",
            showsSubmitButton: false
        ),
        FAQItem(
            title: "Why Ataya?",
            preview: "Find out what makes Ataya unique and how it connects donors, NGOs, and volunteers to fight food waste.",
            body:
"""
Ataya was created to make food donation simple, safe, and impactful.
The name “Ataya” means “Giving” in Arabic — a reflection of generosity, compassion, and community support.

The app bridges the gap between people who have surplus food and organizations that deliver meals to those in need.
Through Ataya, donors, NGOs, and volunteers connect within one digital platform to reduce food waste and fight hunger in local communities.
The system ensures that every donation is verified, tracked, and safely delivered.

Key reasons that make Ataya unique:
- Smart Coordination: Automatically matches donors with verified NGOs and collectors for fast, conflict-free pickups.
- Transparency: Real-time donation tracking keeps both donors and NGOs informed of every stage — from scheduling to delivery.
- Safety & Trust: Each food item passes safety checks and collector inspection before reaching beneficiaries.
- Impact Awareness: Users can view their contribution through the Impact Dashboard — showing meals provided, waste prevented, and environmental benefits.
- Sustainability: Ataya directly supports UN SDG 2 (Zero Hunger) and SDG 12 (Responsible Consumption and Production).
""",
            showsSubmitButton: false
        )
    ]
}

final class FAQListViewController: UIViewController {

    // Header
    private let headerContainer = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    // Cards
    private let stack = UIStackView()
    private let items: [FAQItem] = FAQItem.all

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupHeader()
        setupCards()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func setupHeader() {
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerContainer)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Help & Support"
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
            titleLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor)
        ])
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupCards() {
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill   // ✅ THIS is the correct line (don’t edit)

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 28),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36)
        ])

        for item in items {
            let card = FAQPreviewCardView(title: item.title, subtitle: item.preview)
            card.onTap = { [weak self] in
                let vc = FAQDetailsViewController(item: item)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            stack.addArrangedSubview(card)
        }
    }
}

// MARK: - Card view (same style, perfect equal size)

private final class FAQPreviewCardView: UIControl {

    var onTap: (() -> Void)?

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        titleLabel.text = title
        subtitleLabel.text = subtitle
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.88, alpha: 1).cgColor

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor(white: 0.35, alpha: 1)
        subtitleLabel.numberOfLines = 0

        addSubview(titleLabel)
        addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            // ✅ Perfect equal size (no color/text changes)
            heightAnchor.constraint(equalToConstant: 92),

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -14)
        ])
    }

    @objc private func tapped() {
        UIView.animate(withDuration: 0.08, animations: {
            self.transform = CGAffineTransform(scaleX: 0.985, y: 0.985)
        }, completion: { _ in
            UIView.animate(withDuration: 0.08) { self.transform = .identity }
        })
        onTap?()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
}
