//
//  InspectDonationViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 18/12/2025.
//

import UIKit

class InspectDonationViewController: UIViewController {
    @IBOutlet weak var photoCardView: UIView!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var reasonSectionStack: UIStackView!
    @IBOutlet weak var descriptionSectionStack: UIStackView!
    @IBOutlet weak var reasonTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var confirmButton: UIView!
    
    private let yellow = UIColor(red: 255/255, green: 216/255, blue: 63/255, alpha: 1) // #FFD83F
       private let ringGray = UIColor.systemGray3

       private enum Decision { case reject, accept }
       private var decision: Decision = .reject { didSet { updateRadioUI() } }

    private let rejectReasons = [
        "Expired or past best-before date",
        "Spoiled / unsafe appearance or smell",
        "Damaged or leaking packaging",
        "Opened or tampered item",
        "Contamination risk",
        "Unsafe storage temperature",
        "Missing or unclear label / allergen info",
        "Pickup issue (cannot reach donor/location)",
        "Other"
    ]

    private let reasonPicker = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRadioButtons()
        setupReasonDropdown()
        updateRadioUI()
        styleCard(photoCardView)
        
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        
        confirmButton.setContentHuggingPriority(.required, for: .vertical)
        confirmButton.setContentCompressionResistancePriority(.required, for: .vertical)

    }

    private func setupRadioButtons() {
           configure(button: rejectButton)
           configure(button: acceptButton)
       }
    
    private func styleCard(_ v: UIView) {
        v.backgroundColor = .white
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
        v.clipsToBounds = true
    }
    
    private func configure(button: UIButton) {

        var config = UIButton.Configuration.plain()

        // نفس ستايل النص
        config.baseForegroundColor = .label

        // نخلي الأيقونة والنص على نفس الخط تمامًا
        config.contentInsets = .zero
        config.titlePadding = 8

        // نخلي المحاذاة يسار
        config.titleAlignment = .leading

        // نثبت ارتفاع موحد للزر
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true

        // نحتفظ بعنوان الستوريبورد
        if let t = button.title(for: .normal) {
            config.title = t
        }

        button.configuration = config
        button.contentHorizontalAlignment = .left
    }


    private func updateRadioUI() {
        setRadio(rejectButton, selected: decision == .reject)
        setRadio(acceptButton, selected: decision == .accept)
        
        // ✅ SHOW only on Reject
        let isReject = (decision == .reject)
        reasonSectionStack.isHidden = !isReject
        descriptionSectionStack.isHidden = !isReject
        descriptionTextView.backgroundColor = .white
        descriptionTextView.layer.cornerRadius = 12
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.systemGray5.cgColor
        descriptionTextView.clipsToBounds = true

        descriptionTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        descriptionTextView.font = .systemFont(ofSize: 16)
        
                
        
        // ✅ If Accept: clear + close keyboard
        if !isReject {
            reasonTextField.text = ""
            descriptionTextView.text = ""
            view.endEditing(true)
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
        
        private func setRadio(_ button: UIButton, selected: Bool) {
            guard var config = button.configuration else { return }
            config.image = radioImage(isSelected: selected)
            button.configuration = config
        }
    // ✅ 1) Setup reason dropdown like EnterDetails
    private func setupReasonDropdown() {
        reasonPicker.delegate = self
        reasonPicker.dataSource = self

        reasonTextField.inputView = reasonPicker
        reasonTextField.inputAccessoryView = makeDoneToolbar(action: #selector(closePicker))

        setRightIcon("chevron.down", for: reasonTextField)
        reasonTextField.tintColor = .clear
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
        reasonTextField.becomeFirstResponder()
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

        textField.rightView = container
        textField.rightViewMode = .always
    }


        // ✅ Fixed-size image (never shrinks)
        private func radioImage(isSelected: Bool) -> UIImage? {
                let size = CGSize(width: 24, height: 24)
                let renderer = UIGraphicsImageRenderer(size: size)


            return renderer.image { _ in
                let ringConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
                let ring = UIImage(systemName: "circle", withConfiguration: ringConfig)?
                    .withTintColor(ringGray, renderingMode: .alwaysOriginal)
                ring?.draw(in: CGRect(origin: .zero, size: size))

                if isSelected {
                    let dotSize: CGFloat = 10
                    let dotConfig = UIImage.SymbolConfiguration(pointSize: dotSize, weight: .regular)
                    let dot = UIImage(systemName: "circle.fill", withConfiguration: dotConfig)?
                        .withTintColor(yellow, renderingMode: .alwaysOriginal)

                    let dotRect = CGRect(x: (size.width - dotSize)/2,
                                         y: (size.height - dotSize)/2,
                                         width: dotSize,
                                         height: dotSize)
                    dot?.draw(in: dotRect)
                }
            }
        }

    @IBAction func rejectTapped(_ sender: UIButton) { decision = .reject }
    @IBAction func acceptTapped(_ sender: UIButton) { decision = .accept }
}
extension InspectDonationViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        rejectReasons.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        rejectReasons[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        reasonTextField.text = rejectReasons[row]
    }
}
