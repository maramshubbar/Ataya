//
//  ReviewPredictionViewController.swift
//  Ataya
//
//  Created by Fatema Maitham on 28/11/2025.
//
import UIKit

final class ReviewPredictionVC: UIViewController {
    
    // MARK: - Scroll + Content
    
    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.alwaysBounceVertical = true
        return s
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let stackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    // MARK: - Header
    
    private let headerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .black
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Review Prediction"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    // MARK: - Form labels + fields
    
    private func makeTitleLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .black
        return l
    }
    
    private func makeFieldContainer() -> UIView {
        let v = UIView()
        v.layer.cornerRadius = 8
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        v.backgroundColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }
    
    private func makeTextField() -> UITextField {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 14)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return tf
    }
    
    // Food Item
    private lazy var foodItemLabel = makeTitleLabel("Food Item")
    private lazy var foodItemContainer = makeFieldContainer()
    private lazy var foodItemTF: UITextField = {
        let tf = makeTextField()
        tf.text = "Baby Formula"
        return tf
    }()
    
    // Estimated Quantity
    private lazy var quantityLabel = makeTitleLabel("Estimated Quantity")
    private lazy var quantityContainer = makeFieldContainer()
    private lazy var quantityTF: UITextField = {
        let tf = makeTextField()
        tf.text = "850 grams"
        return tf
    }()
    
    // Expiry / Date
    private lazy var expiryLabel = makeTitleLabel("Expiry / Best Before Date")
    private lazy var expiryContainer = makeFieldContainer()
    private lazy var expiryTF: UITextField = {
        let tf = makeTextField()
        tf.text = "05 / 2026"
        tf.isUserInteractionEnabled = false   // we open date picker instead of typing
        return tf
    }()
    private let calendarButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "calendar"), for: .normal)
        b.tintColor = .black
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // Food Category
    private lazy var categoryLabel = makeTitleLabel("Food Category")
    private lazy var categoryContainer = makeFieldContainer()
    private lazy var categoryTF: UITextField = {
        let tf = makeTextField()
        tf.text = "Infant Nutrition"
        tf.isUserInteractionEnabled = false
        return tf
    }()
    private let categoryArrow: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.down"))
        iv.tintColor = .black
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // Packaging Type
    private lazy var packagingLabel = makeTitleLabel("Packaging Type")
    private lazy var packagingContainer = makeFieldContainer()
    private lazy var packagingTF: UITextField = {
        let tf = makeTextField()
        tf.text = "Metal Can"
        tf.isUserInteractionEnabled = false
        return tf
    }()
    private let packagingArrow: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.down"))
        iv.tintColor = .black
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // Allergen info
    private lazy var allergenLabel = makeTitleLabel("Allergen Information")
    private lazy var allergenContainer = makeFieldContainer()
    private lazy var allergenTF: UITextField = {
        let tf = makeTextField()
        tf.text = "Contains milk and soy"
        return tf
    }()
    
    // Description
    private lazy var descriptionLabel = makeTitleLabel("Description")
    private lazy var descriptionContainer: UIView = {
        let v = makeFieldContainer()
        v.heightAnchor.constraint(equalToConstant: 120).isActive = true
        return v
    }()
    private let descriptionTV: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 14)
        tv.text = "Fresh and in good condition, ready to be shared with families in need."
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // MARK: - Bottom buttons
    
    private let editManuallyButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Edit Manually", for: .normal)
        b.setTitleColor(UIColor(hex: "#F7D44C"), for: .normal)
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor(hex: "#F7D44C").cgColor
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let nextButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Next", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.backgroundColor = UIColor(hex: "#F7D44C")
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupLayout()
        setupActions()
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        // Header
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        
        // Scroll + content
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        // Bottom buttons
        view.addSubview(editManuallyButton)
        view.addSubview(nextButton)
        
        // Header constraints
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        // Bottom buttons
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 55),
            
            editManuallyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            editManuallyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            editManuallyButton.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -12),
            editManuallyButton.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        // ScrollView above buttons
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: editManuallyButton.topAnchor, constant: -16)
        ])
        
        // ContentView == scrollView width
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // StackView inside content
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
        
        // Add all fields to stackView
        addField(label: foodItemLabel, container: foodItemContainer, inner: foodItemTF)
        addField(label: quantityLabel, container: quantityContainer, inner: quantityTF)
        
        // Expiry with calendar button
        stackView.addArrangedSubview(expiryLabel)
        stackView.setCustomSpacing(8, after: expiryLabel)
        stackView.addArrangedSubview(expiryContainer)
        expiryContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        expiryContainer.addSubview(expiryTF)
        expiryContainer.addSubview(calendarButton)
        NSLayoutConstraint.activate([
            expiryTF.leadingAnchor.constraint(equalTo: expiryContainer.leadingAnchor, constant: 12),
            expiryTF.centerYAnchor.constraint(equalTo: expiryContainer.centerYAnchor),
            
            calendarButton.trailingAnchor.constraint(equalTo: expiryContainer.trailingAnchor, constant: -12),
            calendarButton.centerYAnchor.constraint(equalTo: expiryContainer.centerYAnchor),
            calendarButton.widthAnchor.constraint(equalToConstant: 24),
            calendarButton.heightAnchor.constraint(equalToConstant: 24),
            
            expiryTF.trailingAnchor.constraint(lessThanOrEqualTo: calendarButton.leadingAnchor, constant: -8)
        ])
        stackView.setCustomSpacing(16, after: expiryContainer)
        
        // Category with arrow
        addFieldWithArrow(label: categoryLabel, container: categoryContainer, tf: categoryTF, arrow: categoryArrow)
        
        // Packaging with arrow
        addFieldWithArrow(label: packagingLabel, container: packagingContainer, tf: packagingTF, arrow: packagingArrow)
        
        // Allergen
        addField(label: allergenLabel, container: allergenContainer, inner: allergenTF)
        
        // Description (UITextView)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.setCustomSpacing(8, after: descriptionLabel)
        stackView.addArrangedSubview(descriptionContainer)
        descriptionContainer.addSubview(descriptionTV)
        NSLayoutConstraint.activate([
            descriptionTV.topAnchor.constraint(equalTo: descriptionContainer.topAnchor, constant: 8),
            descriptionTV.leadingAnchor.constraint(equalTo: descriptionContainer.leadingAnchor, constant: 12),
            descriptionTV.trailingAnchor.constraint(equalTo: descriptionContainer.trailingAnchor, constant: -12),
            descriptionTV.bottomAnchor.constraint(equalTo: descriptionContainer.bottomAnchor, constant: -8)
        ])
    }
    
    private func addField(label: UILabel, container: UIView, inner: UIView) {
        stackView.addArrangedSubview(label)
        stackView.setCustomSpacing(8, after: label)
        stackView.addArrangedSubview(container)
        container.heightAnchor.constraint(equalToConstant: 50).isActive = true
        container.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            inner.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            inner.topAnchor.constraint(equalTo: container.topAnchor),
            inner.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        stackView.setCustomSpacing(16, after: container)
    }
    
    private func addFieldWithArrow(label: UILabel, container: UIView, tf: UITextField, arrow: UIImageView) {
        stackView.addArrangedSubview(label)
        stackView.setCustomSpacing(8, after: label)
        stackView.addArrangedSubview(container)
        container.heightAnchor.constraint(equalToConstant: 50).isActive = true
        container.addSubview(tf)
        container.addSubview(arrow)
        NSLayoutConstraint.activate([
            arrow.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            arrow.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            arrow.widthAnchor.constraint(equalToConstant: 16),
            arrow.heightAnchor.constraint(equalToConstant: 16),
            
            tf.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            tf.trailingAnchor.constraint(lessThanOrEqualTo: arrow.leadingAnchor, constant: -8),
            tf.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        stackView.setCustomSpacing(16, after: container)
    }
    
    // MARK: - Actions
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        calendarButton.addTarget(self, action: #selector(expiryTapped), for: .touchUpInside)
        editManuallyButton.addTarget(self, action: #selector(editManuallyTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // Bottom-sheet style date picker using pageSheet
    @objc private func expiryTapped() {
        let pickerVC = UIViewController()
        pickerVC.view.backgroundColor = .systemBackground
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        pickerVC.view.addSubview(datePicker)
        pickerVC.view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: pickerVC.view.topAnchor, constant: 12),
            doneButton.trailingAnchor.constraint(equalTo: pickerVC.view.trailingAnchor, constant: -16),
            
            datePicker.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: pickerVC.view.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: pickerVC.view.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: pickerVC.view.bottomAnchor)
        ])
        
        doneButton.addAction(UIAction { [weak self, weak pickerVC] _ in
            guard let self = self else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "MM / yyyy"
            self.expiryTF.text = formatter.string(from: datePicker.date)
            pickerVC?.dismiss(animated: true)
        }, for: .touchUpInside)
        
        pickerVC.modalPresentationStyle = .pageSheet   // iOS bottom sheet style
        present(pickerVC, animated: true)
    }
    
    @objc private func editManuallyTapped() {
        let vc = EditManuallyVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func nextTapped() {
        print("Next tapped from ReviewPredictionVC")
    }
}
