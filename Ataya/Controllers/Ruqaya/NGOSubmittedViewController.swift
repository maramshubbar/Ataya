//
//  NGOSubmittedViewController.swift
//  AtayaTest
//
//  Created by Ruqaya Habib on 19/12/2025.
//

import UIKit

class NGOSubmittedViewController: UIViewController {

    @IBOutlet weak var cardView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)

        
        cardView.layer.cornerRadius = 8
        cardView.clipsToBounds = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)


        
        if !cardView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
