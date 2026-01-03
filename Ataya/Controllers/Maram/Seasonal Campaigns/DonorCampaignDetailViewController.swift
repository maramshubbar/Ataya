//
//  DonorCampaignDetailViewController.swift
//  Ataya
//
//  Created by Maram on 25/12/2025.
//

//
//  DonorCampaignDetailViewController.swift
//  Ataya
//
//  Created by Maram on 25/12/2025.
//

import UIKit

final class DonorCampaignDetailViewController: UIViewController {

    // MARK: - ViewModel
    struct ViewModel {
        let title: String
        let category: String
        let imageURL: String?

        let goalAmount: Double
        let raisedAmount: Double
        let daysLeftText: String

        let overviewText: String

        let quoteText: String
        let quoteAuthor: String

        let orgName: String
        let orgAbout: String
    }

    // MARK: - Public
    private var model: ViewModel
    private var onDonate: (() -> Void)?

    init(model: ViewModel, onDonate: (() -> Void)? = nil) {
        self.model = model
        self.onDonate = onDonate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.model = ViewModel(
            title: "Campaign",
            category: "",
            imageURL: nil,
            goalAmount: 0,
            raisedAmount: 0,
            daysLeftText: "—",
            overviewText: "—",
            quoteText: "—",
            quoteAuthor: "—",
            orgName: "—",
            orgAbout: "—"
        )
        self.onDonate = nil
        super.init(coder: coder)
    }

    // ✅ PAYMENT (Storyboard file name + VC Storyboard ID)
    private let paymentStoryboardName = "BasketFunds"   // اسم ملف الستوريبورد
    private let paymentStoryboardID   = "FundsDonation" // Storyboard ID داخل Identity Inspector

    // MARK: - Local Hex Color Helper
    private func color(hex: String, alpha: CGFloat = 1) -> UIColor {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6 else { return UIColor.systemYellow.withAlphaComponent(alpha) }

        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }

    // MARK: - Colors
    private lazy var brandYellow = color(hex: "#F7D44C")
    private lazy var borderGray  = color(hex: "#E6E6E6")
    private lazy var cardCream   = color(hex: "#FFF7E6")

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Hero
    private let heroImageView = UIImageView()

    private let statusPill = DonorPaddedLabel()

    private let heroOverlay = UIView()
    private let heroTitleLabel = UILabel()
    private let heroGradient = CAGradientLayer()

    private let progressTrack = UIView()
    private let progressFill  = UIView()
    private var progressWidthC: NSLayoutConstraint?
    private var pendingProgress: CGFloat?

    private let progressInfoRow = UIStackView()
    private let leftAmountLabel = UILabel()
    private let rightPercentLabel = UILabel()

    // Body
    private let statsRow = UIStackView()

    private let overviewTitle = UILabel()
    private let overviewBody  = UILabel()

    private let quoteCard = UIView()
    private let quoteIcon = UIImageView()
    private let quoteLabel = UILabel()
    private let quoteAuthorLabel = UILabel()

    private let aboutTitle = UILabel()
    private let aboutBody  = UILabel()

    private let donateButton = UIButton(type: .system)

    private var imageTask: URLSessionDataTask?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.semanticContentAttribute = .forceLeftToRight

        setupNav()
        setupScroll()
        setupHero()
        setupBody()
        applyModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        heroGradient.frame = heroOverlay.bounds

        if let p = pendingProgress {
            pendingProgress = nil
            setProgress(Double(p), animated: false)
        }
    }

    deinit { imageTask?.cancel() }

    // MARK: - Nav
    private func setupNav() {
        title = model.title
        navigationItem.largeTitleDisplayMode = .never

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(didTapShare)
        )
    }

    @objc private func didTapBack() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func didTapShare() {
        let text = model.title
        let ac = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(ac, animated: true)
    }

    // MARK: - Scroll
    private func setupScroll() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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

    // MARK: - Hero
    private func setupHero() {
        heroImageView.backgroundColor = color(hex: "#F2F2F7")
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroImageView.image = UIImage(systemName: "photo")

        contentView.addSubview(heroImageView)
        heroImageView.translatesAutoresizingMaskIntoConstraints = false

        statusPill.font = .systemFont(ofSize: 13, weight: .semibold)
        statusPill.textColor = .white
        statusPill.textAlignment = .left
        statusPill.layer.cornerRadius = 0
        statusPill.layer.masksToBounds = true
        statusPill.isHidden = true
        statusPill.layer.zPosition = 50

        heroImageView.addSubview(statusPill)
        statusPill.translatesAutoresizingMaskIntoConstraints = false

        heroOverlay.backgroundColor = .clear
        heroImageView.addSubview(heroOverlay)
        heroOverlay.translatesAutoresizingMaskIntoConstraints = false

        heroGradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.55).cgColor
        ]
        heroGradient.locations = [0.0, 1.0]
        heroOverlay.layer.insertSublayer(heroGradient, at: 0)

        heroTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        heroTitleLabel.textColor = .white
        heroTitleLabel.numberOfLines = 2
        heroTitleLabel.textAlignment = .left
        heroOverlay.addSubview(heroTitleLabel)
        heroTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        setupProgressBarUI()

        leftAmountLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        leftAmountLabel.textColor = UIColor.white.withAlphaComponent(0.95)
        leftAmountLabel.textAlignment = .left

        rightPercentLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        rightPercentLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        rightPercentLabel.textAlignment = .right

        progressInfoRow.axis = .horizontal
        progressInfoRow.alignment = .center
        progressInfoRow.spacing = 8
        progressInfoRow.addArrangedSubview(leftAmountLabel)
        progressInfoRow.addArrangedSubview(UIView())
        progressInfoRow.addArrangedSubview(rightPercentLabel)

        heroImageView.addSubview(progressTrack)
        heroImageView.addSubview(progressInfoRow)
        progressTrack.translatesAutoresizingMaskIntoConstraints = false
        progressInfoRow.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heroImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroImageView.heightAnchor.constraint(equalToConstant: 366),

            statusPill.topAnchor.constraint(equalTo: heroImageView.topAnchor, constant: 0),
            statusPill.leadingAnchor.constraint(equalTo: heroImageView.leadingAnchor, constant: 0),
            statusPill.heightAnchor.constraint(equalToConstant: 32),

            heroOverlay.leadingAnchor.constraint(equalTo: heroImageView.leadingAnchor),
            heroOverlay.trailingAnchor.constraint(equalTo: heroImageView.trailingAnchor),
            heroOverlay.bottomAnchor.constraint(equalTo: heroImageView.bottomAnchor),
            heroOverlay.heightAnchor.constraint(equalToConstant: 170),

            progressInfoRow.bottomAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: -18),
            progressInfoRow.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressInfoRow.trailingAnchor.constraint(equalTo: progressTrack.trailingAnchor),

            progressTrack.bottomAnchor.constraint(equalTo: progressInfoRow.topAnchor, constant: -8),
            progressTrack.centerXAnchor.constraint(equalTo: heroImageView.centerXAnchor),
            progressTrack.widthAnchor.constraint(equalToConstant: 392),
            progressTrack.heightAnchor.constraint(equalToConstant: 28),

            heroTitleLabel.bottomAnchor.constraint(equalTo: progressTrack.topAnchor, constant: -14),
            heroTitleLabel.leadingAnchor.constraint(equalTo: heroOverlay.leadingAnchor, constant: 24),
            heroTitleLabel.trailingAnchor.constraint(equalTo: heroOverlay.trailingAnchor, constant: -24),
        ])

        heroImageView.bringSubviewToFront(statusPill)
    }

    // MARK: - Progress UI
    private func setupProgressBarUI() {
        let trackH: CGFloat = 28
        let padding: CGFloat = 2

        progressTrack.backgroundColor = .clear
        progressTrack.layer.borderWidth = 1
        progressTrack.layer.borderColor = UIColor.white.withAlphaComponent(0.75).cgColor
        progressTrack.layer.cornerRadius = trackH / 2
        progressTrack.layer.masksToBounds = true

        progressFill.backgroundColor = brandYellow
        progressFill.layer.cornerRadius = (trackH - padding*2) / 2
        progressFill.layer.masksToBounds = true

        progressTrack.addSubview(progressFill)
        progressFill.translatesAutoresizingMaskIntoConstraints = false

        let w = progressFill.widthAnchor.constraint(equalToConstant: 0)
        progressWidthC = w

        NSLayoutConstraint.activate([
            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor, constant: padding),
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor, constant: padding),
            progressFill.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor, constant: -padding),
            w
        ])
    }

    private func setProgress(_ value: Double, animated: Bool = true) {
        let p = max(0, min(1, CGFloat(value)))

        let usableWidth = progressTrack.bounds.width - 4
        guard usableWidth > 0 else {
            pendingProgress = p
            return
        }

        progressWidthC?.constant = usableWidth * p

        if animated {
            UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
        } else {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Body
    private func setupBody() {
        statsRow.axis = .horizontal
        statsRow.spacing = 14
        statsRow.distribution = .fillEqually
        statsRow.alignment = .center

        overviewTitle.text = "Campaign Overview"
        overviewTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        overviewTitle.textColor = .label

        overviewBody.font = .systemFont(ofSize: 14.5, weight: .regular)
        overviewBody.textColor = .label
        overviewBody.numberOfLines = 0
        overviewBody.textAlignment = .left

        quoteCard.backgroundColor = cardCream
        quoteCard.layer.cornerRadius = 26
        quoteCard.layer.borderWidth = 1
        quoteCard.layer.borderColor = borderGray.cgColor
        quoteCard.layer.masksToBounds = true

        quoteIcon.image = UIImage(systemName: "quote.opening")
        quoteIcon.tintColor = brandYellow
        quoteIcon.contentMode = .scaleAspectFit

        quoteLabel.font = .systemFont(ofSize: 18, weight: .bold)
        quoteLabel.textColor = .label
        quoteLabel.numberOfLines = 0
        quoteLabel.textAlignment = .center

        quoteAuthorLabel.font = .systemFont(ofSize: 16, weight: .regular)
        quoteAuthorLabel.textColor = .secondaryLabel
        quoteAuthorLabel.textAlignment = .right
        quoteAuthorLabel.semanticContentAttribute = .forceLeftToRight

        [quoteIcon, quoteLabel, quoteAuthorLabel].forEach {
            quoteCard.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            quoteIcon.topAnchor.constraint(equalTo: quoteCard.topAnchor, constant: 20),
            quoteIcon.leadingAnchor.constraint(equalTo: quoteCard.leadingAnchor, constant: 22),
            quoteIcon.widthAnchor.constraint(equalToConstant: 34),
            quoteIcon.heightAnchor.constraint(equalToConstant: 34),

            quoteLabel.topAnchor.constraint(equalTo: quoteCard.topAnchor, constant: 22),
            quoteLabel.leadingAnchor.constraint(equalTo: quoteCard.leadingAnchor, constant: 70),
            quoteLabel.trailingAnchor.constraint(equalTo: quoteCard.trailingAnchor, constant: -24),

            quoteAuthorLabel.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: 18),
            quoteAuthorLabel.leadingAnchor.constraint(equalTo: quoteLabel.leadingAnchor),
            quoteAuthorLabel.trailingAnchor.constraint(equalTo: quoteLabel.trailingAnchor),
            quoteAuthorLabel.bottomAnchor.constraint(equalTo: quoteCard.bottomAnchor, constant: -18)
        ])

        aboutTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        aboutTitle.textColor = .label

        aboutBody.font = .systemFont(ofSize: 14.5, weight: .regular)
        aboutBody.textColor = .label
        aboutBody.numberOfLines = 0
        aboutBody.textAlignment = .left

        donateButton.setTitle("Donate Now", for: .normal)
        donateButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        donateButton.backgroundColor = brandYellow
        donateButton.setTitleColor(.black, for: .normal)
        donateButton.layer.cornerRadius = 8
        donateButton.layer.masksToBounds = true
        donateButton.addTarget(self, action: #selector(didTapDonateNow), for: .touchUpInside)

        let wrap = UIView()
        contentView.addSubview(wrap)
        wrap.translatesAutoresizingMaskIntoConstraints = false

        [statsRow, overviewTitle, overviewBody, quoteCard, aboutTitle, aboutBody, donateButton].forEach {
            wrap.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            wrap.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: 14),
            wrap.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            wrap.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            wrap.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -22),

            statsRow.topAnchor.constraint(equalTo: wrap.topAnchor),
            statsRow.leadingAnchor.constraint(equalTo: wrap.leadingAnchor),
            statsRow.trailingAnchor.constraint(equalTo: wrap.trailingAnchor),

            overviewTitle.topAnchor.constraint(equalTo: statsRow.bottomAnchor, constant: 18),
            overviewTitle.leadingAnchor.constraint(equalTo: wrap.leadingAnchor),
            overviewTitle.trailingAnchor.constraint(equalTo: wrap.trailingAnchor),

            overviewBody.topAnchor.constraint(equalTo: overviewTitle.bottomAnchor, constant: 10),
            overviewBody.leadingAnchor.constraint(equalTo: wrap.leadingAnchor),
            overviewBody.trailingAnchor.constraint(equalTo: wrap.trailingAnchor),

            quoteCard.topAnchor.constraint(equalTo: overviewBody.bottomAnchor, constant: 18),
            quoteCard.leadingAnchor.constraint(equalTo: wrap.leadingAnchor),
            quoteCard.trailingAnchor.constraint(equalTo: wrap.trailingAnchor),

            aboutTitle.topAnchor.constraint(equalTo: quoteCard.bottomAnchor, constant: 18),
            aboutTitle.leadingAnchor.constraint(equalTo: wrap.leadingAnchor),
            aboutTitle.trailingAnchor.constraint(equalTo: wrap.trailingAnchor),

            aboutBody.topAnchor.constraint(equalTo: aboutTitle.bottomAnchor, constant: 10),
            aboutBody.leadingAnchor.constraint(equalTo: wrap.leadingAnchor),
            aboutBody.trailingAnchor.constraint(equalTo: wrap.trailingAnchor),

            donateButton.topAnchor.constraint(equalTo: aboutBody.bottomAnchor, constant: 24),
            donateButton.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            donateButton.widthAnchor.constraint(equalToConstant: 362),
            donateButton.heightAnchor.constraint(equalToConstant: 54),
            donateButton.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -6),
        ])
    }

    // MARK: - Apply Model
    private func applyModel() {
        title = model.title
        heroTitleLabel.text = model.title

        applyCategoryPill(model.category)

        let p = (model.goalAmount <= 0) ? 0 : (model.raisedAmount / model.goalAmount)
        setProgress(p, animated: false)

        leftAmountLabel.text = "\(money(model.raisedAmount)) of \(money(model.goalAmount)) $"
        rightPercentLabel.text = "\(Int(max(0, min(1, p)) * 100)) %"

        statsRow.arrangedSubviews.forEach { $0.removeFromSuperview() }

        statsRow.addArrangedSubview(statItem(icon: "target", title: "Goal",  value: "\(money(model.goalAmount)) $"))
        statsRow.addArrangedSubview(statItem(icon: "chart.line.uptrend.xyaxis", title: "Raised", value: "\(money(model.raisedAmount)) $"))
        statsRow.addArrangedSubview(statItem(icon: "clock", title: "Days",  value: model.daysLeftText))

        overviewBody.text = model.overviewText.isEmpty ? "—" : model.overviewText

        quoteLabel.text = model.quoteText.isEmpty ? "—" : model.quoteText
        quoteAuthorLabel.text = model.quoteAuthor.isEmpty ? "—" : model.quoteAuthor

        aboutTitle.text = "About HopPal"
        aboutBody.text = """
        HopPal is a humanitarian organization dedicated to helping families in crisis rebuild their lives with dignity. We deliver urgent medical aid, food, water, and long-term recovery support to those affected by conflict and disaster. Guided by compassion and transparency, we work to restore hope where it’s needed most.
        """

        loadHeroImage(urlString: model.imageURL)
    }

    private func applyCategoryPill(_ raw: String) {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else {
            statusPill.isHidden = true
            return
        }

        let lower = s.lowercased()
        statusPill.isHidden = false
        statusPill.text = s

        if lower == "emergency" {
            statusPill.backgroundColor = UIColor.systemRed.withAlphaComponent(0.88)
        } else if lower == "critical" {
            statusPill.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.88)
        } else if lower == "climate change" || lower == "climatechange" {
            statusPill.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.85)
        } else {
            statusPill.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        }
    }

    private func statItem(icon: String, title: String, value: String) -> UIView {
        let v = UIView()

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = brandYellow
        iconView.contentMode = .scaleAspectFit

        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLbl.textColor = .secondaryLabel
        titleLbl.textAlignment = .center

        let valueLbl = UILabel()
        valueLbl.text = value
        valueLbl.font = .systemFont(ofSize: 13, weight: .semibold)
        valueLbl.textColor = .label
        valueLbl.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [iconView, titleLbl, valueLbl])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6

        v.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let iconSize: CGFloat = 24
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: v.topAnchor),
            stack.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: v.bottomAnchor),

            iconView.widthAnchor.constraint(equalToConstant: iconSize),
            iconView.heightAnchor.constraint(equalToConstant: iconSize)
        ])

        return v
    }

    private func loadHeroImage(urlString: String?) {
        heroImageView.image = UIImage(systemName: "photo")
        imageTask?.cancel()
        imageTask = nil

        guard let s = urlString, let url = URL(string: s) else { return }

        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.heroImageView.image = img }
        }
        imageTask?.resume()
    }

    private func money(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }

    // ✅ زر Donate Now -> يفتح DonateFundsViewController
    @objc private func didTapDonateNow() {
        openPayment()
    }

    private func openPayment() {
        let sb = UIStoryboard(name: paymentStoryboardName, bundle: .main)

        guard let vc = sb.instantiateViewController(withIdentifier: paymentStoryboardID) as? DonateFundsViewController else {
            assertionFailure("❌ \(paymentStoryboardName).storyboard ما فيه VC بالـ ID '\(paymentStoryboardID)' أو الكلاس مو DonateFundsViewController")
            return
        }

        vc.hidesBottomBarWhenPushed = true

        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
        } else if let nav = self.tabBarController?.selectedViewController as? UINavigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
}

// MARK: - Padded Badge
final class DonorPaddedLabel: UILabel {
    var insets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(
            width: s.width + insets.left + insets.right,
            height: s.height + insets.top + insets.bottom
        )
    }
}
