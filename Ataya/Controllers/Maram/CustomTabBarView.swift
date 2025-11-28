//
//  CustomTabBarView.swift
//  Ataya
//
//  Created by Maram on 28/11/2025.
//
/*
import Foundation

import UIKit

class CustomTabBarView: UIView {

    // This will be called after the view is loaded from the XIB
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    private func setupView() {
        // later we can add corner radius, shadow, colors here
    }

    // Helper to load the view from the XIB
    static func loadFromNib() -> CustomTabBarView {
        let nib = UINib(nibName: "CustomTabBarView", bundle: nil)
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? CustomTabBarView else {
            fatalError("Could not load CustomTabBarView from nib")
        }
        return view
    }
}*/
import UIKit

class CustomTabBarView: UIView {
    // MARK: - Outlets

       @IBOutlet weak var homeIcon: UIImageView!
       @IBOutlet weak var homeLabel: UILabel!

       @IBOutlet weak var verifyIcon: UIImageView!
       @IBOutlet weak var verifyLabel: UILabel!

       @IBOutlet weak var reportHexagon: UIImageView!
       @IBOutlet weak var reportIcon: UIImageView!
       @IBOutlet weak var reportLabel: UILabel!

       @IBOutlet weak var analyticsIcon: UIImageView!
       @IBOutlet weak var analyticsLabel: UILabel!

       @IBOutlet weak var profileIcon: UIImageView!
       @IBOutlet weak var profileLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    private func setupView() {
        // Later you can add shadows, corner radius or background colors if needed
        self.backgroundColor = .white
            //self.backgroundColor = .red

            // Optional: small shadow on top so you can see it clearly
//            layer.shadowColor = UIColor.black.cgColor
//            layer.shadowOpacity = 0.08
//            layer.shadowOffset = CGSize(width: 0, height: -2)
//            layer.shadowRadius = 6
    }

    static func loadFromNib() -> CustomTabBarView {
        let nib = UINib(nibName: "CustomTabBarView", bundle: nil)
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? CustomTabBarView else {
            fatalError("Could not load CustomTabBarView.xib")
        }
        return view
    }
}



