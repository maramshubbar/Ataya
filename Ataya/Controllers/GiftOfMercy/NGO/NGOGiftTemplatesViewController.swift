//
//  NGOGiftTemplatesViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//


import UIKit

final class NGOGiftTemplatesViewController: UIViewController {

    // MARK: - Local colors (no hex extension)
    private func color(hex: String, alpha: CGFloat = 1) -> UIColor {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6 else { return .systemYellow.withAlphaComponent(alpha) }

        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }

    private lazy var accentYellow = color(hex: "F7D44C")
    private lazy var softYellow = color(hex: "FFF8E8")
    private let border = UIColor.black.withAlphaComponent(0.06)

    // MARK: - Model (UI only)
    struct TemplateItem {
        let title: String
        let imageName: String
    }

    private var items: [TemplateItem] = [
        .init(title: "Kaaba", imageName: "c1"),
        .init(title: "Palestine Al Aqsa", imageName: "c2"),
        .init(title: "Floral", imageName: "c3"),
        .init(title: "Water", imageName: "c4")
    ]

    private var activeIndex: Int = 0 {
        didSet { updateActiveUI() }
    }

    // MARK: - UI
    private var collectionView: UICollectionView!

    private let headerCard = UIView()
    private let headerTitle = UILabel()
    private let headerSubtitle = UILabel()
    private let activePill = UILabel()

    private let toast = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        buildUI()
        setupCollection()
        setupToast()
        updateActiveUI()
    }

    private func setupNav() {
        title = "Gift card templates"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .black
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - UI Build
    private func buildUI() {
        // Header card
        headerCard.backgroundColor = softYellow
        headerCard.layer.cornerRadius = 18
        headerCard.layer.borderWidth = 1
        headerCard.layer.borderColor = UIColor.black.withAlphaComponent(0.03).cgColor
        headerCard.clipsToBounds = true

        headerTitle.text = "Manage templates"
        headerTitle.font = .systemFont(ofSize: 22, weight: .heavy)
        headerTitle.textColor = .label

        headerSubtitle.numberOfLines = 2
        headerSubtitle.font = .systemFont(ofSize: 15, weight: .regular)
        headerSubtitle.textColor = .secondaryLabel
        headerSubtitle.text = "Choose the default design your NGO will use when issuing certificates."

        activePill.font = .systemFont(ofSize: 12, weight: .semibold)
        activePill.textAlignment = .center
        activePill.textColor = .black
        activePill.backgroundColor = accentYellow.withAlphaComponent(0.95)
        activePill.layer.cornerRadius = 10
        activePill.clipsToBounds = true

        let topRow = UIStackView(arrangedSubviews: [headerTitle, activePill])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.distribution = .equalSpacing

        let headerStack = UIStackView(arrangedSubviews: [topRow, headerSubtitle])
        headerStack.axis = .vertical
        headerStack.spacing = 8

        headerCard.addSubview(headerStack)
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(headerCard)
        headerCard.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            headerCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            headerStack.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),
            headerStack.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -16),

            activePill.widthAnchor.constraint(greaterThanOrEqualToConstant: 86),
            activePill.heightAnchor.constraint(equalToConstant: 22),
        ])
    }

    private func setupCollection() {
        let layout = makeSingleColumnLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 30, right: 0)

        // ✅ تستخدمين CardChoiceCell.swift اللي عندج
        collectionView.register(CardChoiceCell.self, forCellWithReuseIdentifier: CardChoiceCell.reuseID)
        collectionView.dataSource = self
        collectionView.delegate = self

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func makeSingleColumnLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 14

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(330) // كلهم نفس الحجم
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 30, trailing: 16)

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Toast
    private func setupToast() {
        toast.isHidden = true
        toast.alpha = 0
        toast.textAlignment = .center
        toast.font = .systemFont(ofSize: 14, weight: .semibold)
        toast.textColor = .label
        toast.backgroundColor = accentYellow.withAlphaComponent(0.22)
        toast.layer.cornerRadius = 14
        toast.clipsToBounds = true

        view.addSubview(toast)
        toast.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 26),
            toast.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -26),
            toast.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func showToast(_ text: String) {
        toast.text = "   \(text)   "
        toast.isHidden = false
        toast.alpha = 0
        UIView.animate(withDuration: 0.2) {
            self.toast.alpha = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            UIView.animate(withDuration: 0.2, animations: {
                self.toast.alpha = 0
            }, completion: { _ in
                self.toast.isHidden = true
            })
        }
    }

    private func updateActiveUI() {
        let name = items.indices.contains(activeIndex) ? items[activeIndex].title : "—"
        activePill.text = "ACTIVE: \(name)"
        collectionView?.reloadData()
    }

    // MARK: - Actions
    private func setActiveTemplate(at index: Int) {
        activeIndex = index
        showToast("Active template set to \(items[index].title)")
    }

    private func previewTemplate(at index: Int) {
        let img = UIImage(named: items[index].imageName)
        let vc = ImagePreviewViewController(image: img, titleText: items[index].title)
        present(vc, animated: true)
    }
}

// MARK: - DataSource / Delegate
extension NGOGiftTemplatesViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardChoiceCell.reuseID, for: indexPath) as! CardChoiceCell

        let item = items[indexPath.item]
        let img = UIImage(named: item.imageName)

        // ✅ Cell عندج فيها configure(image:accent:)
        cell.configure(image: img, accent: accentYellow)

        // Choose = Set Active
        cell.onChooseTapped = { [weak self] in
            self?.setActiveTemplate(at: indexPath.item)
        }

        // Zoom = Preview
        cell.onZoomTapped = { [weak self] in
            self?.previewTemplate(at: indexPath.item)
        }

        // لو تبين تمييز الـ active بالكليك على السيل نفسه:
        if indexPath.item == activeIndex {
            cell.contentView.layer.borderWidth = 2
            cell.contentView.layer.borderColor = accentYellow.cgColor
            cell.contentView.layer.cornerRadius = 16
        } else {
            cell.contentView.layer.borderWidth = 0
            cell.contentView.layer.borderColor = UIColor.clear.cgColor
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setActiveTemplate(at: indexPath.item)
    }
}
