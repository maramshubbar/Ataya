//
//  MyAddressDetailsViewController.swift
//  Ataya
//
//  Created by BP-36-224-14 on 22/12/2025.
//

import UIKit

final class MyAddressDetailsViewController: UIViewController {

    @IBOutlet weak var twobuttonView: UIView!
    @IBOutlet weak var cancelbtn: UIButton!
    @IBOutlet weak var savebtn: UIButton!
    @IBOutlet weak var viewLocationtxt: UIButton!

    @IBOutlet weak var blacktxt: UITextField!
    @IBOutlet weak var streettxt: UITextField!
    @IBOutlet weak var houseNumbertxt: UITextField!
    @IBOutlet weak var addressLabeltxt: UITextField!

    private let yellow = UIColor(hex: "#F7D44C")
    private let yellowBG = UIColor(hex: "#FFFBE7") 


    // from List (edit/add)
    var editIndex: Int?
    var existingAddress: AddressModel?
    var onSaveAddress: ((AddressModel, Int?) -> Void)?

    // confirmed location (in-memory)
    private var confirmedLat: Double?
    private var confirmedLng: Double?
    private var confirmedAddress: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Address Details"

        // ✅ Back arrow always goes to My Address
        navigationItem.hidesBackButton = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backToMyAddress)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black

        setupButtons()
        wireButtons()
        makeButtonsSameSize()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // Editing
        if let existing = existingAddress {
            addressLabeltxt.text = existing.title
            confirmedLat = existing.latitude
            confirmedLng = existing.longitude
            confirmedAddress = existing.fullAddress
            viewLocationtxt.setTitle("Location Selected", for: .normal)
        } else {
            viewLocationtxt.setTitle("View or Change Pin Location", for: .normal)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let saved = LocationStorage.load() {
            confirmedLat = saved.latitude
            confirmedLng = saved.longitude
            confirmedAddress = saved.address
            viewLocationtxt.setTitle(saved.address, for: .normal)
            LocationStorage.clear()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        savebtn.layer.cornerRadius = 10
        cancelbtn.layer.cornerRadius = 10
        viewLocationtxt.layer.cornerRadius = 10
    }

    // MARK: - Back to list always
    @objc private func backToMyAddress() {
        if let nav = navigationController,
           let listVC = nav.viewControllers.first(where: { $0 is MyAddressListTableViewController }) {
            nav.popToViewController(listVC, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - UI
    private func setupButtons() {
        twobuttonView.backgroundColor = .clear

        savebtn.clipsToBounds = true
        savebtn.backgroundColor = yellow
        savebtn.setTitleColor(.black, for: .normal)

        cancelbtn.clipsToBounds = true
        cancelbtn.backgroundColor = .white
        cancelbtn.setTitleColor(yellow, for: .normal)
        cancelbtn.layer.borderWidth = 2
        cancelbtn.layer.borderColor = yellow.cgColor

        viewLocationtxt.setTitleColor(yellow, for: .normal)
        viewLocationtxt.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        viewLocationtxt.backgroundColor = yellowBG
        viewLocationtxt.layer.borderWidth = 2
        viewLocationtxt.layer.borderColor = yellow.cgColor
        viewLocationtxt.clipsToBounds = true

        [savebtn, cancelbtn].forEach { btn in
            btn.addTarget(self, action: #selector(pressDown(_:)), for: .touchDown)
            btn.addTarget(self, action: #selector(pressUp(_:)),
                          for: [.touchUpInside, .touchCancel, .touchDragExit, .touchUpOutside])
        }
    }

    private func makeButtonsSameSize() {
        savebtn.translatesAutoresizingMaskIntoConstraints = false
        cancelbtn.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            savebtn.widthAnchor.constraint(equalTo: cancelbtn.widthAnchor),
            savebtn.heightAnchor.constraint(equalTo: cancelbtn.heightAnchor)
        ])
    }

    private func wireButtons() {
        savebtn.removeTarget(nil, action: nil, for: .touchUpInside)
        cancelbtn.removeTarget(nil, action: nil, for: .touchUpInside)
        viewLocationtxt.removeTarget(nil, action: nil, for: .touchUpInside)

        savebtn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        cancelbtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        // if you still have confirm location screen
        viewLocationtxt.addTarget(self, action: #selector(openConfirmLocation), for: .touchUpInside)
    }

    @objc private func openConfirmLocation() {
        // If you have ConfirmLocationViewController keep it.
        // If you DON'T have it, delete this function + remove the target above.
        LocationStorage.clear()
        let vc = storyboard?.instantiateViewController(withIdentifier: "ConfirmLocationViewController") as! ConfirmLocationViewController
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Actions
    @objc private func saveTapped() {
        let label = addressLabeltxt.text?.trimmed ?? ""
        let house = houseNumbertxt.text?.trimmed ?? ""
        let street = streettxt.text?.trimmed ?? ""
        let block = blacktxt.text?.trimmed ?? ""

        guard !label.isEmpty else { return showAlert("Missing info", "Please enter Address Label.") }
        guard !house.isEmpty else { return showAlert("Missing info", "Please enter House Number.") }
        guard !street.isEmpty else { return showAlert("Missing info", "Please enter Street.") }
        guard !block.isEmpty else { return showAlert("Missing info", "Please enter Block.") }

        guard let lat = confirmedLat, let lng = confirmedLng else {
            return showAlert("Missing Location", "Please confirm your location on the map.")
        }

        let full = "Block \(block), Street \(street), House \(house)"

        let newAddress = AddressModel(
            title: label,
            fullAddress: full,
            latitude: lat,
            longitude: lng
        )

        // ✅ ALWAYS save (even if callback nil)
        if let onSaveAddress {
            onSaveAddress(newAddress, editIndex)
        } else {
            AddressRuntimeStore.shared.upsert(newAddress, at: editIndex)
            if let editIndex {
                AddressRuntimeStore.shared.selectedIndex = editIndex
            } else {
                AddressRuntimeStore.shared.selectedIndex = AddressRuntimeStore.shared.addresses.count - 1
            }
        }

        goToMyAddressList()
    }

    private func goToMyAddressList() {
        guard let nav = navigationController else {
            dismiss(animated: true)
            return
        }

        if let listVC = nav.viewControllers.first(where: { $0 is MyAddressListTableViewController }) {
            nav.popToViewController(listVC, animated: true)
            return
        }

        let vc = storyboard?.instantiateViewController(withIdentifier: "MyAddressListTableViewController") as! MyAddressListTableViewController
        nav.pushViewController(vc, animated: true)
    }

    @objc private func cancelTapped() {
        backToMyAddress()
    }

    // MARK: - Helpers
    @objc private func dismissKeyboard() { view.endEditing(true) }

    private func showAlert(_ title: String, _ message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    @objc private func pressDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            sender.alpha = 0.92
        }
    }

    @objc private func pressUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }
}

// MARK: - In-memory LocationStorage (no extra file)
struct locationStorage {
    struct SavedLocation {
        let latitude: Double
        let longitude: Double
        let address: String
    }

    private static var cached: SavedLocation?

    static func save(latitude: Double, longitude: Double, address: String) {
        cached = SavedLocation(latitude: latitude, longitude: longitude, address: address)
    }

    static func load() -> SavedLocation? { cached }
    static func clear() { cached = nil }
}

// MARK: - Small helpers
private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

private extension UIColor {
    convenience init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&rgb)
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
