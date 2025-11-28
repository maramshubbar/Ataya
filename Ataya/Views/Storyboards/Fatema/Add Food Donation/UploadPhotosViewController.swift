//
//  UploadPhotosViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 28/11/2025.
//

import UIKit

class UploadPhotosViewController: UIViewController {

    @IBOutlet weak var uploadCardView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        uploadCardView.layoutIfNeeded()
        
        // Remove previous dashed layer so it doesn't duplicate
        uploadCardView.layer.sublayers?.removeAll(where: { $0.name == "dashedBorder" })
        
        let dashed = CAShapeLayer()
        dashed.name = "dashedBorder"
        dashed.path = UIBezierPath(roundedRect: uploadCardView.bounds, cornerRadius: 12).cgPath
        dashed.strokeColor = UIColor.systemGray3.cgColor
        dashed.lineWidth = 1
        dashed.lineDashPattern = [6, 4]
        dashed.fillColor = UIColor.clear.cgColor
        
        uploadCardView.layer.addSublayer(dashed)
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
