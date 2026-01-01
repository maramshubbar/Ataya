//
//  ChooseCardViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//

import UIKit
import FirebaseFirestore

final class ChooseCardViewController: UIViewController {

    // MARK: - ViewModel
    struct CardItem {
        let id: String
        let title: String
        let imageURL: String?
    }

    // MARK: - Inputs (set from previous screen)
    var giftNameText: String?

    var selectedGift: MercyGift?
    var selectedAmount: Decimal = 0

    var onSelectCard: ((CardItem) -> Void)?

    // MARK: - Theme
    private let accent = UIColor(atayaHex: "00A85C")
    private let brandYellow = UIColor(atayaHex: "F7D44C")

    // MARK: - UI
    private var collectionView: UICollectionView!

    private let bannerView = UIView()
    private let bannerIcon = UIImageView()
    private let bannerLabel = UILabel()

    private let emptyLabel = UILabel()

    // MARK: - Data (from Firestore)
    private var items: [CardItem] = []
    private var cardsListener: ListenerRegistration?

    deinit { cardsListener?.remove() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        setupConstraints()
        listenCards()
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

        // Empty label (when no cards)
        emptyLabel.text = "No card designs available."
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

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
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
        ])
    }

    // MARK: - Firestore
    private func listenCards() {
        cardsListener?.remove()

        cardsListener = MercyBackend.listenActiveCardDesigns { [weak self] result in
            guard let self else { return }

            switch result {
            case .failure(let err):
                print("❌ listenActiveCardDesigns error:", err)
                DispatchQueue.main.async {
                    self.items = []
                    self.collectionView.reloadData()
                    self.emptyLabel.isHidden = false
                }

            case .success(let list):
                let mapped = list.map { CardItem(id: $0.id, title: $0.title, imageURL: $0.imageURL) }

                DispatchQueue.main.async {
                    self.items = mapped
                    self.collectionView.reloadData()
                    self.emptyLabel.isHidden = !mapped.isEmpty
                }
            }
        }
    }

    // MARK: - Actions
    private func openPreview(for item: CardItem) {
        let vc = CardPreviewViewController()
        vc.imageURL = item.imageURL
        vc.image = placeholderImage(for: item.id) // optional
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }

    private func chooseCard(_ item: CardItem) {
        onSelectCard?(item)

        let vc = GiftCertificateDetailsViewController()
        vc.giftNameText = giftNameText
        vc.cardDesignText = item.title
        vc.selectedCardDesignId = item.id

        // ✅ IMPORTANT: pass URL to details
        vc.selectedCardDesignImageURL = item.imageURL

        // optional quick placeholder
        vc.bottomPreviewImage = placeholderImage(for: item.id)

        vc.selectedGift = selectedGift
        vc.selectedAmount = selectedAmount

        navigationController?.pushViewController(vc, animated: true)
    }

    private func placeholderImage(for id: String) -> UIImage? {
        UIImage(named: id) ?? UIImage(named: "\(id).jpg") ?? UIImage(named: "\(id).png")
    }
}

// MARK: - DataSource
extension ChooseCardViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CardChoiceCell.reuseID,
            for: indexPath
        ) as? CardChoiceCell else {
            return UICollectionViewCell()
        }

        let item = items[indexPath.item]
        let placeholder = placeholderImage(for: item.id)

        // ✅ one call فقط
        cell.configure(imageURL: item.imageURL, accent: brandYellow, placeholder: placeholder)

        cell.onZoomTapped = { [weak self] in
            self?.openPreview(for: item)
        }

        cell.onChooseTapped = { [weak self] in
            self?.chooseCard(item)
        }

        return cell
    }
}

extension ChooseCardViewController: UICollectionViewDelegate { }
