//
//  PopupNGOApplicationViewController.swift
//  Ataya
//
//  Created by BP-36-224-14 on 29/12/2025.
//

import UIKit

class PopupNGOApplicationViewController: UIViewController {

    @IBOutlet weak var dimView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var viewNgoVerification: UIButton!
    
    @IBOutlet weak var cardView: UIView!
    
    // Callback for button tap
    var onDone: (() -> Void)?
    
    // Dynamic content
    var popupTitle: String?
    var popupDescription: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel?.text = popupTitle
        descriptionLabel?.text = popupDescription
        view.backgroundColor = .clear
        
        viewNgoVerification?.layer.cornerRadius = 8
        cardView?.layer.cornerRadius = 8
        cardView?.layer.shadowColor = UIColor.black.cgColor
        cardView?.layer.shadowOpacity = 0.2
        cardView?.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView?.layer.shadowRadius = 6

        // Dim overlay
        let overlay: UIView
        if let dimView {
            overlay = dimView }
        else {
            overlay = UIView(frame: view.bounds); overlay.translatesAutoresizingMaskIntoConstraints = false; view.insertSubview(overlay, at: 0); NSLayoutConstraint.activate([ overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor), overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor), overlay.topAnchor.constraint(equalTo: view.topAnchor), overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor) ])
            self.dimView = overlay }
        
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.45); overlay.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup)); overlay.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissPopup() {
        onDone?()
        dismiss(animated: true)
    }
    
    @IBAction func ngoViewVerification(_ sender: Any) {
        onDone?()
        dismiss(animated: true)
    }
    

}
