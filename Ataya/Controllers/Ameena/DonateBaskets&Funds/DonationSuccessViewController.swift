import UIKit

final class DonationSuccessViewController: UIViewController {

    // MARK: - Colors
    private let atayaYellow = UIColor(red: 0xF7/255.0, green: 0xD4/255.0, blue: 0x4C/255.0, alpha: 1.0)

    // MARK: - UI
    private let dimView = UIView()
    private let cardView = UIView()

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let backHomeButton = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        layoutUI()
    }

    private func buildUI() {
        view.backgroundColor = .clear

        // Dim background
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)

        // Card
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 8
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)

        // Icon (from Assets: "success icon")
        iconImageView.image = UIImage(named: "Succes icon")
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconImageView)

        // Title
        titleLabel.text = "Thank You"
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)

        // Small font subtitle
        subtitleLabel.text = "Your donation has been received!"
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(subtitleLabel)

        // Back Home button
        backHomeButton.setTitle("Back Home", for: .normal)
        backHomeButton.backgroundColor = atayaYellow
        backHomeButton.setTitleColor(.black, for: .normal)
        backHomeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        backHomeButton.layer.cornerRadius = 8  // ✅ button radius = 8
        backHomeButton.translatesAutoresizingMaskIntoConstraints = false
        backHomeButton.addTarget(self, action: #selector(backHomeTapped), for: .touchUpInside)
        cardView.addSubview(backHomeButton)
    }

    private func layoutUI() {
        NSLayoutConstraint.activate([
            // Dim fill
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Card size: 454x361
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 361),
            cardView.heightAnchor.constraint(equalToConstant: 400),

            // Icon (you didn’t give exact size, so I keep it clean + easy to tweak)
            iconImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 48),
            iconImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 120),
            iconImageView.heightAnchor.constraint(equalToConstant: 120),

            // Title
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            // Subtitle (small font)
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            // Back Home button size: 54x340
            backHomeButton.heightAnchor.constraint(equalToConstant: 54),
            backHomeButton.widthAnchor.constraint(equalToConstant: 340),
            backHomeButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            backHomeButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -22),
        ])
    }

    @objc private func backHomeTapped() {
        dismiss(animated: true) { [weak self] in
            self?.presentingViewController?.navigationController?.popToRootViewController(animated: true)
        }
    }
}
