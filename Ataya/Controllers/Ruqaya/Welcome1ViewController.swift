//
//  Welcome1ViewController.swift
//  AtayaTest
//
//  Created by Ruqaya Habib on 20/12/2025.
//

import UIKit

class Welcome1ViewController: UIViewController {

    
    
    @IBOutlet weak var nextImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        nextImageView.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(nextTapped))
        nextImageView.addGestureRecognizer(tap)
        
    }
    
    
    @objc private func nextTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Welcome2ViewController")

        navigationController?.pushViewController(vc, animated: true)

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
