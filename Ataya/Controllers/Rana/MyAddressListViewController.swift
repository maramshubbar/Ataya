//
//  MyAddressListViewController.swift
//  Ataya
//
//  Created by BP-36-224-16 on 20/12/2025.
//
import UIKit

final class MyAddressListViewController: UIViewController {

    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var myAddressButton: UIButton!
    @IBOutlet weak var ngoButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    private enum Choice { case myAddress, ngo }
    private var selectedChoice: Choice?

    private let grayBorder = UIColor(hex: "#999999")
    private let selectedBorder = UIColor(hex: "#FEC400")
    private let selectedBG = UIColor(hex: "#FFFBE7")

    override func viewDidLoad() {
        super.viewDidLoad()

        setupOptionButton(myAddressButton)
        setupOptionButton(ngoButton)

        myAddressButton.addTarget(self, action: #selector(myAddressTapped), for: .touchUpInside)
        ngoButton.addTarget(self, action: #selector(ngoTapped), for: .touchUpInside)

        // ✅ only ONE next handler
        nextButton.removeTarget(nil, action: nil, for: .allEvents)
        nextButton.addTarget(self, action: #selector(nextTappedProgrammatic), for: .touchUpInside)

        applyDefaultStyle(myAddressButton)
        applyDefaultStyle(ngoButton)
        setNextEnabled(false)
    }

    // MARK: - Button setup
    private func setupOptionButton(_ button: UIButton) {
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.contentHorizontalAlignment = .center

        button.layer.cornerRadius = 4
        button.clipsToBounds = true

        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = grayBorder.cgColor

        button.addTarget(self, action: #selector(pressDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(pressUp(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])
    }

    // MARK: - Selection
    @objc private func myAddressTapped() { select(.myAddress) }
    @objc private func ngoTapped() { select(.ngo) }

    private func select(_ choice: Choice) {
        selectedChoice = choice

        applyDefaultStyle(myAddressButton)
        applyDefaultStyle(ngoButton)

        switch choice {
        case .myAddress: applySelectedStyle(myAddressButton)
        case .ngo: applySelectedStyle(ngoButton)
        }

        setNextEnabled(true)
    }

    private func applyDefaultStyle(_ button: UIButton) {
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = grayBorder.cgColor
    }

    private func applySelectedStyle(_ button: UIButton) {
        button.backgroundColor = selectedBG
        button.layer.borderWidth = 2
        button.layer.borderColor = selectedBorder.cgColor
    }

    private func setNextEnabled(_ enabled: Bool) {
        nextButton.isEnabled = enabled
        nextButton.alpha = enabled ? 1.0 : 0.5
    }

    // MARK: - NEXT
    @objc private func nextTappedProgrammatic() {
        guard let choice = selectedChoice else {
            showAlert(title: "Choose an option", message: "Select My Address or NGO first.")
            return
        }

        switch choice {
        case .ngo:
            presentThankYouPopup()   // ✅ NGO ends with popup
        case .myAddress:
            showAlert(title: "Continue", message: "My Address flow continues.")
        }
    }

    // MARK: - POPUP
    private func presentThankYouPopup() {
        guard let sb = self.storyboard else {
            showAlert(title: "Storyboard Error", message: "This screen is not loaded from storyboard.")
            return
        }

        // ✅ IMPORTANT: this must match Storyboard ID exactly
        let popupVC = sb.instantiateViewController(withIdentifier: "PopupConfirmPickupViewController")

        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.modalTransitionStyle = .crossDissolve

        DispatchQueue.main.async {
            self.present(popupVC, animated: true)
        }
    }

    // MARK: - Press animation
    @objc private func pressDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.10) {
            sender.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            sender.alpha = 0.92
        }
    }

    @objc private func pressUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.10) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }

    // MARK: - Alert
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Hex helper
//private extension UIColor {
//    convenience init(hex: String) {
//        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//        if s.hasPrefix("#") { s.removeFirst() }
//
//        var rgb: UInt64 = 0
//        Scanner(string: s).scanHexInt64(&rgb)
//
//        self.init(
//            red: CGFloat((rgb & 0xFF0000) >> 16) / 255,
//            green: CGFloat((rgb & 0x00FF00) >> 8) / 255,
//            blue: CGFloat(rgb & 0x0000FF) / 255,
//            alpha: 1
//        )
//    }
//}
