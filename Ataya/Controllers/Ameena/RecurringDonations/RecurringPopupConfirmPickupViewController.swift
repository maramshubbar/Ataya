//
//  RecurringPopupConfirmPickupViewController.swift
//  Ataya
//
//  Created by Zahraa Ahmed on 02/01/2026.
//

import UIKit

final class RecurringPopupConfirmPickupViewController: UIViewController {

    // MARK: - Optional Outlets
    // Optional to avoid crashes if not connected in storyboard
    @IBOutlet weak var dimView: UIView?
    @IBOutlet weak var giveFeedbackButton: UIButton?
    @IBOutlet weak var cardView: UIView?

    // Callback triggered when user finishes the popup action
    var onDone: (() -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Transparent root view
        view.backgroundColor = .clear
        isModalInPresentation = true

        // Dim overlay (create programmatically if not linked)
        let overlay: UIView
        if let dimView {
            overlay = dimView
        } else {
            overlay = UIView(frame: view.bounds)
            overlay.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(overlay, at: 0)
            NSLayoutConstraint.activate([
                overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                overlay.topAnchor.constraint(equalTo: view.topAnchor),
                overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            self.dimView = overlay
        }

        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        overlay.isUserInteractionEnabled = true
        // Note: No tap gesture is added, so the popup will not dismiss automatically

        // Card styling
        cardView?.layer.cornerRadius = 8
        cardView?.clipsToBounds = true

        // Button action
        giveFeedbackButton?.addTarget(self,
                                      action: #selector(giveFeedbackTapped),
                                      for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func giveFeedbackTapped() {
        onDone?()
        // If you want to dismiss the popup here, call:
        // dismiss(animated: true)
    }

    // MARK: - Tab Bar Handling
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}

