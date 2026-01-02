//
//  CreateCampaignViewController.swift
//  Ataya
//
//  Created by Maram on 24/12/2025.
//

import UIKit
import FirebaseFirestore

final class CampaignManagementViewController: UIViewController {

    // MARK: UI
    private let createButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: Backend
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // MARK: Data
    private var campaigns: [CampaignItem] = []

    // MARK: Colors
    private let brandYellow = AppColors.brandYellow
    private let borderGray  = AppColors.borderGray


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Campaign Management"
        navigationItem.largeTitleDisplayMode = .never

        setupCreateButton()
        setupTableView()
        layoutUI()

        updateEmptyState()
        startListeningCampaigns()
    }

    deinit { listener?.remove() }

    private func openScreen(_ vc: UIViewController) {
        DispatchQueue.main.async {
            vc.hidesBottomBarWhenPushed = true

            if let nav = self.navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        }
    }

    // MARK: Create Button
    private func setupCreateButton() {
        createButton.setTitle("Create Campaign", for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        createButton.setTitleColor(.label, for: .normal)
        createButton.backgroundColor = brandYellow
        createButton.layer.cornerRadius = 8
        createButton.layer.masksToBounds = true
        createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)

        view.addSubview(createButton)
        createButton.translatesAutoresizingMaskIntoConstraints = false
    }

    @objc private func didTapCreate() {
        let vc = CreateCampaignViewController()
        vc.mode = .create
        openScreen(vc)
    }

    // MARK: Table
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 22, right: 0)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CampaignCell.self, forCellReuseIdentifier: CampaignCell.reuseId)

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: Layout
    private func layoutUI() {
        NSLayoutConstraint.activate([
            createButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createButton.widthAnchor.constraint(equalToConstant: 362),
            createButton.heightAnchor.constraint(equalToConstant: 54),

            tableView.topAnchor.constraint(equalTo: createButton.bottomAnchor, constant: 14),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.bringSubviewToFront(createButton)
    }

    // MARK: Empty State
    private func updateEmptyState() {
        if campaigns.isEmpty {
            let wrap = UIView()
            wrap.backgroundColor = .clear

            let label = UILabel()
            label.text = "No campaigns yet.\nTap Create Campaign to add one."
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = .secondaryLabel
            label.font = .systemFont(ofSize: 15, weight: .regular)

            wrap.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: wrap.centerYAnchor),
                label.leadingAnchor.constraint(greaterThanOrEqualTo: wrap.leadingAnchor, constant: 24),
                label.trailingAnchor.constraint(lessThanOrEqualTo: wrap.trailingAnchor, constant: -24),
            ])

            tableView.backgroundView = wrap
        } else {
            tableView.backgroundView = nil
        }
    }

    // MARK: Backend - Listen
    private func startListeningCampaigns() {
        listener?.remove()

        listener = db.collection("campaigns")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let self = self else { return }
                if let err = err {
                    print("❌ Firestore listen error:", err)
                    return
                }
                guard let docs = snap?.documents else { return }

                self.campaigns = docs.map { doc in
                    let d = doc.data()

                    let title = self.readString(d["title"]) ?? "—"
                    let categoryRaw = (self.readString(d["category"]) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

                    let location = self.readString(d["location"]) ?? "—"
                    let overview = self.readString(d["overview"]) ?? "—"
                    let story = self.readString(d["story"]) ?? ""
                    let from = self.readString(d["from"]) ?? ""
                    let organization = self.readString(d["organization"]) ?? "LifeReach"
                    let showOnHome = self.readBool(d["showOnHome"])

                    let goalAmount = self.readDouble(d["goalAmount"])
                    let raisedAmount = self.readDouble(d["raisedAmount"])

                    let startDate = self.readDate(d["startDate"]) ?? Date()
                    let endDate = self.readDate(d["endDate"]) ?? Date()

                    let imageUrl = self.readString(d["imageUrl"]) ?? self.readString(d["imageURL"])
                    let imagePublicId = self.readString(d["imagePublicId"])

                    return CampaignItem(
                        id: doc.documentID,
                        title: title,
                        categoryRaw: categoryRaw,
                        goalAmount: goalAmount,
                        raisedAmount: raisedAmount,
                        startDate: startDate,
                        endDate: endDate,
                        location: location,
                        overview: overview,
                        story: story,
                        from: from,
                        organization: organization,
                        showOnHome: showOnHome,
                        imageUrl: imageUrl,
                        imagePublicId: imagePublicId
                    )
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateEmptyState()
                }
            }
    }

    // MARK: Helpers
    private func money(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }

    private func readString(_ any: Any?) -> String? { any as? String }

    private func readDouble(_ any: Any?) -> Double {
        if let d = any as? Double { return d }
        if let i = any as? Int { return Double(i) }
        if let n = any as? NSNumber { return n.doubleValue }
        return 0
    }

    private func readBool(_ any: Any?) -> Bool {
        if let b = any as? Bool { return b }
        if let n = any as? NSNumber { return n.boolValue }
        return false
    }

    private func readDate(_ any: Any?) -> Date? {
        if let ts = any as? Timestamp { return ts.dateValue() }
        if let d = any as? Date { return d }
        return nil
    }
}

// MARK: - UITableView
extension CampaignManagementViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        campaigns.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: CampaignCell.reuseId, for: indexPath) as! CampaignCell
        let item = campaigns[indexPath.row]

        let raisedText = "\(money(item.raisedAmount)) of \(money(item.goalAmount)) $"
        cell.configure(
            title: item.title,
            raised: raisedText,
            location: item.location,
            desc: item.overview,
            imageURL: item.imageUrl
        )

        // ✅ EDIT
        cell.onEdit = { [weak self] in
            guard let self = self else { return }

            let vc = CreateCampaignViewController()

            let existing = CreateCampaignViewController.CampaignFormData(
                title: item.title,
                category: item.categoryRaw,
                goalAmount: "\(self.money(item.goalAmount)) $",
                startDate: item.startDate,
                endDate: item.endDate,
                location: item.location,
                overview: item.overview,
                story: item.story,
                from: item.from,
                organization: item.organization,
                showOnHome: item.showOnHome,
                image: nil
            )

            vc.mode = .edit(existing: existing)
            vc.editingDocumentId = item.id
            vc.editingExistingImageUrl = item.imageUrl
            vc.editingExistingPublicId = item.imagePublicId

            self.openScreen(vc)
        }

        // ✅ VIEW -> CampaignDetailViewController
        cell.onView = { [weak self] in
            guard let self = self else { return }

            let days = Calendar.current.dateComponents([.day], from: Date(), to: item.endDate).day ?? 0
            let daysText = "\(max(days, 0)) days Left"

            let vm = CampaignDetailViewController.ViewModel(
                title: item.title,
                category: Category(from: item.categoryRaw),
                imageURL: item.imageUrl,
                goalAmount: item.goalAmount,
                raisedAmount: item.raisedAmount,
                daysLeftText: daysText,
                overviewText: item.overview,
                quoteText: item.story,
                quoteAuthor: item.from.isEmpty ? "—" : item.from,
                orgName: item.organization,
                orgAbout: "LifeReach is a humanitarian organization dedicated to helping families in crisis rebuild their lives with dignity. We deliver urgent medical aid, food, water, and long-term recovery support to those affected by conflict and disaster. Guided by compassion and transparency, we work to restore hope where it’s needed most."
            )

            let detailVC = CampaignDetailViewController(model: vm)
            self.openScreen(detailVC)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 220 }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { UITableView.automaticDimension }
}

// MARK: - Model
private struct CampaignItem {
    let id: String
    let title: String
    let categoryRaw: String
    let goalAmount: Double
    let raisedAmount: Double
    let startDate: Date
    let endDate: Date
    let location: String
    let overview: String
    let story: String
    let from: String
    let organization: String
    let showOnHome: Bool
    let imageUrl: String?
    let imagePublicId: String?
}

// MARK: - Cell
private final class CampaignCell: UITableViewCell {

    static let reuseId = "CampaignCell"

    var onEdit: (() -> Void)?
    var onView: (() -> Void)?

    private let brandYellow = AppColors.brandYellow
    private let borderGray  = AppColors.borderGray
    private let thumbBG     = AppColors.thumbBG
    private let editText    = AppColors.editText


    private let cardView = UIView()

    private let thumb = UIImageView()
    private var imageTask: URLSessionDataTask?

    private let titleLabel = UILabel()
    private let raisedLabel = UILabel()

    private let pinIcon = UIImageView()
    private let locationLabel = UILabel()

    private let descLabel = UILabel()

    private let editButton = UIButton(type: .system)
    private let viewButton = UIButton(type: .system)

    private var topRow: UIStackView!
    private var buttonsRow: UIStackView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        setupCard()
        setupTopRow()
        setupDesc()
        setupButtons()
        layoutAll()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        thumb.image = UIImage(systemName: "photo")
    }

    private func setupCard() {
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 10
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = borderGray.cgColor
        cardView.layer.masksToBounds = true

        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupTopRow() {
        thumb.backgroundColor = thumbBG
        thumb.layer.cornerRadius = 0
        thumb.layer.masksToBounds = true
        thumb.contentMode = .scaleAspectFill
        thumb.image = UIImage(systemName: "photo")

        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2

        raisedLabel.font = .systemFont(ofSize: 13, weight: .regular)
        raisedLabel.textColor = .secondaryLabel

        pinIcon.image = UIImage(systemName: "mappin.and.ellipse")
        pinIcon.tintColor = .secondaryLabel
        pinIcon.contentMode = .scaleAspectFit

        locationLabel.font = .systemFont(ofSize: 13, weight: .regular)
        locationLabel.textColor = .secondaryLabel
        locationLabel.numberOfLines = 1

        let locRow = UIStackView(arrangedSubviews: [pinIcon, locationLabel])
        locRow.axis = .horizontal
        locRow.spacing = 6
        locRow.alignment = .center

        let infoStack = UIStackView(arrangedSubviews: [titleLabel, raisedLabel, locRow])
        infoStack.axis = .vertical
        infoStack.spacing = 4
        infoStack.alignment = .fill

        topRow = UIStackView(arrangedSubviews: [thumb, infoStack])
        topRow.axis = .horizontal
        topRow.spacing = 12
        topRow.alignment = .top

        cardView.addSubview(topRow)
        topRow.translatesAutoresizingMaskIntoConstraints = false

        pinIcon.translatesAutoresizingMaskIntoConstraints = false
        thumb.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumb.widthAnchor.constraint(equalToConstant: 90),
            thumb.heightAnchor.constraint(equalToConstant: 90),
            pinIcon.widthAnchor.constraint(equalToConstant: 14),
            pinIcon.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    private func setupDesc() {
        descLabel.font = .systemFont(ofSize: 15, weight: .regular)
        descLabel.textColor = .label
        descLabel.numberOfLines = 0
        cardView.addSubview(descLabel)
        descLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupButtons() {
        editButton.setTitle("Edit", for: .normal)
        editButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        editButton.setTitleColor(editText, for: .normal)
        editButton.backgroundColor = .white
        editButton.layer.cornerRadius = 4.6
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = brandYellow.cgColor
        editButton.addTarget(self, action: #selector(tapEdit), for: .touchUpInside)

        viewButton.setTitle("View", for: .normal)
        viewButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        viewButton.setTitleColor(.label, for: .normal)
        viewButton.backgroundColor = brandYellow
        viewButton.layer.cornerRadius = 4.6
        viewButton.layer.masksToBounds = true
        viewButton.addTarget(self, action: #selector(tapView), for: .touchUpInside)

        buttonsRow = UIStackView(arrangedSubviews: [editButton, viewButton])
        buttonsRow.axis = .horizontal
        buttonsRow.spacing = 14
        buttonsRow.distribution = .fillEqually

        cardView.addSubview(buttonsRow)
        buttonsRow.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            buttonsRow.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func layoutAll() {
        let preferredW = cardView.widthAnchor.constraint(equalToConstant: 362)
        preferredW.priority = .defaultHigh
        let maxW = cardView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, constant: -32)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            preferredW,
            maxW,
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            topRow.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            topRow.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            topRow.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            descLabel.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 12),
            descLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            buttonsRow.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 14),
            buttonsRow.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            buttonsRow.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            buttonsRow.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
        ])
    }

    func configure(title: String, raised: String, location: String, desc: String, imageURL: String?) {
        titleLabel.text = title
        raisedLabel.text = raised
        locationLabel.text = location
        descLabel.text = desc

        thumb.image = UIImage(systemName: "photo")
        imageTask?.cancel()
        imageTask = nil

        guard let s = imageURL, let url = URL(string: s) else { return }
        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.thumb.image = img }
        }
        imageTask?.resume()
    }

    @objc private func tapEdit() { onEdit?() }
    @objc private func tapView() { onView?() }
}
