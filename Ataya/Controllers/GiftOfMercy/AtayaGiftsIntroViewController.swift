//
//  AtayaGiftsIntroViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 24/12/2025.
//

import UIKit

final class AtayaGiftsIntroViewController: UIViewController {

    // MARK: - Purple Gradient (light, not too dark)
    private let c1 = UIColor(red: 0.10, green: 0.14, blue: 0.34, alpha: 1.0)
    private let c2 = UIColor(red: 0.32, green: 0.24, blue: 0.62, alpha: 1.0)
    private let c3 = UIColor(red: 0.62, green: 0.48, blue: 0.86, alpha: 1.0)

    private let accentYellow = UIColor(red: 0.95, green: 0.88, blue: 0.52, alpha: 1.0)

    private let bgView = UIView()
    private let gradient = CAGradientLayer()

    private let scroll = UIScrollView()
    private let stack = UIStackView()

    private let title1 = UILabel()
    private let title2 = UILabel()

    // ✅ Something in between (NO gift icon)
    private let decoCard = UIView()
    private let decoGradient = CAGradientLayer()

    private let howCard = UIView()
    private let startButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = nil
        navigationItem.title = ""
        navigationItem.largeTitleDisplayMode = .never

        buildUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = bgView.bounds
        decoGradient.frame = decoCard.bounds
    }

    private func buildUI() {
        view.backgroundColor = .black

        // Background
        view.addSubview(bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: view.topAnchor),
            bgView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        gradient.colors = [c1.cgColor, c2.cgColor, c3.cgColor]
        gradient.locations = [0.0, 0.55, 1.0]
        gradient.startPoint = CGPoint(x: 0.15, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.85, y: 1.0)
        bgView.layer.insertSublayer(gradient, at: 0)

        // Scroll
        bgView.addSubview(scroll)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: bgView.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: bgView.trailingAnchor),
        ])

        // Stack
        stack.axis = .vertical
        stack.spacing = 16
        stack.layoutMargins = UIEdgeInsets(top: 26, left: 20, bottom: 26, right: 20)
        stack.isLayoutMarginsRelativeArrangement = true

        scroll.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor),
        ])

        // Titles
        title1.text = "A gift that"
        title1.textColor = .white
        title1.font = .systemFont(ofSize: 44, weight: .heavy)

        title2.text = "keeps on giving"
        title2.textColor = accentYellow
        if let f = UIFont(name: "SnellRoundhand-Bold", size: 46) {
            title2.font = f
        } else {
            title2.font = .italicSystemFont(ofSize: 42)
        }

        stack.addArrangedSubview(title1)
        stack.addArrangedSubview(title2)

        // ✅ Decorative card in between (no icon)
        buildDecoCard()
        stack.addArrangedSubview(decoCard)

        // How card
        buildHowCard()
        stack.addArrangedSubview(howCard)

        // Start button
        buildButton()
        stack.addArrangedSubview(startButton)
    }

    // MARK: - Deco Card
    private func buildDecoCard() {
        decoCard.layer.cornerRadius = 26
        decoCard.layer.masksToBounds = true
        decoCard.layer.borderWidth = 1
        decoCard.layer.borderColor = UIColor.white.withAlphaComponent(0.16).cgColor
        decoCard.heightAnchor.constraint(equalToConstant: 210).isActive = true

        // soft internal gradient (glass-ish without blur)
        decoGradient.colors = [
            UIColor.white.withAlphaComponent(0.14).cgColor,
            UIColor.white.withAlphaComponent(0.06).cgColor
        ]
        decoGradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        decoGradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        decoCard.layer.insertSublayer(decoGradient, at: 0)

        // bubbles (soft circles)
        let bubble1 = UIView()
        bubble1.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        bubble1.layer.cornerRadius = 70
        bubble1.translatesAutoresizingMaskIntoConstraints = false

        let bubble2 = UIView()
        bubble2.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        bubble2.layer.cornerRadius = 46
        bubble2.translatesAutoresizingMaskIntoConstraints = false

        // sparkles cluster
        let sparkBig = UIImageView(image: UIImage(systemName: "sparkles"))
        sparkBig.tintColor = UIColor.white.withAlphaComponent(0.85)
        sparkBig.translatesAutoresizingMaskIntoConstraints = false

        let sparkSmall = UIImageView(image: UIImage(systemName: "sparkle"))
        sparkSmall.tintColor = UIColor.white.withAlphaComponent(0.75)
        sparkSmall.translatesAutoresizingMaskIntoConstraints = false

        // optional tiny dot star
        let dot = UIView()
        dot.backgroundColor = UIColor.white.withAlphaComponent(0.70)
        dot.layer.cornerRadius = 3
        dot.translatesAutoresizingMaskIntoConstraints = false

        decoCard.addSubview(bubble1)
        decoCard.addSubview(bubble2)
        decoCard.addSubview(sparkBig)
        decoCard.addSubview(sparkSmall)
        decoCard.addSubview(dot)

        NSLayoutConstraint.activate([
            bubble1.widthAnchor.constraint(equalToConstant: 140),
            bubble1.heightAnchor.constraint(equalToConstant: 140),
            bubble1.centerXAnchor.constraint(equalTo: decoCard.centerXAnchor, constant: -40),
            bubble1.centerYAnchor.constraint(equalTo: decoCard.centerYAnchor, constant: 20),

            bubble2.widthAnchor.constraint(equalToConstant: 92),
            bubble2.heightAnchor.constraint(equalToConstant: 92),
            bubble2.centerXAnchor.constraint(equalTo: decoCard.centerXAnchor, constant: 70),
            bubble2.centerYAnchor.constraint(equalTo: decoCard.centerYAnchor, constant: -25),

            sparkBig.trailingAnchor.constraint(equalTo: decoCard.trailingAnchor, constant: -28),
            sparkBig.topAnchor.constraint(equalTo: decoCard.topAnchor, constant: 24),
            sparkBig.widthAnchor.constraint(equalToConstant: 22),
            sparkBig.heightAnchor.constraint(equalToConstant: 22),

            sparkSmall.trailingAnchor.constraint(equalTo: sparkBig.leadingAnchor, constant: -10),
            sparkSmall.topAnchor.constraint(equalTo: sparkBig.topAnchor, constant: 7),
            sparkSmall.widthAnchor.constraint(equalToConstant: 14),
            sparkSmall.heightAnchor.constraint(equalToConstant: 14),

            dot.leadingAnchor.constraint(equalTo: decoCard.leadingAnchor, constant: 26),
            dot.topAnchor.constraint(equalTo: decoCard.topAnchor, constant: 30),
            dot.widthAnchor.constraint(equalToConstant: 6),
            dot.heightAnchor.constraint(equalToConstant: 6),
        ])
    }

    // MARK: - How it works card
    private func buildHowCard() {
        howCard.layer.cornerRadius = 22
        howCard.layer.masksToBounds = true
        howCard.layer.borderWidth = 1
        howCard.layer.borderColor = UIColor.white.withAlphaComponent(0.14).cgColor
        howCard.backgroundColor = UIColor.white.withAlphaComponent(0.10)

        let howTitle = UILabel()
        howTitle.text = "How it works:"
        howTitle.textColor = .white
        howTitle.font = .systemFont(ofSize: 22, weight: .heavy)

        let list = UIStackView()
        list.axis = .vertical
        list.spacing = 10

        [
            "1. Select a gift from the options below.",
            "2. Pick a gift card.",
            "3. Add a personal message and complete the transaction."
        ].forEach {
            let lbl = UILabel()
            lbl.text = $0
            lbl.textColor = .white.withAlphaComponent(0.95)
            lbl.font = .systemFont(ofSize: 18, weight: .regular)
            lbl.numberOfLines = 0
            list.addArrangedSubview(lbl)
        }

        let inner = UIStackView(arrangedSubviews: [howTitle, list])
        inner.axis = .vertical
        inner.spacing = 14
        inner.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        inner.isLayoutMarginsRelativeArrangement = true

        howCard.addSubview(inner)
        inner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: howCard.topAnchor),
            inner.bottomAnchor.constraint(equalTo: howCard.bottomAnchor),
            inner.leadingAnchor.constraint(equalTo: howCard.leadingAnchor),
            inner.trailingAnchor.constraint(equalTo: howCard.trailingAnchor),
        ])
    }

    // MARK: - Button
    private func buildButton() {
        startButton.setTitle("Start", for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .heavy)
        startButton.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 16
        startButton.layer.masksToBounds = true
        startButton.layer.borderWidth = 1
        startButton.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        startButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
    }

    @objc private func startTapped() {
        // later: push Step 1
    }
}
