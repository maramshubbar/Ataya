//
//  HistoryStatusPopupViewController.swift
//  MYPAGES
//
//  Created by Zahraa Ahmed on 19/12/2025.
//

import Foundation
import UIKit

final class HistoryStatusPopupViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var cardView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    

        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)

        cardView.layer.cornerRadius = 8
        cardView.clipsToBounds = true
        cardView.backgroundColor = .white

        // Border
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray4.cgColor

        // Shadow (IMPORTANT: shadow needs masksToBounds = false)
        cardView.layer.masksToBounds = false
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.15
        cardView.layer.shadowOffset = CGSize(width: 0, height: 8)
        cardView.layer.shadowRadius = 16


        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    
    @IBAction func backToPageTapped(_ sender: UIButton) { dismiss(animated: true)
    }
    
    
    @objc private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        if !cardView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            // If user taps inside the card (including the button), don't handle the gesture
            if let touchedView = touch.view, touchedView.isDescendant(of: cardView) {
                return false
            }
            return true
        }
}
