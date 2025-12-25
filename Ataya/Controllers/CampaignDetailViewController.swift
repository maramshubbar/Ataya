//
//  CampaignDetailViewController.swift
//  Ataya
//
//  Created by Maram on 25/12/2025.
//


import UIKit

final class CampaignDetailViewController: UIViewController {

    // MARK: - ViewModel
    struct ViewModel {
        let title: String
        let isEmergency: Bool
        let imageURL: String?

        let goalAmount: Double
        let raisedAmount: Double
        let daysLeftText: String

        let overviewText: String

        // النص بالضبط (حتى الفواصل)
        let quoteText: String
        let quoteAuthor: String

        let orgName: String
        let orgAbout: String
    }

    // MARK: - Public
    private var model: ViewModel

    // ✅ init حق الكود
    init(model: ViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    // ✅ لو انفتح بالغلط من storyboard ما يطيح
    required init?(coder: NSCoder) {
        self.model = ViewModel(
            title: "Campaign",
            isEmergency: false,
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
        super.init(coder: coder)
    }

    // MARK: - Colors
    private let brandYellow = UIColor(atayaHexSafe: "#F7D44C")
    private let borderGray  = UIColor(atayaHexSafe: "#E6E6E6")
    private let cardCream   = UIColor(atayaHexSafe: "#FFF7E6")

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Hero
    private let heroImageView = UIImageView()
    private let emergencyPill = UILabel()

    private let heroOverlay = UIView()
    private let heroTitleLabel = UILabel()

    // ✅ Progress (custom مثل الصورة)
    private let progressTrack = UIView()
    private let progressFill  = UIView()
    private var progressWidthC: NSLayoutConstraint?
    private var pendingProgress: CGFloat?

    private let progressInfoRow = UIStackView()
    private let leftAmountLabel = UILabel()
    private let rightPercentLabel = UILabel()

    private let heroGradient = CAGradientLayer()

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

        // gradient frame
        heroGradient.frame = heroOverlay.bounds

        // لو progress انحسب قبل layout
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

    // MARK: - Hero (✅ Full width + title/progress فوق الصورة)
    private func setupHero() {
        heroImageView.backgroundColor = UIColor(atayaHexSafe: "#F2F2F7")
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroImageView.image = UIImage(systemName: "photo")

        contentView.addSubview(heroImageView)
        heroImageView.translatesAutoresizingMaskIntoConstraints = false

        // Emergency pill
        emergencyPill.text = "Emergency"
        emergencyPill.font = .systemFont(ofSize: 12, weight: .semibold)
        emergencyPill.textColor = .white
        emergencyPill.backgroundColor = UIColor.systemRed.withAlphaComponent(0.88)
        emergencyPill.textAlignment = .center
        emergencyPill.layer.cornerRadius = 8
        emergencyPill.layer.masksToBounds = true
        emergencyPill.isHidden = true

        heroImageView.addSubview(emergencyPill)
        emergencyPill.translatesAutoresizingMaskIntoConstraints = false

        // Overlay (للتايتل والبروجريس)
        heroOverlay.backgroundColor = .clear
        heroImageView.addSubview(heroOverlay)
        heroOverlay.translatesAutoresizingMaskIntoConstraints = false

        // Gradient (يخلي النص واضح)
        heroGradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.55).cgColor
        ]
        heroGradient.locations = [0.0, 1.0]
        heroOverlay.layer.insertSublayer(heroGradient, at: 0)

        // Title on image
        heroTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        heroTitleLabel.textColor = .white
        heroTitleLabel.numberOfLines = 2
        heroTitleLabel.textAlignment = .left

        // Progress (custom)
        setupProgressBarUI()

        // Labels تحت البار (على الصورة)
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

        [heroTitleLabel, progressTrack, progressInfoRow].forEach {
            heroOverlay.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            // ✅ FULL WIDTH IMAGE
            heroImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroImageView.heightAnchor.constraint(equalTo: heroImageView.widthAnchor, multiplier: 0.75),

            emergencyPill.topAnchor.constraint(equalTo: heroImageView.topAnchor, constant: 12),
            emergencyPill.leadingAnchor.constraint(equalTo: heroImageView.leadingAnchor, constant: 12),
            emergencyPill.widthAnchor.constraint(equalToConstant: 92),
            emergencyPill.heightAnchor.constraint(equalToConstant: 26),

            // Overlay pinned to bottom
            heroOverlay.leadingAnchor.constraint(equalTo: heroImageView.leadingAnchor),
            heroOverlay.trailingAnchor.constraint(equalTo: heroImageView.trailingAnchor),
            heroOverlay.bottomAnchor.constraint(equalTo: heroImageView.bottomAnchor),
            heroOverlay.heightAnchor.constraint(equalToConstant: 150),

            heroTitleLabel.topAnchor.constraint(equalTo: heroOverlay.topAnchor, constant: 18),
            heroTitleLabel.leadingAnchor.constraint(equalTo: heroOverlay.leadingAnchor, constant: 24),
            heroTitleLabel.trailingAnchor.constraint(equalTo: heroOverlay.trailingAnchor, constant: -24),

            // progress مثل الصورة (أوتلاين أبيض)
            progressTrack.topAnchor.constraint(equalTo: heroTitleLabel.bottomAnchor, constant: 10),
            progressTrack.leadingAnchor.constraint(equalTo: heroOverlay.leadingAnchor, constant: 24),
            progressTrack.trailingAnchor.constraint(equalTo: heroOverlay.trailingAnchor, constant: -24),
            progressTrack.heightAnchor.constraint(equalToConstant: 18),

            progressInfoRow.topAnchor.constraint(equalTo: progressTrack.bottomAnchor, constant: 8),
            progressInfoRow.leadingAnchor.constraint(equalTo: heroOverlay.leadingAnchor, constant: 24),
            progressInfoRow.trailingAnchor.constraint(equalTo: heroOverlay.trailingAnchor, constant: -24),
        ])
    }

    // MARK: - Custom Progress UI (مثل الصورة)
    private func setupProgressBarUI() {
        let trackH: CGFloat = 18
        let padding: CGFloat = 2

        progressTrack.backgroundColor = .clear
        progressTrack.layer.borderWidth = 1
        progressTrack.layer.borderColor = UIColor.white.withAlphaComponent(0.65).cgColor
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

        let usableWidth = progressTrack.bounds.width - 4 // padding*2
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

        // Stats row (3 items)
        statsRow.axis = .horizontal
        statsRow.spacing = 14
        statsRow.distribution = .fillEqually
        statsRow.alignment = .center

        // Overview
        overviewTitle.text = "Campaign Overview"
        overviewTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        overviewTitle.textColor = .label

        overviewBody.font = .systemFont(ofSize: 14.5, weight: .regular)
        overviewBody.textColor = .label
        overviewBody.numberOfLines = 0
        overviewBody.textAlignment = .left  // ✅ يسار

        // Quote Card
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
        quoteAuthorLabel.textAlignment = .center

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
            quoteAuthorLabel.centerXAnchor.constraint(equalTo: quoteCard.centerXAnchor),
            quoteAuthorLabel.bottomAnchor.constraint(equalTo: quoteCard.bottomAnchor, constant: -18)
        ])

        // About
        aboutTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        aboutTitle.textColor = .label

        aboutBody.font = .systemFont(ofSize: 14.5, weight: .regular)
        aboutBody.textColor = .label
        aboutBody.numberOfLines = 0
        aboutBody.textAlignment = .left // ✅ يسار

        // Wrap under hero
        let wrap = UIView()
        contentView.addSubview(wrap)
        wrap.translatesAutoresizingMaskIntoConstraints = false

        [statsRow, overviewTitle, overviewBody, quoteCard, aboutTitle, aboutBody].forEach {
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
            aboutBody.bottomAnchor.constraint(equalTo: wrap.bottomAnchor)
        ])
    }

    // MARK: - Apply Model
    private func applyModel() {
        title = model.title
        heroTitleLabel.text = model.title

        emergencyPill.isHidden = !model.isEmergency

        // Progress
        let p = (model.goalAmount <= 0) ? 0 : (model.raisedAmount / model.goalAmount)
        setProgress(p, animated: false)

        leftAmountLabel.text = "\(money(model.raisedAmount)) of \(money(model.goalAmount)) $"
        rightPercentLabel.text = "\(Int(max(0, min(1, p)) * 100)) %"

        // Stats
        statsRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        statsRow.addArrangedSubview(statItem(icon: "heart.fill", title: "Goal",  value: "\(money(model.goalAmount)) $"))
        statsRow.addArrangedSubview(statItem(icon: "moon.fill",  title: "Raised", value: "\(money(model.raisedAmount)) $"))
        statsRow.addArrangedSubview(statItem(icon: "calendar",   title: "Days",  value: model.daysLeftText))

        // Overview
        overviewBody.text = model.overviewText

        // Quote EXACT
        quoteLabel.text = model.quoteText
        quoteAuthorLabel.text = model.quoteAuthor

        // About
        aboutTitle.text = "About \(model.orgName)"
        aboutBody.text = model.orgAbout

        loadHeroImage(urlString: model.imageURL)
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

        // ✅ مثل الصورة: icon فوق، بعدين title، بعدين value
        let stack = UIStackView(arrangedSubviews: [iconView, titleLbl, valueLbl])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6

        v.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: v.topAnchor),
            stack.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: v.bottomAnchor),

            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18)
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
}

// MARK: - Safe Hex (نفس اللي عندج)
private extension UIColor {
    convenience init(atayaHexSafe hex: String, alpha: CGFloat = 1.0) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }

        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)

        let r, g, b: CGFloat
        if s.count == 6 {
            r = CGFloat((value & 0xFF0000) >> 16) / 255.0
            g = CGFloat((value & 0x00FF00) >> 8)  / 255.0
            b = CGFloat(value & 0x0000FF) / 255.0
        } else if s.count == 8 {
            r = CGFloat((value & 0x00FF0000) >> 16) / 255.0
            g = CGFloat((value & 0x0000FF00) >> 8)  / 255.0
            b = CGFloat(value & 0x000000FF) / 255.0
        } else {
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
