import UIKit

class NGOAboutMeViewController: UIViewController {

    // MARK: - Title Labels
    private let fullNameTitleLabel = UILabel()
    private let emailTitleLabel = UILabel()
    private let phoneTitleLabel = UILabel()

    // MARK: - Value Labels
    private let fullNameValueLabel = UILabel()
    private let emailValueLabel = UILabel()
    private let phoneValueLabel = UILabel()

    // MARK: - Value Containers (Rectangles)
    private let fullNameBox = UIView()
    private let emailBox = UIView()
    private let phoneBox = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "About Me"

        setupTitleLabels()
        setupValueBoxes()
        setupValueLabels()
        setupConstraints()
        loadData()
    }

    // MARK: - Setup Title Labels
    private func setupTitleLabels() {
        let labels = [fullNameTitleLabel, emailTitleLabel, phoneTitleLabel]

        labels.forEach {
            $0.font = .systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = .secondaryLabel
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        fullNameTitleLabel.text = "Full name"
        emailTitleLabel.text = "Email"
        phoneTitleLabel.text = "Phone"
    }

    // MARK: - Setup Value Boxes
    private func setupValueBoxes() {
        let boxes = [fullNameBox, emailBox, phoneBox]

        boxes.forEach {
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    // MARK: - Setup Value Labels
    private func setupValueLabels() {
        let labels = [fullNameValueLabel, emailValueLabel, phoneValueLabel]

        labels.forEach {
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .label
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        fullNameBox.addSubview(fullNameValueLabel)
        emailBox.addSubview(emailValueLabel)
        phoneBox.addSubview(phoneValueLabel)
    }

    // MARK: - Constraints
    private func setupConstraints() {

        NSLayoutConstraint.activate([

            // Full Name Title
            fullNameTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            fullNameTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fullNameTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Full Name Box
            fullNameBox.topAnchor.constraint(equalTo: fullNameTitleLabel.bottomAnchor, constant: 6),
            fullNameBox.leadingAnchor.constraint(equalTo: fullNameTitleLabel.leadingAnchor),
            fullNameBox.trailingAnchor.constraint(equalTo: fullNameTitleLabel.trailingAnchor),
            fullNameBox.heightAnchor.constraint(equalToConstant: 44),

            // Full Name Value Label
            fullNameValueLabel.leadingAnchor.constraint(equalTo: fullNameBox.leadingAnchor, constant: 12),
            fullNameValueLabel.trailingAnchor.constraint(equalTo: fullNameBox.trailingAnchor, constant: -12),
            fullNameValueLabel.centerYAnchor.constraint(equalTo: fullNameBox.centerYAnchor),

            // Email Title
            emailTitleLabel.topAnchor.constraint(equalTo: fullNameBox.bottomAnchor, constant: 20),
            emailTitleLabel.leadingAnchor.constraint(equalTo: fullNameTitleLabel.leadingAnchor),
            emailTitleLabel.trailingAnchor.constraint(equalTo: fullNameTitleLabel.trailingAnchor),

            // Email Box
            emailBox.topAnchor.constraint(equalTo: emailTitleLabel.bottomAnchor, constant: 6),
            emailBox.leadingAnchor.constraint(equalTo: fullNameTitleLabel.leadingAnchor),
            emailBox.trailingAnchor.constraint(equalTo: fullNameTitleLabel.trailingAnchor),
            emailBox.heightAnchor.constraint(equalToConstant: 44),

            // Email Value Label
            emailValueLabel.leadingAnchor.constraint(equalTo: emailBox.leadingAnchor, constant: 12),
            emailValueLabel.trailingAnchor.constraint(equalTo: emailBox.trailingAnchor, constant: -12),
            emailValueLabel.centerYAnchor.constraint(equalTo: emailBox.centerYAnchor),

            // Phone Title
            phoneTitleLabel.topAnchor.constraint(equalTo: emailBox.bottomAnchor, constant: 20),
            phoneTitleLabel.leadingAnchor.constraint(equalTo: fullNameTitleLabel.leadingAnchor),
            phoneTitleLabel.trailingAnchor.constraint(equalTo: fullNameTitleLabel.trailingAnchor),

            // Phone Box
            phoneBox.topAnchor.constraint(equalTo: phoneTitleLabel.bottomAnchor, constant: 6),
            phoneBox.leadingAnchor.constraint(equalTo: fullNameTitleLabel.leadingAnchor),
            phoneBox.trailingAnchor.constraint(equalTo: fullNameTitleLabel.trailingAnchor),
            phoneBox.heightAnchor.constraint(equalToConstant: 44),

            // Phone Value Label
            phoneValueLabel.leadingAnchor.constraint(equalTo: phoneBox.leadingAnchor, constant: 12),
            phoneValueLabel.trailingAnchor.constraint(equalTo: phoneBox.trailingAnchor, constant: -12),
            phoneValueLabel.centerYAnchor.constraint(equalTo: phoneBox.centerYAnchor)
        ])
    }

    // MARK: - Load Data
    private func loadData() {
        fullNameValueLabel.text = "Zahra Ahmed"
        emailValueLabel.text = "zahraahmed88@gmail.com"
        phoneValueLabel.text = "+973 66156902"
    }
}
