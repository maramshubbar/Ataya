//
//  DonorTabBarController.swift
//  Ataya
//
//  Created by Fatema Maitham on 17/12/2025.
//

import UIKit

class DonorTabBarController: UITabBarController {
    private let centerButton = UIButton(type: .custom)
        private var centerButtonConstraints: [NSLayoutConstraint] = []
     
        override func viewDidLoad() {
            super.viewDidLoad()
     
            // ✅ هذا يخلي الآيباد يرجّع التاب بار لتحت (iPadOS 18+)
            if #available(iOS 18.0, *), UIDevice.current.userInterfaceIdiom == .pad {
                traitOverrides.horizontalSizeClass = .compact
            }
     
            setupTabLook()
            setupTabIconSizes()
            setupCenterButton()
        }
     
        private func setupTabLook() {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowColor = .clear
     
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) { tabBar.scrollEdgeAppearance = appearance }
     
            tabBar.isTranslucent = false
            tabBar.tintColor = UIColor(red: 0.96, green: 0.84, blue: 0.36, alpha: 1.0)
            tabBar.unselectedItemTintColor = UIColor.systemGray2
        }
     
        private func setupTabIconSizes() {
            guard let items = tabBar.items, items.count >= 5 else { return }
            let size = CGSize(width: 30, height: 30)
     
            items[0].image = UIImage(named: "housefillgrey")?.resized(to: size).withRenderingMode(.alwaysTemplate)
            items[0].selectedImage = UIImage(named: "housefillgrey")?.resized(to: size).withRenderingMode(.alwaysTemplate)
     
            items[1].image = UIImage(named: "earthglobegrey")?.resized(to: size).withRenderingMode(.alwaysTemplate)
            items[1].selectedImage = UIImage(named: "earthglobegrey")?.resized(to: size).withRenderingMode(.alwaysTemplate)
     
            items[2].image = UIImage(named: "tab_empty")?.withRenderingMode(.alwaysOriginal)
            items[2].selectedImage = UIImage(named: "tab_empty")?.withRenderingMode(.alwaysOriginal)
     
            items[3].image = UIImage(named: "prizegrey")?.resized(to: size).withRenderingMode(.alwaysTemplate)
            items[3].selectedImage = UIImage(named: "prizegrey")?.resized(to: size).withRenderingMode(.alwaysTemplate)
     
            items[4].image = UIImage(named: "usergrey")?.resized(to: size).withRenderingMode(.alwaysTemplate)
            items[4].selectedImage = UIImage(named: "usergrey")?.resized(to: size).withRenderingMode(.alwaysTemplate)
        }
     
        private func setupCenterButton() {
            centerButton.setBackgroundImage(UIImage(named: "hex_report_bg"), for: .normal)
            centerButton.setImage(UIImage(named: "ic_report_center"), for: .normal)
           // centerButton.adjustsImageWhenHighlighted = false
            centerButton.addTarget(self, action: #selector(centerTapped), for: .touchUpInside)
     
            // ✅ مهم: خلّيه داخل tabBar (يحل no common ancestor خصوصًا بالآيباد)
            if centerButton.superview == nil {
                tabBar.addSubview(centerButton)
            }
            tabBar.bringSubviewToFront(centerButton)
     
            centerButton.translatesAutoresizingMaskIntoConstraints = false
     
            NSLayoutConstraint.deactivate(centerButtonConstraints)
            centerButtonConstraints = [
                centerButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
                centerButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor, constant: -7),
                centerButton.widthAnchor.constraint(equalToConstant: 90),
                centerButton.heightAnchor.constraint(equalTo: centerButton.widthAnchor)
            ]
            NSLayoutConstraint.activate(centerButtonConstraints)
        }
     
        @objc private func centerTapped() {
            selectedIndex = 2
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
