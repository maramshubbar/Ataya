//
//  AdminTabBarController.swift
//  Ataya
//
//  Created by Maram on 16/12/2025.
//

import UIKit

final class AdminTabBarController: UITabBarController {

    private let centerButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabLook()
        setupCenterButton()
        setupTabIconSizes()   // ✅ ضيفي هذي

        
    }

    private func setupTabIconSizes() {
        guard let items = tabBar.items, items.count >= 5 else { return }

        // عدلي الحجم من كيفج (عادة 26~30 أفضل للتاب بار)
        let size = CGSize(width: 30, height: 30)

        items[0].image = UIImage(named: "tab_home")?.resized(to: size).withRenderingMode(.alwaysTemplate)
        items[0].selectedImage = UIImage(named: "tab_home")?.resized(to: size).withRenderingMode(.alwaysTemplate)

        items[1].image = UIImage(named: "tab_verify")?.resized(to: size).withRenderingMode(.alwaysTemplate)
        items[1].selectedImage = UIImage(named: "tab_verify")?.resized(to: size).withRenderingMode(.alwaysTemplate)

        // الوسط خليّه empty لأنه زر الهيكس
        items[2].image = UIImage(named: "tab_empty")?.withRenderingMode(.alwaysOriginal)
        items[2].selectedImage = UIImage(named: "tab_empty")?.withRenderingMode(.alwaysOriginal)

        items[3].image = UIImage(named: "tab_analytics")?.resized(to: size).withRenderingMode(.alwaysTemplate)
        items[3].selectedImage = UIImage(named: "tab_analytics")?.resized(to: size).withRenderingMode(.alwaysTemplate)

        items[4].image = UIImage(named: "tab_profile")?.resized(to: size).withRenderingMode(.alwaysTemplate)
        items[4].selectedImage = UIImage(named: "tab_profile")?.resized(to: size).withRenderingMode(.alwaysTemplate)
    }

    
    private func setupTabLook() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        tabBar.isTranslucent = false

        appearance.shadowColor = .clear

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) { tabBar.scrollEdgeAppearance = appearance }

        tabBar.tintColor = UIColor(red: 0.96, green: 0.84, blue: 0.36, alpha: 1.0) // أصفر قريب
        tabBar.unselectedItemTintColor = UIColor.systemGray2
    }

    private func setupCenterButton() {
        centerButton.setBackgroundImage(UIImage(named: "hex_report_bg"), for: .normal)
        centerButton.setImage(UIImage(named: "ic_report_center"), for: .normal)
        centerButton.adjustsImageWhenHighlighted = false

        centerButton.addTarget(self, action: #selector(centerTapped), for: .touchUpInside)

        view.addSubview(centerButton)
        view.bringSubviewToFront(centerButton)

        centerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            centerButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor, constant: -7),
            centerButton.widthAnchor.constraint(equalToConstant: 90),
            centerButton.heightAnchor.constraint(equalTo: centerButton.widthAnchor)
        ])
    }
    

    @objc private func centerTapped() {
        selectedIndex = 2 // تبويب Report (الوسط)
    }
}

private extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
