//
//  SceneDelegate.swift
//  Ataya
//
//  Created by Maram on 24/11/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")

        // Load the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialVC = storyboard.instantiateInitialViewController()

        // Create window and set root
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = initialVC
        window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        self.window = window
        window.makeKeyAndVisible()
    }

    
}
