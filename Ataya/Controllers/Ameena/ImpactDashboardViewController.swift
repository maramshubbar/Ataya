//
//  ImpactDashboardViewController.swift
//  Ataya
//
//  Created by Zahraa Ahmed on 23/12/2025.
//

import UIKit

class ImpactDashboardViewController: UIViewController {

    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var mealsSmallCard: UIView!
    @IBOutlet weak var wasteSmallCard: UIView!
    @IBOutlet weak var envSmallCard: UIView!
    @IBOutlet weak var impactSoFarLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

            title = "Impact Dashboard"
            navigationItem.largeTitleDisplayMode = .never

            addBigCards()
        styleSmallCards()
        fixImpactLabel()
        setupTopLabel()

    }
    
    private func setupTopLabel() {
        impactSoFarLabel.text = "Your Impact So Far...."
        impactSoFarLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        impactSoFarLabel.textColor = .black
        impactSoFarLabel.numberOfLines = 1
        impactSoFarLabel.isHidden = false
    }

    
    private func addBigCards() {

        let mealsCard = makeBigCard(
            title: "Meals Provided",
            description: "You have shared 145 meals with people in need......"
        )

        let foodWasteCard = makeBigCard(
            title: "Food Waste Prevented",
            description: "Your consistent donations have prevented 32% of food......"
        )

        let envCard = makeBigCard(
            title: "Environmental Equivalent",
            description: "Your donations didn’t just help people — they helped the environment too......"
        )

        mainStackView.addArrangedSubview(mealsCard)
        mainStackView.addArrangedSubview(foodWasteCard)
        mainStackView.addArrangedSubview(envCard)
    }
    
    private func makeBigCard(title: String, description: String) -> UIView {

        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 4)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textAlignment = .center

        let chartPlaceholder = UIView()
        chartPlaceholder.backgroundColor = UIColor.systemGray6
        chartPlaceholder.heightAnchor.constraint(equalToConstant: 260).isActive = true
        chartPlaceholder.layer.cornerRadius = 12
        card.heightAnchor.constraint(greaterThanOrEqualToConstant: 320).isActive = true
        chartPlaceholder.setContentCompressionResistancePriority(.required, for: .vertical)
        card.setContentCompressionResistancePriority(.required, for: .vertical)

        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.numberOfLines = 0

        let readMore = UIButton(type: .system)
        readMore.setTitle("Read More", for: .normal)

        let bottomRow = UIStackView(arrangedSubviews: [UIView(), readMore])
        bottomRow.axis = .horizontal

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(chartPlaceholder)
        stack.addArrangedSubview(descLabel)
        stack.addArrangedSubview(bottomRow)

        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }
    
    private func fixImpactLabel() {
        impactSoFarLabel.isHidden = false
        impactSoFarLabel.text = "Your Impact So Far...."
        impactSoFarLabel.numberOfLines = 1
    }

    private func styleSmallCards() {
        [mealsSmallCard, wasteSmallCard, envSmallCard].forEach { card in
            guard let card else { return }

            card.backgroundColor = .white
            card.layer.cornerRadius = 14

            card.layer.borderWidth = 1
            card.layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor

            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.15
            card.layer.shadowRadius = 10
            card.layer.shadowOffset = CGSize(width: 0, height: 6)

            card.layer.masksToBounds = false
        }
    }



}
