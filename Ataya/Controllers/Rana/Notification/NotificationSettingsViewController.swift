//
//  NotificationSettingsViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 28/12/2025.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

final class NotificationSettingsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var cardAllowView: UIView!
    @IBOutlet private weak var allowTitleLabel: UILabel!
    @IBOutlet private weak var allowDescLabel: UILabel!
    @IBOutlet private weak var allowSwitch: UISwitch!

    @IBOutlet private weak var cardSilentView: UIView!
    @IBOutlet private weak var silentTitleLabel: UILabel!
    @IBOutlet private weak var silentDescLabel: UILabel!
    @IBOutlet private weak var silentSwitch: UISwitch!

    @IBOutlet private weak var saveButton: UIButton!

    // MARK: - Colors
    private let yellow = UIColor(hex: "#F7D44C")
    private let borderGray = UIColor(hex: "#B8B8B8")

    // MARK: - State
    private var initialAllow: Bool = true
    private var initialSilent: Bool = false

    // Role comes from NotificationViewController
    var role: AppRole = .donor

    // Firestore live listener
    private var settingsListener: ListenerRegistration?

    // MARK: - Layout
    private var cardsStack: UIStackView?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notification Settings"
        view.backgroundColor = .white

        applyDesign()
        forceTwoSeparateCardsLayout()

        wireActions()

        // ✅ Firestore load + listen
        loadSettingsFromFirestore()
        refreshSaveButtonState()
    }

    deinit {
        settingsListener?.remove()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        allowDescLabel.preferredMaxLayoutWidth = allowDescLabel.bounds.width
        silentDescLabel.preferredMaxLayoutWidth = silentDescLabel.bounds.width

        cardAllowView.layer.shadowPath = UIBezierPath(roundedRect: cardAllowView.bounds, cornerRadius: 10).cgPath
        cardSilentView.layer.shadowPath = UIBezierPath(roundedRect: cardSilentView.bounds, cornerRadius: 10).cgPath
    }

    // MARK: - ✅ HARD LAYOUT FIX (kept as you had)
    private func forceTwoSeparateCardsLayout() {

        guard let parent = cardAllowView.superview,
              parent === cardSilentView.superview else {
            return
        }

        let kill = parent.constraints.filter { c in
            let a = (c.firstItem as AnyObject?) === cardAllowView || (c.secondItem as AnyObject?) === cardAllowView
            let s = (c.firstItem as AnyObject?) === cardSilentView || (c.secondItem as AnyObject?) === cardSilentView
            return a || s
        }
        NSLayoutConstraint.deactivate(kill)

        cardsStack?.removeFromSuperview()
        cardsStack = nil

        cardAllowView.removeFromSuperview()
        cardSilentView.removeFromSuperview()

        let stack = UIStackView(arrangedSubviews: [cardAllowView, cardSilentView])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        parent.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            stack.topAnchor.constraint(equalTo: parent.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: parent.bottomAnchor)
        ])

        cardAllowView.translatesAutoresizingMaskIntoConstraints = false
        cardSilentView.translatesAutoresizingMaskIntoConstraints = false

        let minH: CGFloat = 118
        NSLayoutConstraint.activate([
            cardAllowView.heightAnchor.constraint(greaterThanOrEqualToConstant: minH),
            cardSilentView.heightAnchor.constraint(greaterThanOrEqualToConstant: minH),
            cardSilentView.heightAnchor.constraint(equalTo: cardAllowView.heightAnchor)
        ])

        cardsStack = stack
    }

    // MARK: - Design
    private func applyDesign() {
        styleTitleLabel(allowTitleLabel)
        styleDescLabel(allowDescLabel)

        styleTitleLabel(silentTitleLabel)
        styleDescLabel(silentDescLabel)

        styleCard(cardAllowView)
        styleCard(cardSilentView)

        saveButton.setTitle("Save Changes", for: .normal)
        saveButton.backgroundColor = yellow
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.layer.masksToBounds = true

        allowSwitch.onTintColor = .systemGreen
        silentSwitch.onTintColor = .systemGreen
    }

    private func styleTitleLabel(_ label: UILabel) {
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
    }

    private func styleDescLabel(_ label: UILabel) {
        label.textColor = .black
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
    }

    private func styleCard(_ v: UIView) {
        v.backgroundColor = .white
        v.layer.cornerRadius = 10
        v.layer.borderWidth = 1
        v.layer.borderColor = borderGray.cgColor
        v.layer.masksToBounds = false

        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    // MARK: - ✅ Firestore Load/Listen
    private func loadSettingsFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user logged in (settings screen).")
            return
        }

        // Create defaults once if missing
        NotificationService.shared.ensureDefaultSettings(uid: uid, role: role)

        // Listen realtime
        settingsListener?.remove()
        settingsListener = NotificationService.shared.listenSettings(uid: uid, role: role) { [weak self] s in
            guard let self else { return }

            self.allowSwitch.isOn = s.allow
            self.silentSwitch.isOn = s.silent

            self.initialAllow = s.allow
            self.initialSilent = s.silent
            self.refreshSaveButtonState()
        }
    }

    private func persistValuesToFirestore(allow: Bool, silent: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        NotificationService.shared.saveSettings(uid: uid, role: role, allow: allow, silent: silent) { [weak self] err in
            if let err = err {
                print("saveSettings error:", err.localizedDescription)
                return
            }
            self?.initialAllow = allow
            self?.initialSilent = silent
            self?.refreshSaveButtonState()
        }
    }

    // MARK: - Actions
    private func wireActions() {
        allowSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        silentSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    @objc private func switchChanged() {
        refreshSaveButtonState()
    }

    private func hasUnsavedChanges() -> Bool {
        allowSwitch.isOn != initialAllow || silentSwitch.isOn != initialSilent
    }

    private func refreshSaveButtonState() {
        let enabled = hasUnsavedChanges()
        saveButton.isEnabled = enabled
        saveButton.alpha = enabled ? 1.0 : 0.55
    }

    @objc private func saveTapped() {
        guard hasUnsavedChanges() else { return }

        let alert = UIAlertController(
            title: "Save changes?",
            message: "Do you want to save your notification settings?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let self else { return }

            self.persistValuesToFirestore(
                allow: self.allowSwitch.isOn,
                silent: self.silentSwitch.isOn
            )

            let done = UIAlertController(
                title: "Changes Saved",
                message: "Your notification preferences have been updated successfully.",
                preferredStyle: .alert
            )
            done.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(done, animated: true)
        }))

        present(alert, animated: true)
    }
}

// MARK: - Hex helper
private extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6 else { self.init(white: 0, alpha: alpha); return }

        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
