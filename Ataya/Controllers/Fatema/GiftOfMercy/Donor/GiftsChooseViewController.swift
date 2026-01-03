//
//  GiftsChooseViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 24/12/2025.
//

import UIKit
import FirebaseFirestore

final class GiftsChooseViewController: UIViewController {

    // MARK: - UI
    private var collectionView: UICollectionView!

    private let errorBanner = UIView()
    private let errorLabel = UILabel()
    private var errorBottomConstraint: NSLayoutConstraint?

    // MARK: - Data
    private let accent = UIColor(atayaHex: "#F7D44C")
    private var items: [MercyGift] = []

    // amounts keyed by giftId
    private var enteredAmounts: [String: Decimal] = [:]

    private var giftsListener: ListenerRegistration?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        setupErrorBanner()
        setupConstraints()
        addDismissKeyboardTap()
        listenGifts()
    }

    deinit {
        giftsListener?.remove()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .black
    }

    // MARK: - Setup
    private func setupNav() {
        title = "Step 1: Choose a gift"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .black
        view.backgroundColor = .systemBackground
    }

    private func setupUI() {
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

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(400)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 16, bottom: 24, trailing: 16)

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

    // MARK: - Backend
    private func listenGifts() {
        giftsListener?.remove()
        giftsListener = MercyBackend.listenActiveGifts { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let err):
                print("❌ gifts listen error:", err)

            case .success(let items):
                self.items = items
                self.collectionView.reloadData()
            }
        }
    }

    // MARK: - Validation + Actions
    private func validateAmount(for gift: MercyGift) -> (ok: Bool, message: String) {
        switch gift.pricingMode {

        case .fixed:
            // ✅ also protect fixed gifts (just in case)
            let fixed = Decimal(gift.fixedAmount ?? 0)
            if fixed <= 0 { return (false, "Invalid fixed amount.") }
            return (true, "")

        case .custom:
            guard let amount = enteredAmounts[gift.id] else {
                return (false, "Please enter a donation amount.")
            }

            if amount <= 0 {
                return (false, "Amount must be greater than 0.")
            }

            if let min = gift.minAmount, amount < Decimal(min) {
                return (false, "Minimum amount is $\(min).")
            }
            if let max = gift.maxAmount, amount > Decimal(max) {
                return (false, "Maximum amount is $\(max).")
            }

            return (true, "")
        }
    }

    private func showErrorBanner(_ message: String) {
        errorLabel.text = message
        errorBanner.isHidden = false
        errorBottomConstraint?.constant = -18
        errorBanner.alpha = 0
        errorBanner.transform = CGAffineTransform(translationX: 0, y: 20)

        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut]) {
            self.view.layoutIfNeeded()
            self.errorBanner.alpha = 1
            self.errorBanner.transform = .identity
        }

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

    private func didTapChooseGift(_ gift: MercyGift) {
        dismissKeyboard()

        let result = validateAmount(for: gift)
        guard result.ok else {
            showErrorBanner(result.message)
            return
        }

        let amount: Decimal
        switch gift.pricingMode {
        case .fixed:
            amount = Decimal(gift.fixedAmount ?? 0)
        case .custom:
            amount = enteredAmounts[gift.id] ?? 0
        }

        guard amount > 0 else {
            showErrorBanner("Amount must be greater than 0.")
            return
        }

        let vc = ChooseCardViewController()
        vc.selectedGift = gift
        vc.selectedAmount = amount
        vc.giftNameText = certificateGiftText(gift: gift, amount: amount)

        navigationController?.pushViewController(vc, animated: true)
    }

    private func certificateGiftText(gift: MercyGift, amount: Decimal) -> String {
        let title = gift.title.replacingOccurrences(of: "\n", with: " ")

        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 2

        let amountString = nf.string(from: amount as NSDecimalNumber) ?? "\(amount)"
        return "\(title) $\(amountString)"
    }
}

// MARK: - UICollectionViewDataSource
extension GiftsChooseViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GiftCardCell.reuseID,
            for: indexPath
        ) as? GiftCardCell else {
            return UICollectionViewCell()
        }

        let gift = items[indexPath.item]
        let existingAmount = enteredAmounts[gift.id]

        cell.configure(item: gift, accent: accent, existingAmount: existingAmount)

        cell.onAmountChanged = { [weak self] newText in
            guard let self else { return }

            // ✅ BLOCK "-" even if user pastes it
            let cleaned = newText
                .replacingOccurrences(of: "-", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if let value = cleaned.decimalValue() {
                self.enteredAmounts[gift.id] = value

                if value <= 0 {
                    self.showErrorBanner("Amount must be greater than 0.")
                }
            } else {
                self.enteredAmounts[gift.id] = nil
            }
        }

        cell.onChooseTapped = { [weak self] in
            self?.didTapChooseGift(gift)
        }

        return cell
    }
}

extension GiftsChooseViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
}
