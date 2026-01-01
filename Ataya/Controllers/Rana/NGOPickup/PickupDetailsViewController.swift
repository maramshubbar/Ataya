//
//  PickupDetailsViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 29/12/2025.
//
import UIKit

final class PickupDetailsViewController: UIViewController {

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var statusView: StatusProgressView!

    @IBOutlet weak var detailsCardView: UIView!
    @IBOutlet weak var dateCardView: UIView!

    @IBOutlet weak var itemNameValueLabel: UILabel!
    @IBOutlet weak var quantityValueLabel: UILabel!
    @IBOutlet weak var categoryValueLabel: UILabel!
    @IBOutlet weak var expiryValueLabel: UILabel!
    @IBOutlet weak var notesValueLabel: UILabel!

    @IBOutlet weak var scheduledDateValueLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!

    var item: PickupItem!
    var onStatusChanged: ((PickupStatus) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pickup Details"

        guard item != nil else {
            assertionFailure("item is nil. You didn't pass the item before pushing.")
            navigationController?.popViewController(animated: true)
            return
        }

        setupCardsUI()
        fillData()
        refreshUI(animated: false)

        // ✅ FORCE: even if storyboard action is broken, this makes it work
        actionButton.removeTarget(nil, action: nil, for: .allEvents)
        actionButton.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // ✅ FORCE: button stays on top and receives touch
        view.bringSubviewToFront(actionButton)
        actionButton.isUserInteractionEnabled = true
        actionButton.isEnabled = true
    }

    private func setupCardsUI() {
        [detailsCardView, dateCardView].forEach {
            $0?.backgroundColor = .white
            $0?.layer.cornerRadius = 12
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor.hex("#E6E6E6").cgColor
            $0?.layer.masksToBounds = true
        }

        actionButton.backgroundColor = UIColor.hex("#F7D44C")
        actionButton.setTitleColor(.black, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        actionButton.layer.cornerRadius = 12
        actionButton.layer.masksToBounds = true

        notesValueLabel.numberOfLines = 0
    }

    private func fillData() {
        idLabel.text = "ID : (\(item.pickupID))"

        itemNameValueLabel.text = "Item Name: \(item.itemName)"
        quantityValueLabel.text = "Quantity: \(item.quantity)"
        categoryValueLabel.text = "Category: \(item.category)"
        expiryValueLabel.text = "Expiry Date: \(item.expiryDate)"
        notesValueLabel.text = "Additional Notes: \(item.notes)"

        scheduledDateValueLabel.text = item.scheduledDate
    }

    private func refreshUI(animated: Bool) {
        switch item.status {
        case .pending:
            statusView.set(step: .pending, animated: animated)
            actionButton.isEnabled = true
            actionButton.alpha = 1
            actionButton.setTitle("Accept", for: .normal)

        case .accepted:
            statusView.set(step: .accepted, animated: animated)
            actionButton.isEnabled = true
            actionButton.alpha = 1
            actionButton.setTitle("Mark As Completed", for: .normal)

        case .completed:
            statusView.set(step: .completed, animated: animated)
            actionButton.isEnabled = false
            actionButton.alpha = 0.6
            actionButton.setTitle("Completed", for: .normal)
        }
    }

    @objc @IBAction func actionTapped(_ sender: UIButton) {
        // If you tap and don’t see popup, then this function is NOT firing.
        print("✅ actionTapped fired. Current status:", item.status.rawValue)

        switch item.status {
        case .pending:
            confirm(title: "Accept Pickup?",
                    message: "Are you sure you want to accept this pickup?") { [weak self] in
                guard let self else { return }
                self.item.status = .accepted
                self.onStatusChanged?(.accepted)
                self.refreshUI(animated: true)
            }

        case .accepted:
            confirm(title: "Complete Pickup?",
                    message: "Are you sure you want to mark this pickup as completed?") { [weak self] in
                guard let self else { return }
                self.item.status = .completed
                self.onStatusChanged?(.completed)
                self.refreshUI(animated: true)
            }

        case .completed:
            break
        }
    }

    private func confirm(title: String, message: String, onYes: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in onYes() })
        present(alert, animated: true)
    }
}
