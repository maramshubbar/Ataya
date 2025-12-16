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
            appearance.titleTextAttributes = [
                .font: UIFont.boldSystemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]

            
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
        // Make sure your asset name matches exactly
        let item = UIBarButtonItem(
            image: UIImage(named: "back-button"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        
        // Accessibility (good practice)
        item.accessibilityLabel = "Back"
        return item
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
