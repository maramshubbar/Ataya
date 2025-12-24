//
//  PasswordChangedViewController.swift
//  AtayaTest
//
//  Created by Ruqaya Habib on 19/12/2025.
//

import UIKit

class PasswordChangedViewController: UIViewController {

    
    @IBOutlet weak var cardView: UIView!
    
    
    @IBOutlet weak var backButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupbackButton()

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
    
    private func setupbackButton() {
            backButton.layer.cornerRadius = 8
        }
    
    

    
    
    @IBAction func backToLoginTapped(_ sender: UIButton) {


        dismiss(animated: true) {


            guard
                    let window = UIApplication.shared.connectedScenes
                        .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                        .first,
                    let nav = window.rootViewController as? UINavigationController
                else { return }


            if let target = nav.viewControllers.last(where: { vc in
                    vc is AdminLoginViewController ||
                    vc is DonorLoginViewController ||
                    vc is NGOLoginViewController
                }) {
                    nav.popToViewController(target, animated: true)
                }
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
