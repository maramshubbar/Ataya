//
//  DonateViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 26/11/2025.
//

import UIKit

enum DonateOption { case food, basket, funds, campaigns, advocacy }

final class DonateViewController: UIViewController {

    // Overlay
    @IBOutlet weak var dimBackgroundView: UIView!
    @IBOutlet weak var sheetContainerView: UIView!
    @IBOutlet weak var sheetBottomConstraint: NSLayoutConstraint!

    // Cards
    @IBOutlet weak var card1: UIView!
    @IBOutlet weak var card2: UIView!
    @IBOutlet weak var card3: UIView!
    @IBOutlet weak var card4: UIView!
    @IBOutlet weak var card5: UIView!

    // Callback to TabBarController
    var onSelect: ((DonateOption) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        // Start dim hidden
        dimBackgroundView.alpha = 0

        // Tap outside to close
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        dimBackgroundView.addGestureRecognizer(tap)

        // Sheet rounded
        sheetContainerView.layer.cornerRadius = 28
        sheetContainerView.clipsToBounds = true

        // Apply style to cards
        [card1, card2, card3, card4, card5].forEach { styleCard($0) }

        // Make cards tappable (since they are UIViews)
        addTap(card1, action: #selector(foodTapped))
        addTap(card2, action: #selector(basketTapped))
        addTap(card3, action: #selector(fundsTapped))
        addTap(card4, action: #selector(campaignsTapped))
        addTap(card5, action: #selector(advocacyTapped))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSheet()
    }

    // MARK: - Styling
    private func styleCard(_ card: UIView?) {
        guard let card else { return }
        card.layer.cornerRadius = 10
        card.layer.masksToBounds = false
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 8
        card.layer.shouldRasterize = true
        card.layer.rasterizationScale = UIScreen.main.scale
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let cards = [card1, card2, card3, card4, card5].compactMap { $0 }
        for card in cards {
            card.layer.shadowPath = UIBezierPath(
                roundedRect: card.bounds,
                cornerRadius: 10
            ).cgPath
        }
    }

    // MARK: - Sheet Animations
    private func showSheet() {
        // Start below screen
        sheetBottomConstraint.constant = -400
        view.layoutIfNeeded()

        sheetBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseOut]) {
            self.dimBackgroundView.alpha = 0.35
            self.view.layoutIfNeeded()
        }
    }

    @objc private func close() {
        hideAndDismiss()
    }

    private func hideAndDismiss(completion: (() -> Void)? = nil) {
        sheetBottomConstraint.constant = -400
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseIn]) {
            self.dimBackgroundView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }

    // MARK: - Card taps
    private func addTap(_ view: UIView, action: Selector) {
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(tap)
    }

    @objc private func foodTapped() {
        hideAndDismiss { self.onSelect?(.food) }
    }

    @objc private func basketTapped() {
        hideAndDismiss { self.onSelect?(.basket) }
    }

    @objc private func fundsTapped() {
        hideAndDismiss { self.onSelect?(.funds) }
    }

    @objc private func campaignsTapped() {
        hideAndDismiss { self.onSelect?(.campaigns) }
    }

    @objc private func advocacyTapped() {
        hideAndDismiss { self.onSelect?(.advocacy) }
    }

    // Optional: connect your X button to this IBAction
    @IBAction func xTapped(_ sender: Any) {
        close()
    }
}
