//
//  GiftsCheckoutViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 24/12/2025.
//


import UIKit

final class GiftsCheckoutViewController: UIViewController {

    private let selection: GiftSelection
    private let form: GiftCertificateForm

    private let poster = UIImageView()
    private let info = UILabel()
    private let submitButton = UIButton(type: .system)

    init(selection: GiftSelection, form: GiftCertificateForm) {
        self.selection = selection
        self.form = form
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Step 3: Review"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground

        poster.image = UIImage(named: form.selectedCard?.imageName ?? "")
        poster.contentMode = .scaleAspectFit
        poster.backgroundColor = .white
        poster.layer.cornerRadius = 16
        poster.clipsToBounds = true
        poster.layer.borderWidth = 1
        poster.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor

        info.numberOfLines = 0
        info.font = .systemFont(ofSize: 16, weight: .semibold)
        info.textColor = .label
        info.text =
"""
Gift: \(selection.gift.title)  \(selection.amount.moneyString)
Card: \(form.selectedCard?.title ?? "-")

From: \(form.fromName)
Message: \(form.message)

Recipient: \(form.recipientName)
Email: \(form.recipientEmail)
"""

        submitButton.setTitle("Complete", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        submitButton.backgroundColor = .yellow
        submitButton.layer.cornerRadius = 14
        submitButton.clipsToBounds = true
        submitButton.addTarget(self, action: #selector(done), for: .touchUpInside)

        view.addSubview(poster)
        view.addSubview(info)
        view.addSubview(submitButton)

        [poster, info, submitButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            poster.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            poster.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            poster.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            poster.heightAnchor.constraint(equalToConstant: 260),

            info.topAnchor.constraint(equalTo: poster.bottomAnchor, constant: 16),
            info.leadingAnchor.constraint(equalTo: poster.leadingAnchor),
            info.trailingAnchor.constraint(equalTo: poster.trailingAnchor),

            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            submitButton.heightAnchor.constraint(equalToConstant: 56),
        ])
    }

    @objc private func done() {
        let alert = UIAlertController(title: "Done ✅", message: "Step 3 placeholder (connect payment / submit later).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
