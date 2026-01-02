//
//  EnterDetailsViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 28/11/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

final class EnterDetailsViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    var draft: DraftDonation!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var expiryTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var allergenTextField: UITextField!
    @IBOutlet weak var packagingTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var foodItemTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    
    @IBOutlet weak var foodItemErrorLabel: UILabel!
    @IBOutlet weak var quantityErrorLabel: UILabel!
    @IBOutlet weak var expiryErrorLabel: UILabel!
    @IBOutlet weak var categoryErrorLabel: UILabel!
    @IBOutlet weak var packagingErrorLabel: UILabel!
        
    // Expiry
        private let expiryDatePicker = UIDatePicker()
        private let expiryFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "dd / MM / yyyy"
            return f
        }()

        // Dropdown Data
        private let categories: [String] = [
            "Fruits & Vegetables","Bakery","Dairy","Meat & Poultry","Seafood",
            "Frozen Foods","Canned & Jarred","Dry Goods (Rice/Pasta)","Snacks",
            "Beverages","Infant Nutrition","Condiments & Sauces","Other"
        ]

        private let packagings: [String] = [
            "Plastic","Glass","Metal Can","Paper/Cardboard","Bag/Pouch","Tray/Clamshell","Other"
        ]

        private let allergens: [String] = [
            "None","Milk","Eggs","Peanuts","Tree Nuts","Soy","Wheat (Gluten)","Fish","Shellfish","Sesame","Multiple Allergens","Other"
        ]

        // Pickers
        private let categoryPicker = UIPickerView()
        private let packagingPicker = UIPickerView()
        private let allergenPicker  = UIPickerView()

        // Quantity
        private let quantityPicker = UIPickerView()
        private let quantityValues: [Int] = Array(1...200)
        private let quantityUnits: [String] = ["kg", "g", "pcs", "L"]

        override func viewDidLoad() {
            super.viewDidLoad()

            if draft == nil { draft = DraftDonation() }

            scrollView.delegate = self

            // delegates
            foodItemTextField.delegate = self
            quantityTextField.delegate = self
            categoryTextField.delegate = self
            packagingTextField.delegate = self
            allergenTextField.delegate = self
            expiryTextField.delegate = self
//            descriptionTextView.delegate = self

            // update itemName live
            foodItemTextField.addTarget(self, action: #selector(foodItemChanged), for: .editingChanged)

            nextButton.isHidden = true
            nextButton.alpha = 0

            styleCard(descriptionTextView)

            // tags for right icon taps
            expiryTextField.tag = 1
            categoryTextField.tag = 2
            packagingTextField.tag = 3
            allergenTextField.tag = 4
            quantityTextField.tag = 5

            setupExpiryDatePicker()
            setupDropdowns()
            setupQuantityPicker()
            fillUIFromDraft()
        }

        private func styleCard(_ v: UIView) {
            v.backgroundColor = .white
            v.layer.cornerRadius = 14
            v.layer.borderWidth = 1
            v.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
            v.clipsToBounds = true
        }

        private func fillUIFromDraft() {
            foodItemTextField.text = draft.itemName

            if let d = draft.expiryDate {
                expiryDatePicker.date = d
                expiryTextField.text = expiryFormatter.string(from: d)
            } else {
                expiryTextField.text = ""
            }

            categoryTextField.text = draft.category.isEmpty ? "" : draft.category
            packagingTextField.text = draft.packagingType.isEmpty ? "" : draft.packagingType
            allergenTextField.text = draft.allergenInfo ?? ""
            descriptionTextView.text = draft.notes ?? ""

            // select pickers rows
            if let i = categories.firstIndex(of: draft.category) {
                categoryPicker.selectRow(i, inComponent: 0, animated: false)
            }
            if let i = packagings.firstIndex(of: draft.packagingType) {
                packagingPicker.selectRow(i, inComponent: 0, animated: false)
            }
            if let a = draft.allergenInfo, let i = allergens.firstIndex(of: a) {
                allergenPicker.selectRow(i, inComponent: 0, animated: false)
            }

            if draft.quantityValue > 0, let vI = quantityValues.firstIndex(of: draft.quantityValue) {
                quantityPicker.selectRow(vI, inComponent: 0, animated: false)
            }
            if !draft.quantityUnit.isEmpty, let uI = quantityUnits.firstIndex(of: draft.quantityUnit) {
                quantityPicker.selectRow(uI, inComponent: 1, animated: false)
            }

            if draft.quantityValue > 0 && !draft.quantityUnit.isEmpty {
                quantityTextField.text = "\(draft.quantityValue) \(draft.quantityUnit)"
            } else {
                quantityTextField.text = ""
            }
        }

        // MARK: - Expiry
        private func setupExpiryDatePicker() {
            expiryDatePicker.datePickerMode = .date
            expiryDatePicker.preferredDatePickerStyle = .wheels
            expiryDatePicker.minimumDate = Calendar.current.startOfDay(for: Date())

            expiryTextField.inputView = expiryDatePicker
            expiryTextField.inputAccessoryView = makeDoneToolbar(action: #selector(expiryDoneTapped))
            setRightIcon("calendar", for: expiryTextField)
            expiryTextField.tintColor = .clear

            expiryDatePicker.addTarget(self, action: #selector(expiryChanged), for: .valueChanged)
        }

        @objc private func expiryChanged() {
            let picked = expiryDatePicker.date
            expiryTextField.text = expiryFormatter.string(from: picked)
            draft.expiryDate = picked
        }

        @objc private func expiryDoneTapped() {
            let picked = expiryDatePicker.date
            draft.expiryDate = picked
            expiryTextField.text = expiryFormatter.string(from: picked)
            view.endEditing(true)
        }

        // MARK: - Dropdowns
        private func setupDropdowns() {
            categoryPicker.delegate = self
            categoryPicker.dataSource = self

            packagingPicker.delegate = self
            packagingPicker.dataSource = self

            allergenPicker.delegate = self
            allergenPicker.dataSource = self

            categoryTextField.inputView = categoryPicker
            packagingTextField.inputView = packagingPicker
            allergenTextField.inputView  = allergenPicker

            let toolbar = makeDoneToolbar(action: #selector(closePicker))
            categoryTextField.inputAccessoryView = toolbar
            packagingTextField.inputAccessoryView = toolbar
            allergenTextField.inputAccessoryView  = toolbar

            setRightIcon("chevron.down", for: categoryTextField)
            setRightIcon("chevron.down", for: packagingTextField)
            setRightIcon("chevron.down", for: allergenTextField)

            categoryTextField.tintColor = .clear
            packagingTextField.tintColor = .clear
            allergenTextField.tintColor = .clear
        }

        // MARK: - Quantity
        private func setupQuantityPicker() {
            quantityPicker.delegate = self
            quantityPicker.dataSource = self

            quantityTextField.inputView = quantityPicker
            quantityTextField.inputAccessoryView = makeDoneToolbar(action: #selector(closePicker))

            setRightIcon("chevron.down", for: quantityTextField)
            quantityTextField.tintColor = .clear
        }

        private func updateQuantityFromPicker() {
            let valueRow = max(0, min(quantityPicker.selectedRow(inComponent: 0), quantityValues.count - 1))
            let unitRow  = max(0, min(quantityPicker.selectedRow(inComponent: 1), quantityUnits.count - 1))

            let value = quantityValues[valueRow]
            let unit  = quantityUnits[unitRow]

            draft.quantityValue = value
            draft.quantityUnit = unit
            quantityTextField.text = "\(value) \(unit)"
        }

        // ✅ This prevents "opened picker but didn't move" issue
        func textFieldDidBeginEditing(_ textField: UITextField) {
            if textField == quantityTextField {
                // if no selection yet, force a valid initial selection
                if draft.quantityValue <= 0 || draft.quantityUnit.isEmpty {
                    quantityPicker.selectRow(0, inComponent: 0, animated: false)
                    quantityPicker.selectRow(0, inComponent: 1, animated: false)
                    updateQuantityFromPicker()
                }
            } else if textField == categoryTextField {
                if draft.category.isEmpty {
                    categoryPicker.selectRow(0, inComponent: 0, animated: false)
                    let v = categories[0]
                    draft.category = v
                    categoryTextField.text = v
                }
            } else if textField == packagingTextField {
                if draft.packagingType.isEmpty {
                    packagingPicker.selectRow(0, inComponent: 0, animated: false)
                    let v = packagings[0]
                    draft.packagingType = v
                    packagingTextField.text = v
                }
            } else if textField == allergenTextField {
                if (draft.allergenInfo ?? "").isEmpty {
                    allergenPicker.selectRow(0, inComponent: 0, animated: false)
                    let v = allergens[0] // None
                    draft.allergenInfo = (v == "None") ? nil : v
                    allergenTextField.text = v
                }
            }
        }

        // MARK: - Scroll: show Next near bottom
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let isNearBottom = scrollView.contentOffset.y + scrollView.bounds.height >= scrollView.contentSize.height - 80
            nextButton.isHidden = !isNearBottom
            nextButton.alpha = isNearBottom ? 1 : 0
        }

        @objc private func closePicker() {
            if quantityTextField.isFirstResponder {
                updateQuantityFromPicker()
            } else if categoryTextField.isFirstResponder {
                let row = max(0, categoryPicker.selectedRow(inComponent: 0))
                let val = categories[row]
                categoryTextField.text = val
                draft.category = val
            } else if packagingTextField.isFirstResponder {
                let row = max(0, packagingPicker.selectedRow(inComponent: 0))
                let val = packagings[row]
                packagingTextField.text = val
                draft.packagingType = val
            } else if allergenTextField.isFirstResponder {
                let row = max(0, allergenPicker.selectedRow(inComponent: 0))
                let val = allergens[row]
                allergenTextField.text = val
                draft.allergenInfo = (val == "None") ? nil : val
            }

            view.endEditing(true)
        }

        private func makeDoneToolbar(action: Selector) -> UIToolbar {
            let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
            let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: action)
            toolbar.items = [flex, done]
            return toolbar
        }

        @objc private func rightIconTapped(_ sender: UITapGestureRecognizer) {
            guard let tag = sender.view?.tag else { return }
            switch tag {
            case 1: expiryTextField.becomeFirstResponder()
            case 2: categoryTextField.becomeFirstResponder()
            case 3: packagingTextField.becomeFirstResponder()
            case 4: allergenTextField.becomeFirstResponder()
            case 5: quantityTextField.becomeFirstResponder()
            default: break
            }
        }

        private func setRightIcon(_ systemName: String, for textField: UITextField) {
            let icon = UIImageView(image: UIImage(systemName: systemName))
            icon.tintColor = .gray
            icon.contentMode = .scaleAspectFit
            icon.frame = CGRect(x: 0, y: 0, width: 20, height: 20)

            let container = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 30))
            icon.center = CGPoint(x: container.bounds.midX, y: container.bounds.midY)
            container.addSubview(icon)

            container.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(rightIconTapped(_:)))
            container.addGestureRecognizer(tap)

            container.tag = textField.tag
            textField.rightView = container
            textField.rightViewMode = .always
        }

        // MARK: - Live sync
        @objc private func foodItemChanged() {
            draft.itemName = (foodItemTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }

        func textViewDidChange(_ textView: UITextView) {
            let t = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            draft.notes = t.isEmpty ? nil : t
        }

        private func syncDraftFromUI(forceCommitPickers: Bool) {
            if forceCommitPickers {
                // ensures quantity/category/etc are written even if user didn’t press Done
                if quantityTextField.isFirstResponder { updateQuantityFromPicker() }
                if categoryTextField.isFirstResponder { closePicker() }
                if packagingTextField.isFirstResponder { closePicker() }
                if allergenTextField.isFirstResponder { closePicker() }
                if expiryTextField.isFirstResponder { expiryDoneTapped() }
            }

            draft.itemName = (foodItemTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

            // expiry
            let expiryText = (expiryTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            draft.expiryDate = expiryText.isEmpty ? nil : expiryDatePicker.date

            // dropdown texts (as backup)
            draft.category = (categoryTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            draft.packagingType = (packagingTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

            let a = (allergenTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            draft.allergenInfo = (a.isEmpty || a == "None") ? nil : a

            // notes
            let n = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            draft.notes = n.isEmpty ? nil : n
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            syncDraftFromUI(forceCommitPickers: false)
        }

        // MARK: - Validation UI
        private func hideAllErrors() {
            foodItemErrorLabel.isHidden = true
            quantityErrorLabel.isHidden = true
            expiryErrorLabel.isHidden = true
            categoryErrorLabel.isHidden = true
            packagingErrorLabel.isHidden = true
        }

        private func showError(_ label: UILabel, _ message: String) {
            label.text = message
            label.isHidden = false
        }

        private func validateAndShowInlineErrors() -> Bool {
            hideAllErrors()
            syncDraftFromUI(forceCommitPickers: true)

            var firstInvalidField: UIView?
            var ok = true

            func fail(_ label: UILabel, _ message: String, focus: UIView?) {
                showError(label, message)
                if firstInvalidField == nil { firstInvalidField = focus }
                ok = false
            }

            if draft.itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                fail(foodItemErrorLabel, "Please enter the food item name.", focus: foodItemTextField)
            }

            if draft.quantityValue <= 0 || draft.quantityUnit.isEmpty {
                fail(quantityErrorLabel, "Please choose the quantity.", focus: quantityTextField)
            }

            let today = Calendar.current.startOfDay(for: Date())
            if let expiry = draft.expiryDate {
                if Calendar.current.startOfDay(for: expiry) < today {
                    fail(expiryErrorLabel, "Please choose a valid expiry date (today or later).", focus: expiryTextField)
                }
            } else {
                fail(expiryErrorLabel, "Please choose a valid expiry date.", focus: expiryTextField)
            }

            if draft.category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                fail(categoryErrorLabel, "Please choose a food category.", focus: categoryTextField)
            }

            if draft.packagingType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                fail(packagingErrorLabel, "Please choose a packaging type.", focus: packagingTextField)
            }

            firstInvalidField?.becomeFirstResponder()
            return ok
        }

        @IBAction func nextTapped(_ sender: UIButton) {
            view.endEditing(true)
            guard validateAndShowInlineErrors() else { return }

            let sb = UIStoryboard(name: "Pickup", bundle: nil)
            guard let vc = sb.instantiateViewController(withIdentifier: "PickUpDateViewController") as? PickUpDateViewController else {
                showAlert("Storyboard Error", "In Pickup.storyboard set Storyboard ID = PickUpDateViewController")
                return
            }

            vc.draft = draft
            navigationController?.pushViewController(vc, animated: true)
        }

        private func showAlert(_ title: String, _ message: String) {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    // MARK: - UIPickerView
    extension EnterDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            pickerView == quantityPicker ? 2 : 1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if pickerView == quantityPicker {
                return (component == 0) ? quantityValues.count : quantityUnits.count
            }
            if pickerView == categoryPicker { return categories.count }
            if pickerView == packagingPicker { return packagings.count }
            return allergens.count
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if pickerView == quantityPicker {
                return (component == 0) ? "\(quantityValues[row])" : quantityUnits[row]
            }
            if pickerView == categoryPicker { return categories[row] }
            if pickerView == packagingPicker { return packagings[row] }
            return allergens[row]
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if pickerView == quantityPicker {
                updateQuantityFromPicker()
                return
            }

            if pickerView == categoryPicker {
                let val = categories[row]
                categoryTextField.text = val
                draft.category = val
            } else if pickerView == packagingPicker {
                let val = packagings[row]
                packagingTextField.text = val
                draft.packagingType = val
            } else {
                let val = allergens[row]
                allergenTextField.text = val
                draft.allergenInfo = (val == "None") ? nil : val
            }
        }
    }
