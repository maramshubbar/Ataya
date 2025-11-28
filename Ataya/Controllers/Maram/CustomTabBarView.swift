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
    weak var delegate: CustomTabBarDelegate?

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
    
    
    protocol CustomTabBarDelegate: AnyObject {
        func didSelectTab(_ tab: CustomTabBarView.TabType)
    }

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    private func setupView() {
        // Later you can add shadows, corner radius or background colors if needed
        self.backgroundColor = .white
            //self.backgroundColor = .red

            // STEP 1: Enable user interaction on all icons & labels

            homeIcon.isUserInteractionEnabled = true
            homeLabel.isUserInteractionEnabled = true

            verifyIcon.isUserInteractionEnabled = true
            verifyLabel.isUserInteractionEnabled = true

            reportHexagon.isUserInteractionEnabled = true
            reportIcon.isUserInteractionEnabled = true
            reportLabel.isUserInteractionEnabled = true

            analyticsIcon.isUserInteractionEnabled = true
            analyticsLabel.isUserInteractionEnabled = true

            profileIcon.isUserInteractionEnabled = true
            profileLabel.isUserInteractionEnabled = true
            
            
            
            homeIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(homeTapped)))
                homeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(homeTapped)))

                verifyIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(verifyTapped)))
                verifyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(verifyTapped)))

                reportHexagon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reportTapped)))
                reportIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reportTapped)))
                reportLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reportTapped)))

                analyticsIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(analyticsTapped)))
                analyticsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(analyticsTapped)))

                profileIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTapped)))
                profileLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTapped)))
        

    }
    
    enum TabType {
        case home, verification, report, analytics, profile
    }

    func setSelected(tab: TabType) {
        let yellow = UIColor(red: 0xFE/255, green: 0xC4/255, blue: 0x00/255, alpha: 1)
        let gray = UIColor.gray
        
        homeIcon.tintColor = gray
        homeLabel.textColor = gray

        verifyIcon.tintColor = gray
        verifyLabel.textColor = gray

        reportIcon.tintColor = gray
        reportLabel.textColor = gray

        analyticsIcon.tintColor = gray
        analyticsLabel.textColor = gray

        profileIcon.tintColor = gray
        profileLabel.textColor = gray

        switch tab {
        case .home:
            homeIcon.tintColor = yellow
            homeLabel.textColor = yellow
        case .verification:
            verifyIcon.tintColor = yellow
            verifyLabel.textColor = yellow
        case .report:
            reportIcon.tintColor = .white
            reportLabel.textColor = yellow
        case .analytics:
            analyticsIcon.tintColor = yellow
            analyticsLabel.textColor = yellow
        case .profile:
            profileIcon.tintColor = yellow
            profileLabel.textColor = yellow
        }
    }


    static func loadFromNib() -> CustomTabBarView {
        let nib = UINib(nibName: "CustomTabBarView", bundle: nil)
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? CustomTabBarView else {
            fatalError("Could not load CustomTabBarView.xib")
        }
        return view
    }
    
    
    @objc func homeTapped() {
        delegate?.didSelectTab(.home)
    }

    @objc func verifyTapped() {
        delegate?.didSelectTab(.verification)
    }

    @objc func reportTapped() {
        delegate?.didSelectTab(.report)
    }

    @objc func analyticsTapped() {
        delegate?.didSelectTab(.analytics)
    }

    @objc func profileTapped() {
        delegate?.didSelectTab(.profile)
    }

}



