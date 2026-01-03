//
//  AtayaGiftsIntroViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 24/12/2025.
//

import UIKit

final class AtayaGiftsIntroViewController: UIViewController {

    // MARK: - UI
    private let posterContainer = UIView()
    private let posterImageView = UIImageView()
    private let giveNowButton = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Setup
    private func setupNav() {
        title = "Gifts of Mercy"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.hidesBackButton = false
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Poster container (rounded)
        posterContainer.layer.cornerRadius = 28
        posterContainer.clipsToBounds = true
        posterContainer.backgroundColor = .secondarySystemBackground

        // Poster image
        posterImageView.image = UIImage(named: "gifts_intro_banner")
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true

        // Button (Yellow)
        giveNowButton.setTitle("Give Now", for: .normal)
        giveNowButton.setTitleColor(.black, for: .normal)
        giveNowButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        giveNowButton.backgroundColor = .atayaYellow
        giveNowButton.layer.cornerRadius = 14
        giveNowButton.clipsToBounds = true
        giveNowButton.addTarget(self, action: #selector(giveNowTapped), for: .touchUpInside)

        // Add views
        view.addSubview(posterContainer)
        posterContainer.addSubview(posterImageView)
        view.addSubview(giveNowButton)

        // AutoLayout
        [posterContainer, posterImageView, giveNowButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func setupConstraints() {
        // Aspect
        let aspect = posterContainer.heightAnchor.constraint(equalTo: posterContainer.widthAnchor, multiplier: 1.55)
        aspect.priority = .defaultHigh

        NSLayoutConstraint.activate([
            // Poster
            posterContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            posterContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            posterContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Button
            giveNowButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            giveNowButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            giveNowButton.heightAnchor.constraint(equalToConstant: 54),
            giveNowButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),

            // Space بين البوستر والزر
            posterContainer.bottomAnchor.constraint(equalTo: giveNowButton.topAnchor, constant: -16),

            // Image fills container
            posterImageView.topAnchor.constraint(equalTo: posterContainer.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: posterContainer.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: posterContainer.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: posterContainer.bottomAnchor),

            // Aspect
            aspect
        ])
    }

    // MARK: - Actions
    @objc private func giveNowTapped() {
        let vc = GiftsChooseViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
