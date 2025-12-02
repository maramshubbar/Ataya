//
//  AuditLogViewController.swift
//  Ataya
//
//  Created by Maram on 02/12/2025.
//

import UIKit

class AuditLogViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
            tableView.sectionHeaderTopPadding = 0

            let nib = UINib(nibName: "AuditLogCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "AuditLogCell")

    }
    


}
