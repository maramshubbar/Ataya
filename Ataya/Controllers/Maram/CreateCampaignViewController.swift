////
////  CreateCampaignViewController.swift
////  Ataya
////
////  Created by Maram on 29/11/2025.
////
//
//import UIKit
//
//
//class CreateCampaignViewController: UIViewController {
//
//    // ----------------------------------------------------
//    // MARK: - UI Elements
//    // ----------------------------------------------------
//
//    private let scrollView = UIScrollView()
//    private let contentStack = UIStackView()
//
//    // MARK: - Field Builder
//    private func makeField(_ placeholder: String) -> UITextField {
//        let tf = UITextField()
//        tf.placeholder = placeholder
//        tf.font = .systemFont(ofSize: 15)
//        tf.layer.borderWidth = 1
//        tf.layer.borderColor = UIColor.systemGray4.cgColor
//        tf.layer.cornerRadius = 8
//        tf.setLeftPaddingPoints(12)
//        tf.heightAnchor.constraint(equalToConstant: 48).isActive = true
//        return tf
//    }
//
//    // MARK: - Fields
//    private lazy var titleField       = makeField("Title")
//    private lazy var categoryField    = makeField("Category")
//    private lazy var goalField        = makeField("Goal Amount")
//    private lazy var startDateField   = makeField("Start Date")
//    private lazy var endDateField     = makeField("End Date")
//    private lazy var locationField    = makeField("Location")
//    private lazy var fromField        = makeField("From")
//    private lazy var orgField         = makeField("Organization / NGO")
//
//    private let overviewText = UITextView()
//    private let storyText    = UITextView()
//    private let homeToggle   = UISwitch()
//
//    // ----------------------------------------------------
//    // MARK: - Upload Box (Full Width)
//    // ----------------------------------------------------
//
//    private let uploadContainer: UIView = {
//        let v = UIView()
//        v.translatesAutoresizingMaskIntoConstraints = false
//        return v
//    }()
//
//    private let uploadView: UIImageView = {
//        let img = UIImageView(image: UIImage(named: "upload_placeholder"))
//        img.contentMode = .scaleAspectFill
//        img.clipsToBounds = true
//        img.layer.cornerRadius = 12
//        img.translatesAutoresizingMaskIntoConstraints = false
//        return img
//    }()
//
//    // ----------------------------------------------------
//    // MARK: - Buttons
//    // ----------------------------------------------------
//
//    private let cancelButton: UIButton = {
//        let b = UIButton(type: .system)
//        b.setTitle("Cancel", for: .normal)
//        b.setTitleColor(.black, for: .normal)
//        b.layer.borderWidth = 1
//        b.layer.cornerRadius = 8
//        b.layer.borderColor = UIColor(red: 0.96, green: 0.82, blue: 0.20, alpha: 1).cgColor
//        b.heightAnchor.constraint(equalToConstant: 48).isActive = true
//        return b
//    }()
//
//    private let createButton: UIButton = {
//        let b = UIButton(type: .system)
//        b.setTitle("Create Campaign", for: .normal)
//        b.setTitleColor(.black, for: .normal)
//        b.backgroundColor = UIColor(red: 0.96, green: 0.82, blue: 0.20, alpha: 1)
//        b.layer.cornerRadius = 8
//        b.heightAnchor.constraint(equalToConstant: 48).isActive = true
//        return b
//    }()
//
//    // ----------------------------------------------------
//    // MARK: - Lifecycle
//    // ----------------------------------------------------
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//
//        buildHeader()
//        setupScroll()
//        setupContent()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        navigationController?.setNavigationBarHidden(true, animated: false)
//    }
//
//    // ----------------------------------------------------
//    // MARK: - Header
//    // ----------------------------------------------------
//
//    private func buildHeader() {
//
//        let header = UIView()
//        header.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(header)
//
//        NSLayoutConstraint.activate([
//            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            header.heightAnchor.constraint(equalToConstant: 48)
//        ])
//
//        let backBtn = UIButton(type: .system)
//        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//        backBtn.tintColor = .black
//        backBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
//
//        let titleLabel = UILabel()
//        titleLabel.text = "Create Campaign"
//        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
//        titleLabel.textAlignment = .center
//
//        header.addSubview(backBtn)
//        header.addSubview(titleLabel)
//
//        backBtn.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            backBtn.leadingAnchor.constraint(equalTo: header.leadingAnchor),
//            backBtn.centerYAnchor.constraint(equalTo: header.centerYAnchor),
//            backBtn.widthAnchor.constraint(equalToConstant: 28),
//            backBtn.heightAnchor.constraint(equalToConstant: 28),
//
//            titleLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor),
//            titleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor)
//        ])
//    }
//
//    @objc private func goBack() {
//        navigationController?.popViewController(animated: true)
//    }
//
//    // ----------------------------------------------------
//    // MARK: - ScrollView + Content
//    // ----------------------------------------------------
//
//    private func setupScroll() {
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(scrollView)
//
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//
//    private func setupContent() {
//
//        contentStack.axis = .vertical
//        contentStack.spacing = 16
//        contentStack.translatesAutoresizingMaskIntoConstraints = false
//
//        scrollView.addSubview(contentStack)
//
//        NSLayoutConstraint.activate([
//            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
//            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
//            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
//            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
//        ])
//
//        // Fields
//        contentStack.addArrangedSubview(titleField)
//        contentStack.addArrangedSubview(categoryField)
//        contentStack.addArrangedSubview(goalField)
//        contentStack.addArrangedSubview(startDateField)
//        contentStack.addArrangedSubview(endDateField)
//        contentStack.addArrangedSubview(locationField)
//
//        // ----------------------------------------------------
//        // MARK: Upload Box — FULL WIDTH FIX
//        // ----------------------------------------------------
//
//        contentStack.addArrangedSubview(uploadContainer)
//        uploadContainer.addSubview(uploadView)
//
//        NSLayoutConstraint.activate([
//            uploadView.topAnchor.constraint(equalTo: uploadContainer.topAnchor),
//            uploadView.leadingAnchor.constraint(equalTo: uploadContainer.leadingAnchor),
//            uploadView.trailingAnchor.constraint(equalTo: uploadContainer.trailingAnchor),
//            uploadView.bottomAnchor.constraint(equalTo: uploadContainer.bottomAnchor),
//
//            uploadContainer.heightAnchor.constraint(equalToConstant: 200)
//        ])
//
//        // Overview
//        setupTextArea(overviewText)
//        contentStack.addArrangedSubview(overviewText)
//
//        // Story
//        setupTextArea(storyText)
//        contentStack.addArrangedSubview(storyText)
//
//        // Other fields
//        contentStack.addArrangedSubview(fromField)
//        contentStack.addArrangedSubview(orgField)
//
//        // Toggle Row
//        let toggleRow = UIStackView(arrangedSubviews: [
//            UILabel(text: "Show on Home Page"),
//            homeToggle
//        ])
//        toggleRow.axis = .horizontal
//        toggleRow.distribution = .equalSpacing
//
//        contentStack.addArrangedSubview(toggleRow)
//
//        // Buttons
//        contentStack.addArrangedSubview(cancelButton)
//        contentStack.addArrangedSubview(createButton)
//    }
//
//    private func setupTextArea(_ tv: UITextView) {
//        tv.layer.borderWidth = 1
//        tv.layer.borderColor = UIColor.systemGray4.cgColor
//        tv.layer.cornerRadius = 8
//        tv.font = .systemFont(ofSize: 15)
//        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
//        tv.heightAnchor.constraint(equalToConstant: 150).isActive = true
//    }
//}
