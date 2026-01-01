import UIKit
//
//extension UIColor {
//    convenience init(hex: String) {
//        let hex = hex.replacingOccurrences(of: "#", with: "")
//        let scanner = Scanner(string: hex)
//        var rgb: UInt64 = 0
//        scanner.scanHexInt64(&rgb)
//
//        self.init(
//            red: CGFloat((rgb >> 16) & 0xFF) / 255,
//            green: CGFloat((rgb >> 8) & 0xFF) / 255,
//            blue: CGFloat(rgb & 0xFF) / 255,
//            alpha: 1
//        )
//    }
//}

class FeedbackPopupViewController: UIViewController, UITextViewDelegate {

    // MARK: - UI
    private let dimView = UIView()
    private let popupView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let starsStackView = UIStackView()
    private let reviewTextView = UITextView()
    private let submitButton = UIButton(type: .system)
    private let backHomeButton = UIButton(type: .system)

    // MARK: - Data
    private var starButtons: [UIButton] = []
    private var selectedRating = 0
    var collectorID = "collector_1"

    private let goldColor = UIColor(hex: "#F7D44C")

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .clear

        // Dim background
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)

        // Popup card
        popupView.backgroundColor = .systemBackground
        popupView.layer.cornerRadius = 8
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)

        // Title
        titleLabel.text = "How was your experience?"
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .center

        // Subtitle
        subtitleLabel.text = "Your feedback help us improve"
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center

        // Stars stack
        starsStackView.axis = .horizontal
        starsStackView.alignment = .center
        starsStackView.distribution = .equalSpacing
        starsStackView.spacing = 4
        starsStackView.translatesAutoresizingMaskIntoConstraints = false

        for i in 1...5 {
            let button = UIButton(type: .system)
            button.tag = i
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.tintColor = .systemYellow
            button.imageView?.contentMode = .scaleAspectFit
            button.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 30),
                button.heightAnchor.constraint(equalToConstant: 34)
            ])

            button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starButtons.append(button)
            starsStackView.addArrangedSubview(button)
        }

        // Review TextView
        reviewTextView.delegate = self
        reviewTextView.text = "write feedback"
        reviewTextView.textColor = .lightGray
        reviewTextView.backgroundColor = .white
        reviewTextView.layer.cornerRadius = 8
        reviewTextView.layer.borderWidth = 1
        reviewTextView.layer.borderColor = UIColor.systemGray4.cgColor
        reviewTextView.font = .systemFont(ofSize: 15)

        // Submit Button
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(goldColor, for: .normal)
        submitButton.backgroundColor = .white
        submitButton.layer.cornerRadius = 8
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = goldColor.cgColor
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        // Back Home Button
        backHomeButton.setTitle("Back Home", for: .normal)
        backHomeButton.setTitleColor(.black, for: .normal)
        backHomeButton.backgroundColor = goldColor
        backHomeButton.layer.cornerRadius = 8
        backHomeButton.addTarget(self, action: #selector(backHomeTapped), for: .touchUpInside)

        // Stack layout
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            starsStackView,
            reviewTextView,
            submitButton,
            backHomeButton
        ])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(stack)

        // Constraints
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popupView.widthAnchor.constraint(equalToConstant: 320),

            stack.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -20),

            starsStackView.heightAnchor.constraint(equalToConstant: 40),
            starsStackView.widthAnchor.constraint(equalToConstant: 200),

            reviewTextView.heightAnchor.constraint(equalToConstant: 110),
            submitButton.heightAnchor.constraint(equalToConstant: 44),
            backHomeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Star Logic
    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStars()
    }

    private func updateStars() {
        for button in starButtons {
            let imageName = button.tag <= selectedRating ? "star.fill" : "star"
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }

    // MARK: - Actions
    @objc private func submitTapped() {
        guard selectedRating > 0 else { return }

        let review = Review(
            reviewerName: "Donor Sarah",
            rating: selectedRating,
            comment: reviewTextView.text == "write feedback" ? "" : reviewTextView.text,
            date: Date()
        )

        DummyDatabase.shared.collectors[collectorID]?.reviews.append(review)
        dismiss(animated: true)
    }

    @objc private func backHomeTapped() {
        dismiss(animated: true)
    }

    // MARK: - TextView Placeholder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "write feedback" {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "write feedback"
            textView.textColor = .lightGray
        }
    }
}
