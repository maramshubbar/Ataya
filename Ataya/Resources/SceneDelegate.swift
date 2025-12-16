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
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(
            UIOffset(horizontal: -1000, vertical: 0),
            for: .default
        )
        
        UINavigationBar.appearance().tintColor = .black

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = .white

        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 22, weight: .semibold)
        ]


    }
    
    
    
}
     
     
      



