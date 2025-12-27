//
//  EnterDetailsViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 28/11/2025.
//

import UIKit
import FirebaseFirestore

final class EnterDetailsViewController: UIViewController, UIScrollViewDelegate {
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
    
    // Expiry: UIDatePicker
    private let expiryDatePicker = UIDatePicker()
    private let expiryFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd / MM / yyyy"
        return f
    }()
    
    // MARK: - Dropdown Data
    private let categories: [String] = [
        "Fruits & Vegetables",
        "Bakery",
        "Dairy",
        "Meat & Poultry",
        "Seafood",
        "Frozen Foods",
        "Canned & Jarred",
        "Dry Goods (Rice/Pasta)",
        "Snacks",
        "Beverages",
        "Infant Nutrition",
        "Condiments & Sauces",
        "Other"
    ]
    
    private let packagings: [String] = [
        "Plastic",
        "Glass",
        "Metal Can",
        "Paper/Cardboard",
        "Bag/Pouch",
        "Tray/Clamshell",
        "Other"
    ]
    
    private let allergens: [String] = [
        "None",
        "Milk",
        "Eggs",
        "Peanuts",
        "Tree Nuts",
        "Soy",
        "Wheat (Gluten)",
        "Fish",
        "Shellfish",
        "Sesame",
        "Multiple Allergens",
        "Other"
    ]
    
    
    // MARK: - Pickers (Dropdowns)
    private let categoryPicker = UIPickerView()
    private let packagingPicker = UIPickerView()
    private let allergenPicker  = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Safer approach
        if draft == nil { draft = DraftDonation() }
        
        scrollView.delegate = self
        nextButton.isHidden = true
        nextButton.alpha = 0
        
        styleCard(descriptionTextView)
        
        // Set tags (so icon tap knows which field to open)
        expiryTextField.tag = 1
        categoryTextField.tag = 2
        packagingTextField.tag = 3
        allergenTextField.tag = 4
        
        
        setupExpiryDatePicker()
        setupDropdowns()
    }
    
    
    private func styleCard(_ v: UIView) {
        v.backgroundColor = .white
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
        v.clipsToBounds = true
    }
    
    // MARK: - Expiry Setup
    private func setupExpiryDatePicker() {
        
        expiryDatePicker.datePickerMode = .date
        expiryDatePicker.preferredDatePickerStyle = .wheels
        
        expiryDatePicker.minimumDate = Calendar.current.startOfDay(for: Date())
        
        expiryTextField.inputView = expiryDatePicker
        expiryTextField.inputAccessoryView = makeDoneToolbar(action: #selector(expiryDoneTapped))
        
        setRightIcon("calendar", for: expiryTextField)
        expiryTextField.tintColor = .clear
        
        expiryDatePicker.addTarget(self, action: #selector(expiryChanged), for: .valueChanged)
        
        if let saved = draft.expiryDate {
            expiryDatePicker.date = saved
            expiryTextField.text = expiryFormatter.string(from: saved)
        } else {
            expiryTextField.text = ""
        }
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
    
    // MARK: - Scroll: show Next near bottom
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isNearBottom = scrollView.contentOffset.y + scrollView.bounds.height >= scrollView.contentSize.height - 80
        nextButton.isHidden = !isNearBottom
        nextButton.alpha = isNearBottom ? 1 : 0
    }
    
    // MARK: - Dropdown Setup
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
    
    @objc private func closePicker() {
        
        if categoryTextField.isFirstResponder {
            let row = categoryPicker.selectedRow(inComponent: 0)
            let val = categories[row]
            categoryTextField.text = val
            draft.category = val
        } else if packagingTextField.isFirstResponder {
            let row = packagingPicker.selectedRow(inComponent: 0)
            let val = packagings[row]
            packagingTextField.text = val
            draft.packagingType = val
        } else if allergenTextField.isFirstResponder {
            let row = allergenPicker.selectedRow(inComponent: 0)
            let val = allergens[row]
            allergenTextField.text = val
            draft.allergenInfo = val
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
        default: break
        }
    }
    
    // MARK: - Right Icon (tappable)
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
    
    
    private func syncDraftFromUI() {
        
        draft.itemName = (foodItemTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        draft.quantity = (quantityTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        // Expiry
        let expiryText = (expiryTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        draft.expiryDate = expiryText.isEmpty ? nil : expiryDatePicker.date
        
        // Dropdown/TextFields
        draft.category = (categoryTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        draft.packagingType = (packagingTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        draft.allergenInfo = (allergenTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Description
        draft.notes = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        syncDraftFromUI()
    }
    
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
        syncDraftFromUI()
        
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
        
        if draft.quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            fail(quantityErrorLabel, "Please enter the quantity.", focus: quantityTextField)
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
        syncDraftFromUI()
        
        guard validateAndShowInlineErrors() else { return }
        
        nextButton.isEnabled = false
        saveToFirestore()
    }
    
    
    private func saveToFirestore() {
        let db = Firestore.firestore()
        
        // reuse same doc if already created
        let docId = draft.id ?? db.collection("donations").document().documentID
        draft.id = docId
        
        var data = draft.toFirestoreDict()
        data["status"] = "pending"
        data["createdAt"] = FieldValue.serverTimestamp()
        data["updatedAt"] = FieldValue.serverTimestamp()
        
        print("✅ Saving donation docId:", docId)
        print("✅ Data keys:", Array(data.keys))
        
        db.collection("donations").document(docId).setData(data, merge: true) { [weak self] error in
            guard let self else { return }
            self.nextButton.isEnabled = true
            
            if let error {
                print("❌ Firestore error:", error.localizedDescription)
                self.showAlert("Save failed", error.localizedDescription)
                return
            }
            
//            self.showAlert("Saved ✅", "Donation saved to Firebase.")
        }
    }
}

    // MARK: - UIPickerView Delegate/DataSource (Dropdowns)
extension EnterDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == categoryPicker { return categories.count }
        if pickerView == packagingPicker { return packagings.count }
        return allergens.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPicker { return categories[row] }
        if pickerView == packagingPicker { return packagings[row] }
        return allergens[row]
    }
    private func showAlert(_ title: String, _ message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
            draft.allergenInfo = val
        }
    }
    
}
