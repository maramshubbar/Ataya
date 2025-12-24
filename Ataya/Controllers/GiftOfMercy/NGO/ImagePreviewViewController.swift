//
//  ImagePreviewViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//


import UIKit

final class ImagePreviewViewController: UIViewController {

    private let image: UIImage?
    private let titleText: String

    private let imageView = UIImageView()
    private let closeButton = UIButton(type: .system)

    init(image: UIImage?, titleText: String) {
        self.image = image
        self.titleText = titleText
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.88)

        imageView.image = image
        imageView.contentMode = .scaleAspectFit

        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        closeButton.layer.cornerRadius = 18
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        let title = UILabel()
        title.text = titleText
        title.textColor = .white
        title.font = .systemFont(ofSize: 16, weight: .semibold)
        title.textAlignment = .center

        view.addSubview(imageView)
        view.addSubview(closeButton)
        view.addSubview(title)

        [imageView, closeButton, title].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36),

            title.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            imageView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
