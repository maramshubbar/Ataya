//
//  RecurringDonationViewController.swift
//  Ataya
//
//  Created by Zahraa Ahmed on 01/12/2025.
//

import UIKit

class RecurringDonationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
    {

    @IBOutlet weak var periodTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var arrowButton: UITextField!
    
    //Mark: -Proprities
    private let periodOptions = [
        "Dialy",
        "Weekly",
        "Bi-Weekly (Every 2 weeks)",
        "Monthly",
        "Bi-Monthly (Every 2 months)",
        "Yearly"
    ]
    
    private let periodPicker = UIPickerView()
    
    //Mark - LifeCycle
    override func loadView() {
        super.viewDidLoad()
        setupUI()
        setupPeriodPicker()
    }
    
    //Set up UI
    private func setupUI(){
        periodTextField.layer.cornerRadius = 8
        periodTextField.layer.borderWidth = 1
        periodTextField.layer.borderColor = UIColor.systemGray.cgColor
        periodTextField.layer.masksToBounds = true
        
        //prevent typing
        periodTextField.tintColor = .clear
        
        //style next button
        nextButton.layer.cornerRadius = 8
        nextButton.layer.masksToBounds = true
        
        //Minimum date
        datePicker.minimumDate = Date()
    }
    
    //Picker Set Up
    private func setupPeriodPicker(){
        periodPicker.delegate = self
        periodPicker.dataSource = self
        periodTextField.inputView = periodPicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelPickingPeriod)
            )
        
        let flexSpace = UIBarButtonItem(
                    barButtonSystemItem: .flexibleSpace,
                    target: nil,
                    action: nil
                )

                let doneButton = UIBarButtonItem(
                    title: "Done",
                    style: .done,
                    target: self,
                    action: #selector(donePickingPeriod)
                )

                toolbar.setItems([cancelButton, flexSpace, doneButton], animated: false)
                periodTextField.inputAccessoryView = toolbar
            }
    // MARK: - UIPickerViewDataSource
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

        func pickerView(_ pickerView: UIPickerView,
                        numberOfRowsInComponent component: Int) -> Int {
            return periodOptions.count
        }

        // MARK: - UIPickerViewDelegate
        func pickerView(_ pickerView: UIPickerView,
                        titleForRow row: Int,
                        forComponent component: Int) -> String? {
            return periodOptions[row]
        }

        func pickerView(_ pickerView: UIPickerView,
                        didSelectRow row: Int,
                        inComponent component: Int) {
            periodTextField.text = periodOptions[row]
        }

        // MARK: - Picker Actions
        @objc private func donePickingPeriod() {
            let selectedRow = periodPicker.selectedRow(inComponent: 0)
            periodTextField.text = periodOptions[selectedRow]
            periodTextField.resignFirstResponder()
        }

        @objc private func cancelPickingPeriod() {
            periodTextField.resignFirstResponder()
        }

        // MARK: - Button Actions
        @IBAction func arrowButtonTapped(_ sender: UIButton) {
            // Open drop-down picker when arrow is pressed
            periodTextField.becomeFirstResponder()
        }

        @IBAction func nextButtonTapped(_ sender: UIButton) {
            guard let period = periodTextField.text,
                  !period.isEmpty else {
                showAlert(title: "Missing period",
                          message: "Please select a relevant period before continuing.")
                return
            }

            let selectedDate = datePicker.date
            print("Recurring period: \(period)")
            print("Start date: \(selectedDate)")

            // Later: performSegue(...)
        }
    // MARK: - Helpers
        private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default,
                                          handler: nil))
            present(alert, animated: true, completion: nil)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
