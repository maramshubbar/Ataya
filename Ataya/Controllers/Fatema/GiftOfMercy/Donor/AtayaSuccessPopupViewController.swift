//
//  AtayaSuccessPopupViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 01/01/2026.
//


// FILE: AtayaSuccessPopupViewController.swift
import UIKit

final class AtayaSuccessPopupViewController: UIViewController {

    // MARK: - Public
    var onPrimaryTapped: (() -> Void)?

    var titleText: String = "Successfully Submitted"
    var subtitleText: String = "Saved successfully."
    var buttonText: String = "Back Home"

    // MARK: - Theme
    private let brandYellow = UIColor(atayaHex: "#F7D44C")
    private let checkGreen = UIColor(atayaHex: "#4F8E4F")
    private let fillGreen  = UIColor(atayaHex: "#CFE6CF")

    // MARK: - UI
    private let dim = UIView()
    private let card = UIView()

    private let closeBtn = UIButton(type: .system)

    private let iconWrap = UIView()
    private let sealImg = UIImageView()
    private let checkImg = UIImageView()

    private let titleLbl = UILabel()
    private let subLbl = UILabel()
    private let primaryBtn = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        buildUI()
        buildConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateIn()
    }

    private func buildUI() {
        view.backgroundColor = .clear

        // dim
        dim.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        view.addSubview(dim)
        dim.translatesAutoresizingMaskIntoConstraints = false
        dim.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeTapped)))

        // card
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 18
        card.layer.masksToBounds = true
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false

        // close X
        closeBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeBtn.tintColor = .secondaryLabel
        closeBtn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        card.addSubview(closeBtn)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false

        // icon (seal + check) EXACT style
        sealImg.image = UIImage(systemName: "seal.fill")
        sealImg.tintColor = fillGreen
        sealImg.contentMode = .scaleAspectFit
        sealImg.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 150, weight: .regular)

        checkImg.image = UIImage(systemName: "checkmark")
        checkImg.tintColor = checkGreen
        checkImg.contentMode = .scaleAspectFit
        checkImg.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 85, weight: .bold)

        iconWrap.addSubview(sealImg)
        iconWrap.addSubview(checkImg)
        card.addSubview(iconWrap)

        iconWrap.translatesAutoresizingMaskIntoConstraints = false
        sealImg.translatesAutoresizingMaskIntoConstraints = false
        checkImg.translatesAutoresizingMaskIntoConstraints = false

        // labels
        titleLbl.text = titleText
        titleLbl.font = .systemFont(ofSize: 28, weight: .bold)
        titleLbl.textAlignment = .center
        titleLbl.textColor = .label
        titleLbl.numberOfLines = 2

        subLbl.text = subtitleText
        subLbl.font = .systemFont(ofSize: 15, weight: .regular)
        subLbl.textAlignment = .center
        subLbl.textColor = .secondaryLabel
        subLbl.numberOfLines = 3

        card.addSubview(titleLbl)
        card.addSubview(subLbl)
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        subLbl.translatesAutoresizingMaskIntoConstraints = false

        // button
        primaryBtn.setTitle(buttonText, for: .normal)
        primaryBtn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        primaryBtn.setTitleColor(.label, for: .normal)
        primaryBtn.backgroundColor = brandYellow
        primaryBtn.layer.cornerRadius = 8
        primaryBtn.layer.masksToBounds = true
        primaryBtn.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)

        card.addSubview(primaryBtn)
        primaryBtn.translatesAutoresizingMaskIntoConstraints = false

        // set text now (in case you changed vars before presenting)
        refreshTexts()
    }

    private func refreshTexts() {
        titleLbl.text = titleText
        subLbl.text = subtitleText
        primaryBtn.setTitle(buttonText, for: .normal)
    }

    private func buildConstraints() {
        let preferredWidth = card.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -44)
        preferredWidth.priority = .defaultHigh

        let maxW = card.widthAnchor.constraint(lessThanOrEqualToConstant: 420)
        maxW.priority = .required

        NSLayoutConstraint.activate([
            dim.topAnchor.constraint(equalTo: view.topAnchor),
            dim.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dim.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dim.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // keep safe margins
            card.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 22),
            card.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -22),

            preferredWidth,
            maxW,

            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 460),

            closeBtn.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            closeBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            closeBtn.widthAnchor.constraint(equalToConstant: 28),
            closeBtn.heightAnchor.constraint(equalToConstant: 28),

            iconWrap.topAnchor.constraint(equalTo: card.topAnchor, constant: 56),
            iconWrap.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconWrap.widthAnchor.constraint(equalToConstant: 160),
            iconWrap.heightAnchor.constraint(equalToConstant: 160),

            sealImg.topAnchor.constraint(equalTo: iconWrap.topAnchor),
            sealImg.leadingAnchor.constraint(equalTo: iconWrap.leadingAnchor),
            sealImg.trailingAnchor.constraint(equalTo: iconWrap.trailingAnchor),
            sealImg.bottomAnchor.constraint(equalTo: iconWrap.bottomAnchor),

            checkImg.centerXAnchor.constraint(equalTo: iconWrap.centerXAnchor),
            checkImg.centerYAnchor.constraint(equalTo: iconWrap.centerYAnchor),
            checkImg.widthAnchor.constraint(equalToConstant: 90),
            checkImg.heightAnchor.constraint(equalToConstant: 90),

            titleLbl.topAnchor.constraint(equalTo: iconWrap.bottomAnchor, constant: 18),
            titleLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            titleLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),

            subLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 12),
            subLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            subLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),

            primaryBtn.topAnchor.constraint(equalTo: subLbl.bottomAnchor, constant: 28),
            primaryBtn.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            primaryBtn.widthAnchor.constraint(equalTo: card.widthAnchor, constant: -56),
            primaryBtn.heightAnchor.constraint(equalToConstant: 56),
            primaryBtn.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -34)
        ])
    }


    private func animateIn() {
        card.alpha = 0
        card.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut]) {
            self.card.alpha = 1
            self.card.transform = .identity
        }
    }

    @objc private func primaryTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onPrimaryTapped?()
        }
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
