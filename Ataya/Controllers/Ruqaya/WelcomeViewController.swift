//
//  WelcomeViewController.swift
//  AtayaTest
//
//  Created by Ruqaya Habib on 20/12/2025.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        view.addGestureRecognizer(tap)
    }
    

    @objc private func screenTapped() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Welcome1ViewController")
        
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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
