//
//  EnterDetailsViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 28/11/2025.
//

import UIKit

final class EnterDetailsViewController: UIViewController, UIScrollViewDelegate {
    var draft: DraftDonation!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var expiryTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var allergenTextField: UITextField!
    @IBOutlet weak var packagingTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    private let expiryMonthYearPicker = UIPickerView()

    private let months = Calendar.current.monthSymbols  // ["January", ...]
    private let years: [Int] = Array(Calendar.current.component(.year, from: Date())...(Calendar.current.component(.year, from: Date()) + 20))
    private var selectedDayIndex = Calendar.current.component(.day, from: Date()) - 1

    private func daysCount(forMonth monthIndex: Int, year: Int) -> Int {
        // monthIndex: 0...11
        var comps = DateComponents()
        comps.year = year
        comps.month = monthIndex + 1
        comps.day = 1
        let cal = Calendar.current
        let date = cal.date(from: comps) ?? Date()
        return cal.range(of: .day, in: .month, for: date)?.count ?? 30
    }

    private var selectedMonthIndex = Calendar.current.component(.month, from: Date()) - 1
    private var selectedYearIndex  = 0

    
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
    
    // MARK: - Pickers
    private let categoryPicker = UIPickerView()
    private let packagingPicker = UIPickerView()
    private let allergenPicker  = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        nextButton.isHidden = true
        nextButton.alpha = 0
        styleCard(descriptionTextView)

        // Set tags (so icon tap knows which field to open)
                expiryTextField.tag = 1
                categoryTextField.tag = 2
                packagingTextField.tag = 3
                allergenTextField.tag = 4

                setupExpiryPicker()
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
    private func setupExpiryPicker() {
        expiryMonthYearPicker.delegate = self
        expiryMonthYearPicker.dataSource = self

        expiryTextField.inputView = expiryMonthYearPicker
        expiryTextField.inputAccessoryView = makeDoneToolbar(action: #selector(expiryDoneTapped))

        setRightIcon("calendar", for: expiryTextField)
        expiryTextField.tintColor = .clear

        // Start on current day/month/year
        expiryMonthYearPicker.selectRow(selectedDayIndex, inComponent: 0, animated: false)
        expiryMonthYearPicker.selectRow(selectedMonthIndex, inComponent: 1, animated: false)
        expiryMonthYearPicker.selectRow(selectedYearIndex, inComponent: 2, animated: false)

        // Optional: show initial text
        updateExpiryText()
    }

    
    @objc private func expiryDoneTapped() {
        updateExpiryText()
        view.endEditing(true)
    }

    private func updateExpiryText() {
        let day = String(format: "%02d", selectedDayIndex + 1)
            let month = String(format: "%02d", selectedMonthIndex + 1)
            let year = years[selectedYearIndex]
            expiryTextField.text = "\(day) / \(month) / \(year)"
    }
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
            view.endEditing(true)
        }
    private func makeDoneToolbar(action: Selector) -> UIToolbar {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: action)
            toolbar.setItems([flex, done], animated: false)
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

            // Use textfield tag so we know which one to open
            container.tag = textField.tag

            textField.rightView = container
            textField.rightViewMode = .always
        }
    }

    // MARK: - UIPickerView Delegate/DataSource (MUST be outside the class)
extension EnterDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == expiryMonthYearPicker { return 3 } // Day / Month / Year
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == expiryMonthYearPicker {
            if component == 0 {
                let year = years[selectedYearIndex]
                return daysCount(forMonth: selectedMonthIndex, year: year)
            } else if component == 1 {
                return months.count
            } else {
                return years.count
            }
        }
        
        if pickerView == categoryPicker { return categories.count }
        if pickerView == packagingPicker { return packagings.count }
        return allergens.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == expiryMonthYearPicker {
            if component == 0 { return String(row + 1) }     // Day
            if component == 1 { return months[row] }         // Month name
            return String(years[row])                        // Year
        }
        
        if pickerView == categoryPicker { return categories[row] }
        if pickerView == packagingPicker { return packagings[row] }
        return allergens[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == expiryMonthYearPicker {
            
            if component == 0 {
                selectedDayIndex = row
            } else if component == 1 {
                selectedMonthIndex = row
                
                // month changed -> update days
                let year = years[selectedYearIndex]
                let maxDays = daysCount(forMonth: selectedMonthIndex, year: year)
                if selectedDayIndex >= maxDays { selectedDayIndex = maxDays - 1 }
                
                expiryMonthYearPicker.reloadComponent(0)
                expiryMonthYearPicker.selectRow(selectedDayIndex, inComponent: 0, animated: true)
                
            } else {
                selectedYearIndex = row
                
                // year changed -> update days (leap year)
                let year = years[selectedYearIndex]
                let maxDays = daysCount(forMonth: selectedMonthIndex, year: year)
                if selectedDayIndex >= maxDays { selectedDayIndex = maxDays - 1 }
                
                expiryMonthYearPicker.reloadComponent(0)
                expiryMonthYearPicker.selectRow(selectedDayIndex, inComponent: 0, animated: true)
            }
            
            updateExpiryText()
            return
        }
        
        if pickerView == categoryPicker {
            categoryTextField.text = categories[row]
        } else if pickerView == packagingPicker {
            packagingTextField.text = packagings[row]
        } else {
            allergenTextField.text = allergens[row]
        }
    }
}
