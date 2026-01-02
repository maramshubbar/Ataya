//
//  GiftOfMercyHubViewController.swift
//  Ataya
//

import UIKit

final class GiftOfMercyHubViewController: UIViewController {

    private enum DestID {
        static let orders  = "GiftOrdersListViewController"
        static let gifts   = "ManageGiftsListViewController"
        static let designs = "ManageCardDesignsListViewController"
    }

    private let gridVStack = UIStackView()
    private let row1 = UIStackView()
    private let row2Container = UIView()

    private let tileOrders  = RoleStyleTileView(title: "Orders", iconSystemName: "tray.full")
    private let tileGifts   = RoleStyleTileView(title: "Manage Gifts", iconSystemName: "gift")
    private let tileDesigns = RoleStyleTileView(title: "Card Designs", iconSystemName: "doc.richtext")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        setupActions()
    }

    private func setupNav() {
        view.backgroundColor = .systemBackground
        title = "Gift of Mercy"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.hidesBackButton = true
    }

    private func setupUI() {
        gridVStack.axis = .vertical
        gridVStack.spacing = 18
        gridVStack.translatesAutoresizingMaskIntoConstraints = false

        // row1: Orders + Manage Gifts
        row1.axis = .horizontal
        row1.spacing = 18
        row1.distribution = .fillEqually
        row1.addArrangedSubview(tileOrders)
        row1.addArrangedSubview(tileGifts)

        // row2: Card Designs centered
        row2Container.translatesAutoresizingMaskIntoConstraints = false
        tileDesigns.translatesAutoresizingMaskIntoConstraints = false
        row2Container.addSubview(tileDesigns)

        gridVStack.addArrangedSubview(row1)
        gridVStack.addArrangedSubview(row2Container)

        view.addSubview(gridVStack)

        let sameWidth = tileDesigns.widthAnchor.constraint(equalTo: tileOrders.widthAnchor)

        NSLayoutConstraint.activate([
            tileOrders.heightAnchor.constraint(equalTo: tileOrders.widthAnchor),
            tileGifts.heightAnchor.constraint(equalTo: tileGifts.widthAnchor),
            tileDesigns.heightAnchor.constraint(equalTo: tileDesigns.widthAnchor),

            gridVStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            gridVStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            gridVStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            tileDesigns.centerXAnchor.constraint(equalTo: row2Container.centerXAnchor),
            tileDesigns.topAnchor.constraint(equalTo: row2Container.topAnchor),
            tileDesigns.bottomAnchor.constraint(equalTo: row2Container.bottomAnchor),

            sameWidth
        ])
    }

    private func setupActions() {
        tileOrders.addTarget(self, action: #selector(openOrders), for: .touchUpInside)
        tileGifts.addTarget(self, action: #selector(openGifts), for: .touchUpInside)
        tileDesigns.addTarget(self, action: #selector(openDesigns), for: .touchUpInside)
    }

    @objc private func openOrders()  { openScreen(id: DestID.orders,  title: "Orders") }
    @objc private func openGifts()   { openScreen(id: DestID.gifts,   title: "Manage Gifts") }
    @objc private func openDesigns() { openScreen(id: DestID.designs, title: "Card Designs") }

    private func openScreen(id: String, title: String) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: id)
        vc.title = title

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
}

private final class RoleStyleTileView: UIControl {

    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    private let brandYellow = UIColor(hex: "F7D44C")

    override var isHighlighted: Bool {
        didSet { applyStyle() }
    }

    init(title: String, iconSystemName: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        iconView.image = UIImage(systemName: iconSystemName)
        setup()
        applyStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        applyStyle()
    }

    private func setup() {
        layer.cornerRadius = 14
        layer.borderWidth = 1.2
        layer.borderColor = UIColor.systemGray4.cgColor

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = brandYellow

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        addSubview(iconView)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -18),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }

    private func applyStyle() {
        if isHighlighted {
            backgroundColor = brandYellow.withAlphaComponent(0.18)
            layer.borderColor = brandYellow.cgColor
        } else {
            backgroundColor = .systemBackground
            layer.borderColor = UIColor.systemGray4.cgColor
        }
    }
}

private extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6 else { self.init(white: 0.5, alpha: alpha); return }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
