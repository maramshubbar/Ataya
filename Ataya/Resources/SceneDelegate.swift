//
//  SceneDelegate.swift
//  Ataya
//
//  Created by Maram on 24/11/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

        func scene(
            _ scene: UIScene,
            willConnectTo session: UISceneSession,
            options connectionOptions: UIScene.ConnectionOptions
        ) {
            guard let windowScene = (scene as? UIWindowScene) else { return }

            let window = UIWindow(windowScene: windowScene)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            window.rootViewController = storyboard.instantiateInitialViewController()

            // ✅ APPLY DARK MODE GLOBALLY
            let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light

            self.window = window
            window.makeKeyAndVisible()
        }
    
}
