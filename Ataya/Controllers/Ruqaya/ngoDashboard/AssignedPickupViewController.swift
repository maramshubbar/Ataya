//
//  AssignedPickupViewController.swift
//  Ataya
//
//  Created by Ruqaya Habib on 30/12/2025.
//

import UIKit

final class AssignedPickupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var item: AssignedPickupItem?

       override func viewDidLoad() {
           super.viewDidLoad()

           title = "Assigned Pickup"
           navigationItem.largeTitleDisplayMode = .never
           view.backgroundColor = .systemGroupedBackground

           tableView.dataSource = self
           tableView.delegate = self
           tableView.separatorStyle = .none
           tableView.backgroundColor = .systemGroupedBackground

           tableView.rowHeight = 250
           tableView.estimatedRowHeight = 250

           tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
           
           view.backgroundColor = .white
           tableView.backgroundColor = .white
           
           tableView.contentInset.bottom = 80
           tableView.verticalScrollIndicatorInsets.bottom = 80


           
       }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }

       func numberOfSections(in tableView: UITableView) -> Int { 1 }
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 3 }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

           let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
           cell.selectionStyle = .none
           cell.backgroundColor = .clear

           cell.contentView.subviews.forEach { $0.removeFromSuperview() }

           guard let item else { return cell }

           let card = makeCard()
           cell.contentView.addSubview(card)

           NSLayoutConstraint.activate([
               card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
               card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
               card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
               card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10)
           ])

           switch indexPath.row {
           case 0: configureDonationDetails(card: card, item: item)
           case 1: configureDonorInfo(card: card, item: item)
           default: configurePickupInfo(card: card, item: item)
           }

           return cell
       }

       private func makeCard() -> UIView {
           let v = UIView()
           v.translatesAutoresizingMaskIntoConstraints = false
           v.backgroundColor = .white
           v.layer.cornerRadius = 8
           v.layer.borderWidth = 1
           v.layer.borderColor = UIColor.systemGray5.cgColor
           return v
       }

       private func makeHeader(title: String, statusText: String? = nil) -> UIView {
           let container = UIView()
           container.translatesAutoresizingMaskIntoConstraints = false

           let titleLabel = UILabel()
           titleLabel.translatesAutoresizingMaskIntoConstraints = false
           titleLabel.text = title
           titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)

           container.addSubview(titleLabel)

           var constraints: [NSLayoutConstraint] = [
               titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
               titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
               titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
           ]

           if let statusText {
               let badge = UILabel()
               badge.translatesAutoresizingMaskIntoConstraints = false
               badge.text = statusText
               badge.font = .systemFont(ofSize: 12, weight: .bold)
               badge.textAlignment = .center
               badge.backgroundColor = UIColor(red: 1, green: 251/255, blue: 204/255, alpha: 1) // FFFBCC
               badge.layer.cornerRadius = 8
               badge.clipsToBounds = true

               container.addSubview(badge)

               constraints += [
                   badge.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                   badge.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
                   badge.widthAnchor.constraint(equalToConstant: 99),
                   badge.heightAnchor.constraint(equalToConstant: 28.52),
                   titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: badge.leadingAnchor, constant: -10)
               ]
           } else {
               constraints += [ titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor) ]
           }

           NSLayoutConstraint.activate(constraints)
           return container
       }

    private func makeKeyValueRow(key: String, value: String) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let k = UILabel()
        k.translatesAutoresizingMaskIntoConstraints = false
        k.text = key
        k.font = .systemFont(ofSize: 12, weight: .regular)
        k.textColor = .systemGray
        k.setContentHuggingPriority(.required, for: .horizontal)
        k.setContentCompressionResistancePriority(.required, for: .horizontal)

        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.text = value
        v.font = .systemFont(ofSize: 12, weight: .regular)
        v.textColor = .black
        v.numberOfLines = 0
        v.textAlignment = .left

        row.addSubview(k)
        row.addSubview(v)

        NSLayoutConstraint.activate([
            k.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            k.topAnchor.constraint(equalTo: row.topAnchor),
            k.bottomAnchor.constraint(equalTo: row.bottomAnchor),

            v.leadingAnchor.constraint(equalTo: k.trailingAnchor, constant: 10),
            v.topAnchor.constraint(equalTo: row.topAnchor),
            v.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            v.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor)
        ])

        return row
    }


       private func configureDonationDetails(card: UIView, item: AssignedPickupItem) {
           let header = makeHeader(title: "Donation Details", statusText: item.status)

           let imageView = UIImageView(image: UIImage(named: item.imageName))
           imageView.translatesAutoresizingMaskIntoConstraints = false
           imageView.contentMode = .scaleAspectFit
           imageView.clipsToBounds = true

           let stack = UIStackView(arrangedSubviews: [
               makeKeyValueRow(key: "Donation ID:", value: item.donationId),
               makeKeyValueRow(key: "Item Name:", value: item.itemName),
               makeKeyValueRow(key: "Quantity:", value: item.quantity),
               makeKeyValueRow(key: "Category:", value: item.category),
               makeKeyValueRow(key: "Expiry Date:", value: item.expiryDate),
               makeKeyValueRow(key: "Packaging:", value: item.packaging),
               makeKeyValueRow(key: "Allergen Info:", value: item.allergenInfo)
           ])
           stack.translatesAutoresizingMaskIntoConstraints = false
           stack.axis = .vertical
           stack.spacing = 8

           card.addSubview(header)
           card.addSubview(stack)
           card.addSubview(imageView)

           NSLayoutConstraint.activate([
               header.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
               header.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
               header.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),

               stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
               stack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
               stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),

               imageView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
               imageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
               imageView.widthAnchor.constraint(equalToConstant: 70),
               imageView.heightAnchor.constraint(equalToConstant: 70),

               stack.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -12)
           ])
       }

       private func configureDonorInfo(card: UIView, item: AssignedPickupItem) {
           let header = makeHeader(title: "Donor Information")

           let stack = UIStackView(arrangedSubviews: [
               makeKeyValueRow(key: "Donor Name:", value: item.donorName),
               makeKeyValueRow(key: "Contact Number:", value: item.contactNumber),
               makeKeyValueRow(key: "Email:", value: item.email),
               makeKeyValueRow(key: "Location:", value: item.donorLocation)
           ])
           stack.translatesAutoresizingMaskIntoConstraints = false
           stack.axis = .vertical
           stack.spacing = 10

           card.addSubview(header)
           card.addSubview(stack)

           NSLayoutConstraint.activate([
               header.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
               header.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
               header.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),

               stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
               stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
               stack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
               stack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -14)

           ])
       }

    private func configurePickupInfo(card: UIView, item: AssignedPickupItem) {
        let header = makeHeader(title: "Pickup Information")

        let stack = UIStackView(arrangedSubviews: [
            makeKeyValueRow(key: "Scheduled date:", value: item.scheduledDate),
            makeKeyValueRow(key: "Pickup Window:", value: item.pickupWindow),
            makeKeyValueRow(key: "Distance:", value: item.distance),
            makeKeyValueRow(key: "Estimated Time:", value: item.estimatedTime),
            makeKeyValueRow(key: "Donor Notes:", value: item.donorNotes)
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        stack.distribution = .fill

        stack.setContentHuggingPriority(.required, for: .vertical)
        stack.setContentCompressionResistancePriority(.required, for: .vertical)

        card.addSubview(header)
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            header.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            header.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),

            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),


            stack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -14)
        ])
    }

    
    
}
