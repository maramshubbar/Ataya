//
//  PopupConfimPickupViewController.swift
//  Ataya
//
//  Created by BP-36-224-14 on 23/12/2025.
//
import UIKit

final class PopupConfirmPickupViewController: UIViewController {

    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var giveFeedbackButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Tap outside to close
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        dimView.addGestureRecognizer(tap)
    }

    @IBAction func giveFeedbackTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}

