//
//  SafetyVC.swift
//  Ataya
//
//  Created by Fatema Maitham on 29/11/2025.
//

import UIKit

final class SafetyVC: UIViewController {
    var draft: DraftDonation?
    @IBAction func nextTapped(_ sender: UIButton) {
        guard isConfirmed else { return }
        guard var draft = self.draft else { return }

        draft.safetyConfirmed = true
        self.draft = draft

        performSegue(withIdentifier: "toEnterDetails", sender: nil)
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEnterDetails" {

            if let nav = segue.destination as? UINavigationController,
               let vc = nav.topViewController as? EnterDetailsViewController {
                vc.draft = draft
            }

            else if let vc = segue.destination as? EnterDetailsViewController {
                vc.draft = draft
            }
        }
    }




    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
 
    private var isConfirmed = false {
            didSet { updateUI() }
        }
    private let checkedGreen = UIColor.systemGreen
        private let disabledGray  = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1) // #E8E8E8
    private let enabledYellow = UIColor(red: 247/255, green: 212/255, blue: 76/255, alpha: 1) // #F7D44C

        override func viewDidLoad() {
            super.viewDidLoad()
            configureUI()
            isConfirmed = false
        }

    private func configureUI() {

        if #available(iOS 15.0, *) {
            checkboxButton.configuration = nil

            // Setup Next button configuration updates ONCE
            let base = nextButton.configuration
            nextButton.configurationUpdateHandler = { [weak self] button in
                guard let self else { return }
                var cfg = button.configuration ?? base ?? .filled()

                cfg.baseBackgroundColor = button.isEnabled ? self.enabledYellow : self.disabledGray
                cfg.baseForegroundColor = button.isEnabled ? .black : .white

                button.configuration = cfg
            }

            // if title was in config and disappeared
            if nextButton.title(for: .normal) == nil {
                nextButton.setTitle("Next", for: .normal)
            }
        }

        // Checkbox
        checkboxButton.setImage(UIImage(systemName: "square"), for: .normal)
        checkboxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        checkboxButton.tintColor = .lightGray

        updateUI()
    }


    private func updateUI() {
        checkboxButton.isSelected = isConfirmed
        checkboxButton.tintColor  = isConfirmed ? checkedGreen : .lightGray

        nextButton.isEnabled = isConfirmed

        if #available(iOS 15.0, *) {
            nextButton.setNeedsUpdateConfiguration()
        }
    }



        // MARK: - Actions



        @IBAction func checkboxTapped(_ sender: UIButton) {
            isConfirmed.toggle()
        }


    }

