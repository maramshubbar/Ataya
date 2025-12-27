//
//  CampaignDetailViewController.swift
//  Ataya
//
//  Created by Maram on 25/12/2025.
//

import UIKit

// MARK: - Category (from Firestore field: "category")
enum Category: Equatable {
    case climateChange
    case emergency
    case critical
    case unknown(String)

    init(from raw: String?) {
        let s = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = s.lowercased()

        if lower == "emergency" { self = .emergency; return }
        if lower == "critical" { self = .critical; return }
        if lower == "climate change" || lower == "climatechange" { self = .climateChange; return }

        self = s.isEmpty ? .unknown("") : .unknown(s)
    }

    var titleText: String {
        switch self {
        case .climateChange: return "Climate change"
        case .emergency:     return "Emergency"
        case .critical:      return "Critical"
        case .unknown(let s): return s
        }
    }

    var shouldShow: Bool {
        switch self {
        case .unknown(let s): return !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default: return true
        }
    }

    var pillColor: UIColor {
        switch self {
        case .emergency:     return UIColor.systemRed.withAlphaComponent(0.88)
        case .critical:      return UIColor.systemOrange.withAlphaComponent(0.88)
        case .climateChange: return UIColor.systemBlue.withAlphaComponent(0.85)
        case .unknown:       return UIColor.clear
        }
    }
}

// MARK: - Label with padding (badge look)
final class PaddedLabel: UILabel {
    var insets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + insets.left + insets.right,
                      height: s.height + insets.top + insets.bottom)
    }
}

final class CampaignDetailViewController: UIViewController {

    // MARK: - ViewModel
    struct ViewModel {
        let title: String
        let category: Category
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

    init(model: ViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.model = ViewModel(
            title: "Campaign",
            category: .unknown(""),
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
    private let brandYellow = UIColor(hex: "F7D44C")
    private let borderGray  = UIColor(hex: "E6E6E6")
    private let cardCream   = UIColor(hex: "FFF7E6")

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Hero
    private let heroImageView = UIImageView()

    // ✅ Status badge فوق يسار (لاصق + مربع)
    private let statusPill = PaddedLabel()

    private let heroOverlay = UIView()   // للعنوان + gradient
    private let heroTitleLabel = UILabel()
    private let heroGradient = CAGradientLayer()

    // Progress (تحت داخل الصورة)
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
        heroImageView.backgroundColor = UIColor(hex: "F2F2F7")
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroImageView.image = UIImage(systemName: "photo")

        contentView.addSubview(heroImageView)
        heroImageView.translatesAutoresizingMaskIntoConstraints = false

        // ✅ Status pill (لاصق فوق يسار + مربع)
        statusPill.font = .systemFont(ofSize: 13, weight: .semibold)
        statusPill.textColor = .white
        statusPill.textAlignment = .left
        statusPill.layer.cornerRadius = 0
        statusPill.layer.masksToBounds = true
        statusPill.isHidden = true

        heroImageView.addSubview(statusPill)
        statusPill.translatesAutoresizingMaskIntoConstraints = false

        // Overlay + gradient
        heroOverlay.backgroundColor = .clear
        heroImageView.addSubview(heroOverlay)
        heroOverlay.translatesAutoresizingMaskIntoConstraints = false

        heroGradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.55).cgColor
        ]
        heroGradient.locations = [0.0, 1.0]
        heroOverlay.layer.insertSublayer(heroGradient, at: 0)

        // Title
        heroTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        heroTitleLabel.textColor = .white
        heroTitleLabel.numberOfLines = 2
        heroTitleLabel.textAlignment = .left
        heroOverlay.addSubview(heroTitleLabel)
        heroTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Progress
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

            // ✅ status top-left stuck
            statusPill.topAnchor.constraint(equalTo: heroImageView.topAnchor, constant: 0),
            statusPill.leadingAnchor.constraint(equalTo: heroImageView.leadingAnchor, constant: 0),
            statusPill.heightAnchor.constraint(equalToConstant: 32),

            // overlay bottom
            heroOverlay.leadingAnchor.constraint(equalTo: heroImageView.leadingAnchor),
            heroOverlay.trailingAnchor.constraint(equalTo: heroImageView.trailingAnchor),
            heroOverlay.bottomAnchor.constraint(equalTo: heroImageView.bottomAnchor),
            heroOverlay.heightAnchor.constraint(equalToConstant: 170),

            // ✅ progress + info row near bottom (inside image)
            progressInfoRow.bottomAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: -18),
            progressInfoRow.leadingAnchor.constraint(equalTo: heroImageView.leadingAnchor, constant: 24),
            progressInfoRow.trailingAnchor.constraint(equalTo: heroImageView.trailingAnchor, constant: -24),

            progressTrack.bottomAnchor.constraint(equalTo: progressInfoRow.topAnchor, constant: -8),
            progressTrack.leadingAnchor.constraint(equalTo: heroImageView.leadingAnchor, constant: 24),
            progressTrack.trailingAnchor.constraint(equalTo: heroImageView.trailingAnchor, constant: -24),
            progressTrack.heightAnchor.constraint(equalToConstant: 28),

            // ✅ title فوق progress
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

        aboutTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        aboutTitle.textColor = .label

        aboutBody.font = .systemFont(ofSize: 14.5, weight: .regular)
        aboutBody.textColor = .label
        aboutBody.numberOfLines = 0
        aboutBody.textAlignment = .left

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
            aboutBody.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -6)
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
//        statsRow.addArrangedSubview(statItem(icon: "heart.fill", title: "Goal",  value: "\(money(model.goalAmount)) $"))
//        statsRow.addArrangedSubview(statItem(icon: "moon.fill",  title: "Raised", value: "\(money(model.raisedAmount)) $"))
//        statsRow.addArrangedSubview(statItem(icon: "calendar",   title: "Days",  value: model.daysLeftText))
//        
        
        statsRow.addArrangedSubview(statItem(icon: "target", title: "Goal",  value: "\(money(model.goalAmount)) $"))
        statsRow.addArrangedSubview(statItem(icon: "chart.line.uptrend.xyaxis", title: "Raised", value: "\(money(model.raisedAmount)) $"))
        statsRow.addArrangedSubview(statItem(icon: "clock", title: "Days",  value: model.daysLeftText))


        overviewBody.text = model.overviewText

        quoteLabel.text = model.quoteText
        quoteAuthorLabel.text = model.quoteAuthor

        aboutTitle.text = "About \(model.orgName)"
        aboutBody.text = model.orgAbout

        loadHeroImage(urlString: model.imageURL)
    }

    private func applyCategoryPill(_ category: Category) {
        guard category.shouldShow else {
            statusPill.isHidden = true
            return
        }
        statusPill.isHidden = false
        statusPill.text = category.titleText
        statusPill.backgroundColor = category.pillColor
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

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: v.topAnchor),
            stack.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: v.bottomAnchor),

            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 30)
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
