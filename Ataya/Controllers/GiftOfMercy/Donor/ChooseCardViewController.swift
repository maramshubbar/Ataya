//
//  ChooseCardViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//


import UIKit

final class ChooseCardViewController: UIViewController {

    // MARK: - Models
    struct CardItem {
        let id: String            // e.g. "c1"
        let imageName: String     // asset name
        let title: String         // display name
    }

    // MARK: - Inputs (set from previous screen)
    var giftNameText: String?

    // ✅ coming from GiftsChooseViewController (backend gifts)
    var selectedGift: MercyGift?
    var selectedAmount: Decimal = 0

    // optional callback
    var onSelectCard: ((CardItem) -> Void)?

    // MARK: - Theme
    private let accent = UIColor(atayaHex: "00A85C")
    private let brandYellow = UIColor(atayaHex: "F7D44C")

    // MARK: - UI
    private var collectionView: UICollectionView!

    private let bannerView = UIView()
    private let bannerIcon = UIImageView()
    private let bannerLabel = UILabel()

    // MARK: - Data
    private let items: [CardItem] = [
        .init(id: "c1", imageName: "c1", title: "Kaaba"),
        .init(id: "c2", imageName: "c2", title: "Palestine Al Aqsa"),
        .init(id: "c3", imageName: "c3", title: "Floral"),
        .init(id: "c4", imageName: "c4", title: "Water")
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .black
    }

    // MARK: - Setup
    private func setupNav() {
        title = "Step 2: Choose a card"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
    }

    private func setupUI() {
        // Banner
        bannerView.backgroundColor = accent.withAlphaComponent(0.16)
        bannerView.layer.cornerRadius = 14
        bannerView.clipsToBounds = true

        bannerIcon.image = UIImage(systemName: "exclamationmark.circle.fill")
        bannerIcon.tintColor = accent
        bannerIcon.contentMode = .scaleAspectFit

        bannerLabel.text = "Please note: The donation amount is not shown on the certificate."
        bannerLabel.numberOfLines = 0
        bannerLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        bannerLabel.textColor = .label

        bannerView.addSubview(bannerIcon)
        bannerView.addSubview(bannerLabel)
        view.addSubview(bannerView)

        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerIcon.translatesAutoresizingMaskIntoConstraints = false
        bannerLabel.translatesAutoresizingMaskIntoConstraints = false

        // Collection
        let layout = makeTwoColumnLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true

        collectionView.register(CardChoiceCell.self, forCellWithReuseIdentifier: CardChoiceCell.reuseID)
        collectionView.dataSource = self
        collectionView.delegate = self

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func makeTwoColumnLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 16

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(340)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 24, trailing: 16)

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            bannerIcon.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor, constant: 14),
            bannerIcon.topAnchor.constraint(equalTo: bannerView.topAnchor, constant: 14),
            bannerIcon.widthAnchor.constraint(equalToConstant: 22),
            bannerIcon.heightAnchor.constraint(equalToConstant: 22),

            bannerLabel.leadingAnchor.constraint(equalTo: bannerIcon.trailingAnchor, constant: 12),
            bannerLabel.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor, constant: -14),
            bannerLabel.topAnchor.constraint(equalTo: bannerView.topAnchor, constant: 12),
            bannerLabel.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: -12),

            collectionView.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 14),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Actions
    private func openPreview(for item: CardItem) {
        let vc = CardPreviewViewController()
        vc.image = loadImage(named: item.imageName)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }

    private func chooseCard(_ item: CardItem) {
        onSelectCard?(item)

        let vc = GiftCertificateDetailsViewController()

        vc.giftNameText = giftNameText
        vc.cardDesignText = item.title
        vc.selectedCardDesignId = item.id
        vc.bottomPreviewImage = loadImage(named: item.imageName)

        // ✅ pass gift + amount for backend submit
        vc.selectedGift = selectedGift
        vc.selectedAmount = selectedAmount

        navigationController?.pushViewController(vc, animated: true)
    }



    private func loadImage(named name: String) -> UIImage? {
        if let img = UIImage(named: name) { return img }
        return UIImage(named: "\(name).jpeg") ?? UIImage(named: "\(name).jpg") ?? UIImage(named: "\(name).png")
    }
}

// MARK: - DataSource
extension ChooseCardViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CardChoiceCell.reuseID,
            for: indexPath
        ) as? CardChoiceCell else {
            return UICollectionViewCell()
        }

        let item = items[indexPath.item]
        let img = loadImage(named: item.imageName)

        cell.configure(image: img, accent: brandYellow)

        cell.onZoomTapped = { [weak self] in
            self?.openPreview(for: item)
        }

        cell.onChooseTapped = { [weak self] in
            self?.chooseCard(item)
        }

        return cell
    }
}

// MARK: - Delegate
extension ChooseCardViewController: UICollectionViewDelegate { }
