//
//  NotificationSettingsViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 28/12/2025.
//
import UIKit

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
    private let yellow = UIColor(
        red: 247/255,
        green: 212/255,
        blue: 76/255,
        alpha: 1
    ) // #F7D44C

    private let borderGray = UIColor(
        red: 184/255,
        green: 184/255,
        blue: 184/255,
        alpha: 1
    ) // #B8B8B8


    // MARK: - Storage Keys
    private enum Keys {
        static let allowNotifications = "settings_allow_notifications"
        static let silentMode = "settings_silent_mode"
    }

    // MARK: - State
    private var initialAllow: Bool = true
    private var initialSilent: Bool = false

    // MARK: - Layout
    private var cardsStack: UIStackView?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notification Settings"
        view.backgroundColor = .white

        applyDesign()

        // ✅ THIS is the fix: force correct runtime layout even if storyboard is “lying”
        forceTwoSeparateCardsLayout()

        loadSavedValues()
        wireActions()
        refreshSaveButtonState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Keep multiline wrapping stable
        allowDescLabel.preferredMaxLayoutWidth = allowDescLabel.bounds.width
        silentDescLabel.preferredMaxLayoutWidth = silentDescLabel.bounds.width

        // Shadow path after layout
        cardAllowView.layer.shadowPath = UIBezierPath(roundedRect: cardAllowView.bounds, cornerRadius: 10).cgPath
        cardSilentView.layer.shadowPath = UIBezierPath(roundedRect: cardSilentView.bounds, cornerRadius: 10).cgPath
    }

    // MARK: - ✅ HARD LAYOUT FIX
    private func forceTwoSeparateCardsLayout() {

        // They must share a parent (same superview)
        guard let parent = cardAllowView.superview,
              parent === cardSilentView.superview else {
            return
        }

        // 1) Deactivate constraints in parent that touch either card (kills overlap / pinned-to-same-edges bug)
        let kill = parent.constraints.filter { c in
            let a = (c.firstItem as AnyObject?) === cardAllowView || (c.secondItem as AnyObject?) === cardAllowView
            let s = (c.firstItem as AnyObject?) === cardSilentView || (c.secondItem as AnyObject?) === cardSilentView
            return a || s
        }
        NSLayoutConstraint.deactivate(kill)

        // 2) Remove any stack we created before (safety)
        cardsStack?.removeFromSuperview()
        cardsStack = nil

        // 3) Remove cards from parent then re-add inside a fresh stack
        cardAllowView.removeFromSuperview()
        cardSilentView.removeFromSuperview()

        let stack = UIStackView(arrangedSubviews: [cardAllowView, cardSilentView])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        parent.addSubview(stack)

        // ✅ pin stack to parent exactly like storyboard intended
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            stack.topAnchor.constraint(equalTo: parent.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: parent.bottomAnchor)
        ])

        // 4) Force equal heights even if one label wraps (super stable)
        cardAllowView.translatesAutoresizingMaskIntoConstraints = false
        cardSilentView.translatesAutoresizingMaskIntoConstraints = false

        let minH: CGFloat = 118 // match your figma vibe
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

    // MARK: - Load/Save
    private func loadSavedValues() {
        let defaults = UserDefaults.standard

        if defaults.object(forKey: Keys.allowNotifications) == nil {
            defaults.set(true, forKey: Keys.allowNotifications)
        }
        if defaults.object(forKey: Keys.silentMode) == nil {
            defaults.set(false, forKey: Keys.silentMode)
        }

        let allow = defaults.bool(forKey: Keys.allowNotifications)
        let silent = defaults.bool(forKey: Keys.silentMode)

        allowSwitch.isOn = allow
        silentSwitch.isOn = silent

        initialAllow = allow
        initialSilent = silent
    }

    private func persistValues(allow: Bool, silent: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(allow, forKey: Keys.allowNotifications)
        defaults.set(silent, forKey: Keys.silentMode)

        initialAllow = allow
        initialSilent = silent
        refreshSaveButtonState()
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
            guard let self = self else { return }

            self.persistValues(allow: self.allowSwitch.isOn,
                               silent: self.silentSwitch.isOn)

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
//private extension UIColor {
//    convenience init(hex: String, alpha: CGFloat = 1.0) {
//        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//        if h.hasPrefix("#") { h.removeFirst() }
//        guard h.count == 6 else { self.init(white: 0, alpha: alpha); return }
//
//        var rgb: UInt64 = 0
//        Scanner(string: h).scanHexInt64(&rgb)
//
//        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//        let b = CGFloat(rgb & 0x0000FF) / 255.0
//
//        self.init(red: r, green: g, blue: b, alpha: alpha)
//    }
//}
