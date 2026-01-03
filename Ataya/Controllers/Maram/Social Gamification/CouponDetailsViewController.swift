//
//  CouponDetailsViewController.swift
//  Ataya
//
//  Created by Maram on 19/12/2025.
//

import UIKit

final class CouponDetailsViewController: UIViewController {

    @IBOutlet weak var cardView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyCardShadow()
    }

    private func applyCardShadow() {
        let radius: CGFloat = 18

        cardView.layer.cornerRadius = radius
        cardView.layer.masksToBounds = false

        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 6)
        cardView.layer.shadowRadius = 8

        cardView.layer.shadowPath =
            UIBezierPath(roundedRect: cardView.bounds, cornerRadius: radius).cgPath
    }
}
