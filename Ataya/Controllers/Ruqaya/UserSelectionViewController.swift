//
//  UserSelectionViewController.swift
//  Ataya
//
//  Created by Ruqaya Habib on 29/11/2025.
//

import UIKit

class UserSelectionViewController: UIViewController {

    @IBOutlet weak var donorView: UIView!
    
    @IBOutlet weak var ngoView: UIView!
    
    @IBOutlet weak var adminView: UIView!
    
    var selectedUser: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let cards = [donorView, ngoView, adminView]
        for card in cards {
            card?.layer.cornerRadius = 16
            card?.layer.borderWidth = 1
            card?.layer.borderColor = UIColor.lightGray.cgColor
            card?.layer.masksToBounds = true
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
