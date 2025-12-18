//
//  EditManuallyVC.swift
//  Ataya
//
//  Created by Fatema Maitham on 28/11/2025.
//

import UIKit

final class EditManuallyVC: UIViewController {
    
    // Reuse exactly same structure as ReviewPredictionVC,
    // but with different title + bottom buttons text.
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private let headerView = UIView()
    private let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .black
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Edit Manually"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private func makeTitleLabel(_ t: String) -> UILabel {
        let l = UILabel()
        l.text = t
        l.font = .systemFont(ofSize: 13, weight: .semibold)
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
        tf.font = .systemFont(ofSize: 14)
        tf.borderStyle = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }
    
    // Fields (same as before)
    private lazy var foodItemLabel = makeTitleLabel("Food Item")
    private lazy var foodItemContainer = makeFieldContainer()
    private lazy var foodItemTF: UITextField = {
        let tf = makeTextField()
        tf.text = "Baby Formula"
        return tf
    }()
    
    private lazy var quantityLabel = makeTitleLabel("Estimated Quantity")
    private lazy var quantityContainer = makeFieldContainer()
    private lazy var quantityTF: UITextField = {
        let tf = makeTextField()
        tf.text = "850 grams"
        return tf
    }()
    
    private lazy var expiryLabel = makeTitleLabel("Expiry / Best Before Date")
    private lazy var expiryContainer = makeFieldContainer()
    private lazy var expiryTF: UITextField = {
        let tf = makeTextField()
        tf.text = "04 / 2026"
        tf.isUserInteractionEnabled = false
        return tf
    }()
    private let calendarButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "calendar"), for: .normal)
        b.tintColor = .black
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private lazy var categoryLabel = makeTitleLabel("Food Category")
    private lazy var categoryContainer = makeFieldContainer()
    private lazy var categoryTF: UITextField = {
        let tf = makeTextField()
        tf.text = "Infant Nutrition"
        return tf
    }()
    
    private lazy var packagingLabel = makeTitleLabel("Packaging Type")
    private lazy var packagingContainer = makeFieldContainer()
    private lazy var packagingTF: UITextField = {
        let tf = makeTextField()
        tf.text = "Metal Can"
        return tf
    }()
    
    private lazy var allergenLabel = makeTitleLabel("Allergen Information")
    private lazy var allergenContainer = makeFieldContainer()
    private lazy var allergenTF: UITextField = {
        let tf = makeTextField()
        tf.text = "Contains milk and soy"
        return tf
    }()
    
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
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        return tv
    }()
    
    // Bottom buttons
    private let cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Cancel", for: .normal)
        b.setTitleColor(UIColor(hex: "#F7D44C"), for: .normal)
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor(hex: "#F7D44C").cgColor
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Save Changes", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.backgroundColor = UIColor(hex: "#F7D44C")
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupLayout()
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        calendarButton.addTarget(self, action: #selector(expiryTapped), for: .touchUpInside)
    }
    
    private func setupLayout() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        view.addSubview(cancelButton)
        view.addSubview(saveButton)
        
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
        
        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 55),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -12),
            cancelButton.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
        
        func addField(label: UILabel, container: UIView, inner: UIView) {
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
        
        addField(label: foodItemLabel, container: foodItemContainer, inner: foodItemTF)
        addField(label: quantityLabel, container: quantityContainer, inner: quantityTF)
        
        stackView.addArrangedSubview(expiryLabel)
        stackView.setCustomSpacing(8, after: expiryLabel)
        stackView.addArrangedSubview(expiryContainer)
        expiryContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        expiryContainer.addSubview(expiryTF)
        expiryContainer.addSubview(calendarButton)
        NSLayoutConstraint.activate([
            calendarButton.trailingAnchor.constraint(equalTo: expiryContainer.trailingAnchor, constant: -12),
            calendarButton.centerYAnchor.constraint(equalTo: expiryContainer.centerYAnchor),
            calendarButton.widthAnchor.constraint(equalToConstant: 24),
            calendarButton.heightAnchor.constraint(equalToConstant: 24),
            
            expiryTF.leadingAnchor.constraint(equalTo: expiryContainer.leadingAnchor, constant: 12),
            expiryTF.trailingAnchor.constraint(lessThanOrEqualTo: calendarButton.leadingAnchor, constant: -8),
            expiryTF.centerYAnchor.constraint(equalTo: expiryContainer.centerYAnchor)
        ])
        stackView.setCustomSpacing(16, after: expiryContainer)
        
        addField(label: categoryLabel, container: categoryContainer, inner: categoryTF)
        addField(label: packagingLabel, container: packagingContainer, inner: packagingTF)
        addField(label: allergenLabel, container: allergenContainer, inner: allergenTF)
        
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
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }
    @objc private func saveTapped() {
        print("Save Changes tapped")
    }
    @objc private func expiryTapped() {
        // Reuse same pageSheet date picker logic as ReviewPredictionVC if you want.
        print("Show date picker here")
    }
}
