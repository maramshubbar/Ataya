//
//  NGOApplicationViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 21/12/2025.
//

import UIKit
// MARK: - Status Enum (controls the whole screen)
enum ApplicationStatus {
    case pending
    case approved
    case rejected
}


class NGOApplicationViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    
    @IBOutlet weak var uploadedDocumentsContainerView: UIView!
    
    @IBOutlet weak var documentsStackView: UIStackView!
    
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var notesContainerView: UIView!
    
    @IBOutlet weak var actionButtonsContainerView: UIView!
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
}
