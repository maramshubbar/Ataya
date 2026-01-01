//
//  Welcome3ViewController.swift
//  AtayaTest
//
//  Created by Ruqaya Habib on 20/12/2025.
//

import UIKit

class Welcome3ViewController: UIViewController {

    @IBOutlet weak var goImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        goImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(goTapped))
        goImageView.addGestureRecognizer(tap)
    }
    
    
    @objc private func goTapped() {

        performSegue(withIdentifier: "toUserSelection", sender: nil)


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
