//
//  CampaignCardView.swift
//  Ataya
//
//  Created by Maram on 29/11/2025.
//

import UIKit

// ----------------------------------------------------
// MARK: - Data Model for Card
// ----------------------------------------------------

struct CampaignData {
    let imageName: String
    let title: String
    let amount: String
    let location: String
    let desc: String
}

// ----------------------------------------------------
// MARK: - Campaign Card UI Component
// ----------------------------------------------------

class CampaignCardView: UIView {

    // ----------------------------------------------------
    // MARK: - UI Elements
    // ----------------------------------------------------

    private let img = UIImageView()
    private let titleLabel = UILabel()
    private let amountLabel = UILabel()
    private let locationLabel = UILabel()
    private let descLabel = UILabel()

    private let editButton = UIButton(type: .system)
    private let viewButton = UIButton(type: .system)

    // ----------------------------------------------------
    // MARK: - Init
    // ----------------------------------------------------

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCard()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // ----------------------------------------------------
    // MARK: - Card Layout Setup
    // ----------------------------------------------------

    private func setupCard() {

        // CARD APPEARANCE ---------------------------------
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        backgroundColor = .white

        // MAIN STACK --------------------------------------
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])

        // TOP ROW: Image + Text ---------------------------

        img.contentMode = .scaleAspectFill
        img.layer.cornerRadius = 8
        img.clipsToBounds = true
        img.widthAnchor.constraint(equalToConstant: 90).isActive = true
        img.heightAnchor.constraint(equalToConstant: 90).isActive = true

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 4

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        amountLabel.font = .systemFont(ofSize: 13)
        amountLabel.textColor = .darkGray

        locationLabel.font = .systemFont(ofSize: 13)
        locationLabel.textColor = .gray

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(amountLabel)
        textStack.addArrangedSubview(locationLabel)

        let topRow = UIStackView(arrangedSubviews: [img, textStack])
        topRow.axis = .horizontal
        topRow.spacing = 12

        // DESCRIPTION -------------------------------------

        descLabel.font = .systemFont(ofSize: 13)
        descLabel.numberOfLines = 0
        descLabel.textColor = .black

        // BUTTONS -----------------------------------------

        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(.black, for: .normal)
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = UIColor(red: 0.96, green: 0.82, blue: 0.20, alpha: 1).cgColor
        editButton.layer.cornerRadius = 6
        editButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

        viewButton.setTitle("View", for: .normal)
        viewButton.setTitleColor(.black, for: .normal)
        viewButton.backgroundColor = UIColor(red: 0.96, green: 0.82, blue: 0.20, alpha: 1)
        viewButton.layer.cornerRadius = 6
        viewButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let buttonsRow = UIStackView(arrangedSubviews: [editButton, viewButton])
        buttonsRow.axis = .horizontal
        buttonsRow.spacing = 12
        buttonsRow.distribution = .fillEqually

        // ADD EVERYTHING TO MAIN STACK --------------------

        mainStack.addArrangedSubview(topRow)
        mainStack.addArrangedSubview(descLabel)
        mainStack.addArrangedSubview(buttonsRow)
    }

    // ----------------------------------------------------
    // MARK: - Fill Card Data
    // ----------------------------------------------------

    func configure(with data: CampaignData) {
        img.image = UIImage(named: data.imageName)
        titleLabel.text = data.title
        amountLabel.text = data.amount
        locationLabel.text = data.location
        descLabel.text = data.desc
    }
}
