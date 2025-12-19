//
//  CouponDetailsViewController.swift
//  Ataya
//
//  Created by Maram on 19/12/2025.
//

import UIKit

final class CouponDetailsViewController: UIViewController {

    // ✅ Outlet (اربطيه من Storyboard على نفس الـ UIView حق الكارد)
    @IBOutlet weak var cardView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // لا تحطين الشادو هنا لأن القياس (bounds) ممكن يكون صفر
    }

    // ✅ هنا أفضل مكان عشان الشادو يعتمد على الحجم النهائي
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyCardShadow()
    }

    // ✅ Shadow على الكارد نفسه
    private func applyCardShadow() {
        let radius: CGFloat = 18

        cardView.layer.cornerRadius = radius
        cardView.layer.masksToBounds = false     // لازم false عشان الشادو يبين

        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowOffset = CGSize(width: 0, height: 6)
        cardView.layer.shadowRadius = 10

        // شادو نظيف وسريع
        cardView.layer.shadowPath =
            UIBezierPath(roundedRect: cardView.bounds, cornerRadius: radius).cgPath
    }
}
