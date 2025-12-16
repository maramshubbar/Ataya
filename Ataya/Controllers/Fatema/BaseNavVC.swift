//
//  BaseNavVC.swift
//  Ataya
//
//  Created by Fatema Maitham on 16/12/2025.
//

import UIKit

class BaseNavVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backButtonTitle = ""
        configureNavigation()
    }
    
    private func configureNavigation() {
        // Use standard appearance API
        if let navBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowColor = .clear // removes bottom line
            
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            navBar.compactAppearance = appearance
            navBar.tintColor = .black // applies to bar button icons
            
            // Hide the default back title everywhere
            navigationItem.backButtonTitle = ""
        }
        
        // Add custom back icon for any screen that is NOT the root of the stack
        if navigationController?.viewControllers.first != self {
            navigationItem.hidesBackButton = true
            navigationItem.leftBarButtonItem = makeBackBarButton()
        }
    }
    
    private func makeBackBarButton() -> UIBarButtonItem {
        let button = UIButton(type: .system)
            button.setImage(UIImage(named: "back-button"), for: .normal)
            button.tintColor = .black

            button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)

            // Optional: move it slightly down to match your reference
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)

            button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

            let item = UIBarButtonItem(customView: button)
            item.accessibilityLabel = "Back"
            return item
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
