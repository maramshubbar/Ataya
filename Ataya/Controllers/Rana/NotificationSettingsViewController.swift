//
//  NotificationSettingsViewController.swift
//  Ataya
//
//  Created by BP-36-224-09 on 28/12/2025.
//

import UIKit

final class NotificationSettingsViewController: UIViewController {

    // MARK: - Outlets (connect these)
    @IBOutlet private weak var cardAllowView: UIView!
    @IBOutlet private weak var allowTitleLabel: UILabel!
    @IBOutlet private weak var allowDescLabel: UILabel!
    @IBOutlet private weak var allowSwitch: UISwitch!

    @IBOutlet private weak var cardSilentView: UIView!
    @IBOutlet private weak var silentTitleLabel: UILabel!
    @IBOutlet private weak var silentDescLabel: UILabel!
    @IBOutlet private weak var silentSwitch: UISwitch!

    @IBOutlet private weak var saveButton: UIButton!

    // MARK: - Colors (Figma)
    private let yellow = UIColor(hex: "#F7D44C")
    private let borderGray = UIColor(hex: "#B8B8B8")
    private let textBlack = UIColor.black

    // MARK: - Storage Keys
    private enum Keys {
        static let allowNotifications = "settings_allow_notifications"
        static let silentMode = "settings_silent_mode"
    }

    // MARK: - State (to detect changes)
    private var initialAllow: Bool = true
    private var initialSilent: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notification Settings"
        view.backgroundColor = .white

        applyDesign()
        loadSavedValues()
        wireActions()
        refreshSaveButtonState()
    }

    // MARK: - Design
    private func applyDesign() {

        // Labels (you said: title 16, description 13)
        styleTitleLabel(allowTitleLabel)
        styleDescLabel(allowDescLabel)

        styleTitleLabel(silentTitleLabel)
        styleDescLabel(silentDescLabel)

        // Ensure text is black like Figma
        allowTitleLabel.textColor = textBlack
        allowDescLabel.textColor = textBlack
        silentTitleLabel.textColor = textBlack
        silentDescLabel.textColor = textBlack

        // Cards
        styleCard(cardAllowView)
        styleCard(cardSilentView)

        // Save Button
        saveButton.setTitle("Save Changes", for: .normal)
        saveButton.backgroundColor = yellow
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.layer.masksToBounds = true

        // Switch colors (optional but nicer)
        allowSwitch.onTintColor = UIColor.systemGreen
        silentSwitch.onTintColor = UIColor.systemGreen
    }

    private func styleTitleLabel(_ label: UILabel) {
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
    }

    private func styleDescLabel(_ label: UILabel) {
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
    }

    private func styleCard(_ v: UIView) {
        v.backgroundColor = .white
        v.layer.cornerRadius = 10
        v.layer.borderWidth = 1
        v.layer.borderColor = borderGray.cgColor
        v.layer.masksToBounds = false

        // subtle shadow like Figma feel (soft)
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    // MARK: - Load/Save
    private func loadSavedValues() {
        let defaults = UserDefaults.standard

        // If first time -> set defaults
        if defaults.object(forKey: Keys.allowNotifications) == nil {
            defaults.set(true, forKey: Keys.allowNotifications)
        }
        if defaults.object(forKey: Keys.silentMode) == nil {
            defaults.set(false, forKey: Keys.silentMode)
        }

        let allow = defaults.bool(forKey: Keys.allowNotifications)
        let silent = defaults.bool(forKey: Keys.silentMode)

        // Apply to UI
        allowSwitch.isOn = allow
        silentSwitch.isOn = silent

        // Keep initial snapshot
        initialAllow = allow
        initialSilent = silent
    }

    private func persistValues(allow: Bool, silent: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(allow, forKey: Keys.allowNotifications)
        defaults.set(silent, forKey: Keys.silentMode)
        defaults.synchronize()

        // update initial snapshot after saving
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
        return allowSwitch.isOn != initialAllow || silentSwitch.isOn != initialSilent
    }

    private func refreshSaveButtonState() {
        // Optional UX: disable save if no changes
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

            let allow = self.allowSwitch.isOn
            let silent = self.silentSwitch.isOn

            self.persistValues(allow: allow, silent: silent)
            self.showSavedPopup()
        }))

        present(alert, animated: true)
    }

    private func showSavedPopup() {
        let done = UIAlertController(
            title: "Changes Saved",
            message: "Your notification preferences have been updated successfully.",
            preferredStyle: .alert
        )
        done.addAction(UIAlertAction(title: "OK", style: .default))
        present(done, animated: true)
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
