//
//  AIAnalyzingVC.swift
//  Ataya
//
//  Created by Fatema Maitham on 2025-11-28.
//  Screen: AI Analyzing (loading + finished state in ONE page)
//

import UIKit

class AIAnalyzingVC: UIViewController {
    
    // MARK: - UI State
    
    /// Two visual states for this screen.
    /// Both are shown in the SAME view controller.
    private enum ScreenState {
        case analyzing   // spinner + "This might take a few moments.."
        case finished    // text updated + Next button visible
    }
    
    /// Current screen state. Whenever it changes we update the UI.
    private var screenState: ScreenState = .analyzing {
        didSet { updateUIForState() }
    }
    
    // MARK: - Header Views
    
    /// Container for the top header (back button + title).
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Back button (chevron-left SF Symbol).
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// Title label: "AI Analyzing"
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "AI Analyzing"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Illustration
    
    /// Big robot illustration from Assets.xcassets (name: ai_robot)
    private let robotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ai_robot")   // make sure asset name = ai_robot
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Text Content
    
    /// Bold heading under the image.
    private let headingLabel: UILabel = {
        let label = UILabel()
        label.text = "Analyzing your photo using AI"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Gray paragraph text (changes between analyzing/finished).
    private let paragraphLabel: UILabel = {
        let label = UILabel()
        label.text = """
        Analyzing your photo to identify food item, quantity, expiry date, category, and allergen details.
        """
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0    // allow multiple lines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Loading Views (Analyzing state)
    
    /// Center spinner shown while analyzing.
    private let loadingIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = false   // we control visibility manually
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    /// Small hint text: "This might take a few moments .."
    private let loadingHintLabel: UILabel = {
        let label = UILabel()
        label.text = "This might take a few moments .."
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Bottom Button (Finished state)
    
    /// Yellow "Next" button fixed at the bottom.
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(hex: "#F7D44C")   // Ataya yellow
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true      // start hidden in Analyzing state
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Base background
        view.backgroundColor = .white
        
        // Build hierarchy + constraints
        setupLayout()
        
        // Configure targets
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        // Start in "analyzing" state
        screenState = .analyzing
        
        // Simulate AI response after a few seconds.
        // In real app, replace with your network / AWS callback.
        simulateAICall()
    }
    
    // MARK: - Layout
    
    /// Adds subviews and activates all Auto Layout constraints.
    private func setupLayout() {
        
        // 1. Add header container
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        
        // 2. Add main content
        view.addSubview(robotImageView)
        view.addSubview(headingLabel)
        view.addSubview(paragraphLabel)
        view.addSubview(loadingIndicator)
        view.addSubview(loadingHintLabel)
        
        // 3. Add bottom button
        view.addSubview(nextButton)
        
        // MARK: Header constraints
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
        
        // MARK: Illustration constraints
        NSLayoutConstraint.activate([
            robotImageView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 40),
            robotImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            robotImageView.widthAnchor.constraint(equalToConstant: 260),
            robotImageView.heightAnchor.constraint(equalToConstant: 260)
        ])
        
        // MARK: Text constraints
        NSLayoutConstraint.activate([
            headingLabel.topAnchor.constraint(equalTo: robotImageView.bottomAnchor, constant: 20),
            headingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            paragraphLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 10),
            paragraphLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            paragraphLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
        
        // MARK: Loading views constraints
        NSLayoutConstraint.activate([
            loadingIndicator.topAnchor.constraint(equalTo: paragraphLabel.bottomAnchor, constant: 30),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            loadingHintLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 8),
            loadingHintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // MARK: Bottom button constraints
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    // MARK: - State Handling
    
    /// Updates which elements are visible depending on the current screen state.
    private func updateUIForState() {
        switch screenState {
        case .analyzing:
            // Loading visible
            loadingIndicator.isHidden = false
            loadingHintLabel.isHidden = false
            loadingIndicator.startAnimating()
            
            // Next button hidden + paragraph text = analyzing message
            nextButton.isHidden = true
            paragraphLabel.text = """
            Analyzing your photo to identify food item, quantity, expiry date, category, and allergen details.
            """
            
        case .finished:
            // Stop and hide loader
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
            loadingHintLabel.isHidden = true
            
            // Update paragraph message to result text
            paragraphLabel.text = """
            The AI has detected your food details. Please review before proceeding.
            """
            
            // Show Next button
            nextButton.isHidden = false
        }
    }
    
    /// Simulates the AI process. After 3 seconds it switches state to `.finished`.
    /// In the real app, you should call `screenState = .finished`
    /// inside your actual AI/completion handler instead.
    private func simulateAICall() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.screenState = .finished
        }
    }
    
    // MARK: - Actions
    
    /// Handles tap on the back button.
    @objc private func backButtonTapped() {
        // If embedded in navigation controller, pop.
        navigationController?.popViewController(animated: true)
    }
    
    /// Handles tap on the Next button.
    @objc private func nextButtonTapped() {
        let vc = ReviewPredictionVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UIColor helper (hex string → UIColor)
extension UIColor {
    /// Initialize a UIColor using a hex string like "#FEC400" or "FEC400".
    convenience init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgb)
        
        let red   = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8)  / 255.0
        let blue  = CGFloat(rgb & 0x0000FF)         / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
