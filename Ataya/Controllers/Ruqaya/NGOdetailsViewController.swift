//
//  NGOdetailsViewController.swift
//  AtayaTest
//
//  Created by Ruqaya Habib on 18/12/2025.
//

import UIKit

class NGOdetailsViewController: UIViewController {

    
    @IBOutlet weak var typeButton: UIButton!
    
    private var selectedType: String? = nil

    
    @IBOutlet weak var personalIDCard: UIView!
    
    @IBOutlet weak var trainingCard: UIView!
    
    
    @IBOutlet weak var missionCard: UIView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        applyTypeButton(title: "Select Type", isPlaceholder: true)

        // Menu
        setupTypeDropdown()
        
        
        styleDocumentCard(personalIDCard)
        styleDocumentCard(trainingCard)
        styleDocumentCard(missionCard)

        styleSubmitButton()
        definesPresentationContext = true

    }
    
    
    private func styleDocumentCard(_ view: UIView) {
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.backgroundColor = .white
    }

    
    private func styleSubmitButton() {
        submitButton.layer.cornerRadius = 8
        submitButton.clipsToBounds = true
    }

    
    
    // MARK: - UI (Button Style + Placeholder)
        private func applyTypeButton(title: String, isPlaceholder: Bool) {

            typeButton.layer.cornerRadius = 8
            typeButton.layer.borderWidth = 1
            typeButton.layer.borderColor = UIColor.systemGray3.cgColor
            typeButton.backgroundColor = .white

            typeButton.contentHorizontalAlignment = .fill

            var config = UIButton.Configuration.plain()

            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

            let textColor: UIColor = isPlaceholder ? .systemGray2 : .label
            config.attributedTitle = AttributedString(
                title,
                attributes: AttributeContainer([.foregroundColor: textColor])
            )

            // Arrow (Right)
            config.image = UIImage(systemName: "chevron.down")
            config.imagePlacement = .trailing
            config.imagePadding = 10

            typeButton.configuration = config
            typeButton.tintColor = .systemGray

            typeButton.showsMenuAsPrimaryAction = true
        }

        // MARK: - Dropdown Menu
        private func setupTypeDropdown() {

            let option1 = UIAction(title: "Humanitarian / Non-Profit") { [weak self] _ in
                self?.selectedType = "Humanitarian / Non-Profit"
                self?.applyTypeButton(title: "Humanitarian / Non-Profit", isPlaceholder: false)
            }

            let option2 = UIAction(title: "Medical & Psychological") { [weak self] _ in
                self?.selectedType = "Medical & Psychological"
                self?.applyTypeButton(title: "Medical & Psychological", isPlaceholder: false)
            }

            let option3 = UIAction(title: "Community Support & Donation") { [weak self] _ in
                self?.selectedType = "Community Support & Donation"
                self?.applyTypeButton(title: "Community Support & Donation", isPlaceholder: false)
            }

            let menu = UIMenu(title: "", options: .displayInline, children: [
                option1, option2, option3
            ])

            typeButton.menu = menu
        }
    
    
    @IBAction func submitTapped(_ sender: UIButton) {
        print("✅ Submit tapped")
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "NGOSubmittedViewController")
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
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
