//
//  RecurringDonation(Details)ViewController.swift
//  Ataya
//
//  Created by Ameena Khamis on 02/12/2025.
//

import UIKit

class RecurringDonationDetailsViewController: UIViewController,
                                              UIPickerViewDelegate,
                                              UIPickerViewDataSource,
                                              UITextFieldDelegate,
                                              UITextViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var foodItemTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var foodCategoryTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var nextButton: UIButton!

    @IBOutlet weak var foodItemArrowButton: UIButton!
    @IBOutlet weak var unitArrowButton: UIButton!
    @IBOutlet weak var foodCategoryArrowButton: UIButton!

    // MARK: - Picker Data
    private let foodItems = [
        "Baked Goods",
        "Fresh Produce",
        "Canned Food",
        "Prepared Meals",
        "Dry Goods (Rice / Pasta)"
    ]

    private let units = [
        "Packets",
        "Kg",
        "Boxes",
        "Liters"
    ]

    private let foodCategories = [
        "Bread & Bakery Items",
        "Fruits & Vegetables",
        "Canned & Packaged",
        "Cooked Meals",
        "Other"
    ]

    private enum PickerType {
        case foodItem
        case unit
        case foodCategory
    }

    private let picker = UIPickerView()
    private var activePickerType: PickerType?

    // Placeholder text for description
    private let descriptionPlaceholder = "Add any notes about the food condition or details…"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupPickers()
        setupQuantityKeyboard()
        setupDescriptionTextView()
    }

    // MARK: - Setup

    private func setupUI() {
        // نفس شكل الفيقما تقريبًا: زوايا بسيطة
        [foodItemTextField,
         quantityTextField,
         unitTextField,
         foodCategoryTextField].forEach { tf in
            tf?.layer.cornerRadius = 10
            tf?.layer.borderWidth = 1
            tf?.layer.borderColor = UIColor.lightGray.cgColor
            tf?.layer.masksToBounds = true
        }

        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.masksToBounds = true

        nextButton.layer.cornerRadius = 10
        nextButton.layer.masksToBounds = true

        // Prevent text cursor for dropdown fields
        foodItemTextField.tintColor = .clear
        unitTextField.tintColor = .clear
        foodCategoryTextField.tintColor = .clear

        // Delegates
        foodItemTextField.delegate = self
        unitTextField.delegate = self
        foodCategoryTextField.delegate = self
        quantityTextField.delegate = self
        descriptionTextView.delegate = self
    }

    private func setupPickers() {
        picker.delegate = self
        picker.dataSource = self

        // Use same picker for all dropdown textfields
        foodItemTextField.inputView = picker
        unitTextField.inputView = picker
        foodCategoryTextField.inputView = picker

        // Toolbar (Done / Cancel) فوق البيكر
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelPicker)
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
            action: #selector(donePicker)
        )

        toolbar.setItems([cancelButton, flexSpace, doneButton], animated: false)

        foodItemTextField.inputAccessoryView = toolbar
        unitTextField.inputAccessoryView = toolbar
        foodCategoryTextField.inputAccessoryView = toolbar
    }

    private func setupQuantityKeyboard() {
        quantityTextField.keyboardType = .numberPad

        // Add toolbar with Done to dismiss number pad
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )

        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneQuantity)
        )

        toolbar.setItems([flexSpace, doneButton], animated: false)
        quantityTextField.inputAccessoryView = toolbar
    }

    private func setupDescriptionTextView() {
        descriptionTextView.text = descriptionPlaceholder
        descriptionTextView.textColor = .lightGray
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == foodItemTextField {
            activePickerType = .foodItem
        } else if textField == unitTextField {
            activePickerType = .unit
        } else if textField == foodCategoryTextField {
            activePickerType = .foodCategory
        } else {
            activePickerType = nil   // quantity field
        }

        picker.reloadAllComponents()
        return true
    }

    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        switch activePickerType {
        case .foodItem:
            return foodItems.count
        case .unit:
            return units.count
        case .foodCategory:
            return foodCategories.count
        case .none:
            return 0
        }
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        switch activePickerType {
        case .foodItem:
            return foodItems[row]
        case .unit:
            return units[row]
        case .foodCategory:
            return foodCategories[row]
        case .none:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        switch activePickerType {
        case .foodItem:
            foodItemTextField.text = foodItems[row]
        case .unit:
            unitTextField.text = units[row]
        case .foodCategory:
            foodCategoryTextField.text = foodCategories[row]
        case .none:
            break
        }
    }

    // MARK: - Picker Actions

    @objc private func cancelPicker() {
        view.endEditing(true)
    }

    @objc private func donePicker() {
        let selectedRow = picker.selectedRow(inComponent: 0)

        switch activePickerType {
        case .foodItem:
            if foodItems.indices.contains(selectedRow) {
                foodItemTextField.text = foodItems[selectedRow]
            }
        case .unit:
            if units.indices.contains(selectedRow) {
                unitTextField.text = units[selectedRow]
            }
        case .foodCategory:
            if foodCategories.indices.contains(selectedRow) {
                foodCategoryTextField.text = foodCategories[selectedRow]
            }
        case .none:
            break
        }

        view.endEditing(true)
    }

    @objc private func doneQuantity() {
        quantityTextField.resignFirstResponder()
    }

    // MARK: - UITextViewDelegate (placeholder)

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == descriptionPlaceholder {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = descriptionPlaceholder
            textView.textColor = .lightGray
        }
    }

    // MARK: - Button Actions

    @IBAction func foodItemArrowTapped(_ sender: UIButton) {
        foodItemTextField.becomeFirstResponder()
    }

    @IBAction func unitArrowTapped(_ sender: UIButton) {
        unitTextField.becomeFirstResponder()
    }

    @IBAction func foodCategoryArrowTapped(_ sender: UIButton) {
        foodCategoryTextField.becomeFirstResponder()
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        // Basic validation
        guard let foodItem = foodItemTextField.text, !foodItem.isEmpty,
              let quantityText = quantityTextField.text, !quantityText.isEmpty,
              let unit = unitTextField.text, !unit.isEmpty,
              let category = foodCategoryTextField.text, !category.isEmpty
        else {
            showAlert(title: "Missing information",
                      message: "Please fill in Food Item, Quantity, Units, and Food Category.")
            return
        }

        let descriptionText = (descriptionTextView.text == descriptionPlaceholder)
            ? ""
            : descriptionTextView.text ?? ""

        print("Food Item: \(foodItem)")
        print("Quantity: \(quantityText) \(unit)")
        print("Category: \(category)")
        print("Description: \(descriptionText)")

        // TODO: هنا بعدين تربطينها بالفirebase أو تروحين للصفحة اللي بعدها
        // performSegue(withIdentifier: "YourNextSegueIdentifier", sender: self)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
