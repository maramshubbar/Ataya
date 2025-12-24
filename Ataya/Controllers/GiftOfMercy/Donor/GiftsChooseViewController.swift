//
//  GiftsChooseViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 24/12/2025.
//


import UIKit

final class GiftsChooseViewController: UIViewController {

    // MARK: - Model
    struct GiftItem {
        enum Pricing {
            case fixed(amount: Decimal)
            case custom
        }

        let title: String
        let imageName: String
        let pricing: Pricing
        let description: String

        var requiresAmount: Bool {
            if case .custom = pricing { return true }
            return false
        }
    }

    // MARK: - UI
    private var collectionView: UICollectionView!

    private let errorBanner = UIView()
    private let errorLabel = UILabel()
    private var errorBottomConstraint: NSLayoutConstraint?

    // MARK: - Data
    private let accent = UIColor(atayaHex: "#F7D44C")
    private var items: [GiftItem] = []

    private var enteredAmounts: [Int: Decimal] = [:]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupData()
        setupUI()
        setupErrorBanner()
        setupConstraints()
        addDismissKeyboardTap()
    }

    // MARK: - Setup
    private func setupNav() {
        title = "Step 1: Choose a gift"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .black
    }

    private func setupData() {
        items = [
            GiftItem(
                title: "WATER WELL",
                imageName: "water_well_heart",
                pricing: .fixed(amount: 500),
                description: "Provide clean water\nto impoverished\ncommunities"
            ),
            GiftItem(
                title: "Restore Eyesight\nin Africa",
                imageName: "heart_restore_eyesight",
                pricing: .custom,
                description: "Help bring joy to\nthose who cannot\nsee"
            ),
            GiftItem(
                title: "SADAQAH\nJARIYA",
                imageName: "heart_sadaqah",
                pricing: .custom,
                description: "Benefit from the\nongoing rewards of\ncontinuous charity"
            ),
            GiftItem(
                title: "Orphan Care",
                imageName: "heart_orphan_care",
                pricing: .custom,
                description: "Give orphans in need\na brighter future"
            )
        ]
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let layout = makeTwoColumnLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag

        collectionView.register(GiftCardCell.self, forCellWithReuseIdentifier: GiftCardCell.reuseID)
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
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(400)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item, item]
        )
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 18,
            leading: 16,
            bottom: 24,
            trailing: 16
        )

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func setupErrorBanner() {
        errorBanner.backgroundColor = accent.withAlphaComponent(0.22)
        errorBanner.layer.cornerRadius = 14
        errorBanner.clipsToBounds = true
        errorBanner.isHidden = true

        errorLabel.text = "Enter a valid amount!"
        errorLabel.textColor = .label
        errorLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        errorLabel.textAlignment = .center

        errorBanner.addSubview(errorLabel)
        view.addSubview(errorBanner)

        errorBanner.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: errorBanner.topAnchor, constant: 12),
            errorLabel.bottomAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: -12),
            errorLabel.leadingAnchor.constraint(equalTo: errorBanner.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: errorBanner.trailingAnchor, constant: -16),
        ])
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        errorBottomConstraint = errorBanner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 90)

        NSLayoutConstraint.activate([
            errorBanner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorBanner.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -32),
            errorBottomConstraint!,
        ])
    }

    private func addDismissKeyboardTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Validation + Actions
    private func validateAmount(for index: Int) -> Bool {
        guard items.indices.contains(index) else { return false }

        switch items[index].pricing {
        case .fixed:
            return true
        case .custom:
            guard let amount = enteredAmounts[index], amount > 0 else { return false }
            return true
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .black
    }

    private func showErrorBanner() {
        errorBanner.isHidden = false
        errorBottomConstraint?.constant = -18
        errorBanner.alpha = 0
        errorBanner.transform = CGAffineTransform(translationX: 0, y: 20)

        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut]) {
            self.view.layoutIfNeeded()
            self.errorBanner.alpha = 1
            self.errorBanner.transform = .identity
        }

        // Auto hide
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { [weak self] in
            self?.hideErrorBanner()
        }
    }

    private func hideErrorBanner() {
        guard !errorBanner.isHidden else { return }
        errorBottomConstraint?.constant = 90

        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseIn]) {
            self.view.layoutIfNeeded()
            self.errorBanner.alpha = 0
            self.errorBanner.transform = CGAffineTransform(translationX: 0, y: 20)
        } completion: { _ in
            self.errorBanner.isHidden = true
            self.errorBanner.alpha = 1
            self.errorBanner.transform = .identity
        }
    }

    private func didTapChooseGift(at index: Int) {
        dismissKeyboard()

        if validateAmount(for: index) {
             let vc = ChooseCardViewController()
             navigationController?.pushViewController(vc, animated: true)

            print("Proceed with gift:", items[index].title, "amount:", enteredAmounts[index] ?? 0)
        } else {
            showErrorBanner()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension GiftsChooseViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GiftCardCell.reuseID,
            for: indexPath
        ) as? GiftCardCell else {
            return UICollectionViewCell()
        }

        let item = items[indexPath.item]

        let existingAmount = enteredAmounts[indexPath.item]
        cell.configure(
            item: item,
            accent: accent,
            existingAmount: existingAmount
        )

        cell.onAmountChanged = { [weak self] newText in
            guard let self else { return }
            let value = newText.decimalValue()
            if let value, value > 0 {
                self.enteredAmounts[indexPath.item] = value
            } else {
                self.enteredAmounts[indexPath.item] = nil
            }
        }

        cell.onChooseTapped = { [weak self] in
            self?.didTapChooseGift(at: indexPath.item)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate (optional tap to dismiss)
extension GiftsChooseViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
}
