////
////  CampaignManagementVC.swift
////  Ataya
////
////  Created by Maram on 29/11/2025.
////
//import UIKit
//
//class CampaignManagementViewController: UIViewController, UINavigationControllerDelegate {
//
//    // ----------------------------------------------------
//    // MARK: - Public Data (Real data will come from outside)
//    // ----------------------------------------------------
//    var campaigns: [CampaignData] = []
//
//    // ----------------------------------------------------
//    // MARK: - UI Elements
//    // ----------------------------------------------------
//
//    private let scrollView = UIScrollView()
//    private let contentStack = UIStackView()
//
//    private let createButton: UIButton = {
//        let btn = UIButton(type: .system)
//        btn.setTitle("Create Campaign", for: .normal)
//        btn.backgroundColor = UIColor(red: 0.96, green: 0.82, blue: 0.20, alpha: 1)
//        btn.setTitleColor(.black, for: .normal)
//        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
//        btn.layer.cornerRadius = 8
//        return btn
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
//        setupScrollView()
//        setupContent()
//        loadCampaigns()
//
//        navigationController?.delegate = self
//
//        createButton.addTarget(self, action: #selector(openCreateCampaign), for: .touchUpInside)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // 🔥 Hide the blue iOS navigation bar
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
//        // Custom Back Button
//        let backBtn = UIButton(type: .system)
//        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//        backBtn.tintColor = .black
//        backBtn.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
//
//        // Title
//        let titleLabel = UILabel()
//        titleLabel.text = "Campaign Management"
//        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//        titleLabel.textAlignment = .center
//
//        // Share icon
//        let shareBtn = UIButton(type: .system)
//        shareBtn.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
//        shareBtn.tintColor = .black
//
//        header.addSubview(backBtn)
//        header.addSubview(titleLabel)
//        header.addSubview(shareBtn)
//
//        backBtn.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        shareBtn.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            backBtn.leadingAnchor.constraint(equalTo: header.leadingAnchor),
//            backBtn.centerYAnchor.constraint(equalTo: header.centerYAnchor),
//            backBtn.widthAnchor.constraint(equalToConstant: 28),
//            backBtn.heightAnchor.constraint(equalToConstant: 28),
//
//            shareBtn.trailingAnchor.constraint(equalTo: header.trailingAnchor),
//            shareBtn.centerYAnchor.constraint(equalTo: header.centerYAnchor),
//            shareBtn.widthAnchor.constraint(equalToConstant: 28),
//            shareBtn.heightAnchor.constraint(equalToConstant: 28),
//
//            titleLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor),
//            titleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor)
//        ])
//    }
//
//    @objc private func handleBack() {
//        navigationController?.popViewController(animated: true)
//    }
//
//    // ----------------------------------------------------
//    // MARK: - ScrollView
//    // ----------------------------------------------------
//
//    private func setupScrollView() {
//
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
//    // ----------------------------------------------------
//    // MARK: - Content Stack
//    // ----------------------------------------------------
//
//    private func setupContent() {
//
//        contentStack.axis = .vertical
//        contentStack.spacing = 20
//        contentStack.translatesAutoresizingMaskIntoConstraints = false
//
//        scrollView.addSubview(contentStack)
//
//        NSLayoutConstraint.activate([
//            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
//            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
//            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
//            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
//        ])
//
//        contentStack.addArrangedSubview(createButton)
//        createButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
//    }
//
//    // ----------------------------------------------------
//    // MARK: - Load Data
//    // ----------------------------------------------------
//
//    private func loadCampaigns() {
//        guard !campaigns.isEmpty else { return }
//
//        for item in campaigns {
//            let card = CampaignCardView()
//            card.configure(with: item)
//            contentStack.addArrangedSubview(card)
//        }
//    }
//
//    // ----------------------------------------------------
//    // MARK: - Open Create Campaign (Push with animation)
//    // ----------------------------------------------------
//
//    @objc private func openCreateCampaign() {
//        let vc = CreateCampaignViewController()
//        navigationController?.pushViewController(vc, animated: true)
//    }
//
//    // ----------------------------------------------------
//    // MARK: - Custom Ease-Out Transition
//    // ----------------------------------------------------
//
//    func navigationController(
//        _ navigationController: UINavigationController,
//        animationControllerFor operation: UINavigationController.Operation,
//        from fromVC: UIViewController,
//        to toVC: UIViewController
//    ) -> UIViewControllerAnimatedTransitioning? {
//
//        if operation == .push {
//            return PushEaseOutAnimator()
//        }
//        return nil
//    }
//}
//
//// ----------------------------------------------------
//// MARK: - Animator (Ease-Out)
//// ----------------------------------------------------
//
//class PushEaseOutAnimator: NSObject, UIViewControllerAnimatedTransitioning {
//
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return 0.30 // 300ms — Figma perfect
//    }
//
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//
//        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
//
//        let container = transitionContext.containerView
//        let duration = transitionDuration(using: transitionContext)
//
//        toVC.view.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width * 0.30, y: 0)
//        toVC.view.alpha = 0.0
//
//        container.addSubview(toVC.view)
//
//        UIView.animate(
//            withDuration: duration,
//            delay: 0,
//            options: .curveEaseOut,
//            animations: {
//                toVC.view.transform = .identity
//                toVC.view.alpha = 1.0
//            },
//            completion: { finished in
//                transitionContext.completeTransition(finished)
//            }
//        )
//    }
//}
