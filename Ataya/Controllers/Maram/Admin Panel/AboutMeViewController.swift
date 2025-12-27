//
//  AboutMeViewController.swift
//  Ataya
//
//  Created by Maram on 26/11/2025.
//

import UIKit

class AboutMeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    let borderGray = UIColor(red: 134/255, green: 136/255, blue: 137/255, alpha: 1)
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        styleTextField(fullNameTextField)
        styleTextField(emailTextField)
        styleTextField(phoneTextField)
    }
    
    
    
    
        
        @IBOutlet weak var fullNameTextField: UITextField!
        
        @IBOutlet weak var emailTextField: UITextField!
        
        
        @IBOutlet weak var phoneTextField: UITextField!
        
        func styleTextField(_ textField: UITextField) {
            textField.layer.cornerRadius = 8
            textField.layer.borderWidth = 1
            textField.layer.borderColor = borderGray.cgColor
            
            let padding = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
            textField.leftView = padding
            textField.leftViewMode = .always
        }
        
    @IBAction func backButtonTapped(_ sender: UIButton) {
        
           /* UIView.animate(withDuration: 0.30, delay: 0, options: .curveEaseOut) {
                self.navigationController?.popViewController(animated: true)*/
        
        
        self.dismiss(animated: true, completion: nil)


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

    

