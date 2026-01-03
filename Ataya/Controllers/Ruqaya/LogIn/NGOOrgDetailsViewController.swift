import UIKit
import FirebaseAuth
import FirebaseFirestore

final class NGOOrgDetailsViewController: UIViewController {

    
    @IBOutlet weak var missionCard: UIView!
    @IBOutlet weak var personalIDCard: UIView!
    @IBOutlet weak var trainingCard: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var typeButton: UIButton!

    private let db = Firestore.firestore()
    private var isSubmitting = false

    private let types = [
        "Humanitarian / Non-Profit",
        "Medical & Psychological",
        "Community Support & Donation"
    ]

    private var selectedType: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        [missionCard, personalIDCard, trainingCard].forEach { card in
            card.layer.cornerRadius = 12
            card.clipsToBounds = true
        }


        submitButton.layer.cornerRadius = 12
        submitButton.clipsToBounds = true


        styleTypeDropdownButton()


        setupTypeMenu()


        loadSavedTypeIfAny()
    }

    private func styleTypeDropdownButton() {
        typeButton.layer.cornerRadius = 12
        typeButton.layer.borderWidth = 1
        typeButton.layer.borderColor = UIColor.systemGray4.cgColor
        typeButton.backgroundColor = UIColor.systemGray6

        typeButton.setTitleColor(.label, for: .normal)

        typeButton.contentHorizontalAlignment = .left
        typeButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 44)

        typeButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        typeButton.tintColor = .systemGray
        typeButton.semanticContentAttribute = .forceRightToLeft
        typeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)

        let t = (typeButton.title(for: .normal) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty {
            typeButton.setTitle("Select Type", for: .normal)
        }
    }


    private func setupTypeMenu() {
        let actions = types.map { t in
            UIAction(title: t) { [weak self] _ in
                guard let self else { return }
                self.selectedType = t
                self.typeButton.setTitle(t, for: .normal)
            }
        }

        typeButton.menu = UIMenu(title: "Select Type", children: actions)
        typeButton.showsMenuAsPrimaryAction = true
    }

    private func loadSavedTypeIfAny() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).getDocument { [weak self] snap, _ in
            guard let self else { return }

            let saved = (snap?.data()?["type"] as? String)?
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if let saved, !saved.isEmpty {
                self.selectedType = saved
                self.typeButton.setTitle(saved, for: .normal)
            }
        }
    }

    // ✅ سبمت: يحفظ بالفايرستور (والـ uploads مو شرط نهائي)
    @IBAction func submitTapped(_ sender: UIButton) {

        if isSubmitting { return }
        isSubmitting = true
        sender.isEnabled = false
        sender.alpha = 0.6

        guard let uid = Auth.auth().currentUser?.uid else {
            finishSubmitting(sender)
            showAlert("Not Logged In", "Please login again.")
            return
        }

        let typeText = (selectedType ?? typeButton.title(for: .normal) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        var update: [String: Any] = [
            "orgDetailsSubmitted": true,
            "orgDetailsSubmittedAt": FieldValue.serverTimestamp()
        ]


        if !typeText.isEmpty, typeText.lowercased() != "select type" {
            update["type"] = typeText
        }

        db.collection("users").document(uid).setData(update, merge: true) { [weak self] err in
            guard let self else { return }

            self.finishSubmitting(sender)

            if let err = err {
                self.showAlert("Firestore Error", err.localizedDescription)
                return
            }

            let alert = UIAlertController(
                title: "Success ✅",
                message: "Your information has been saved successfully.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    private func finishSubmitting(_ sender: UIButton) {
        isSubmitting = false
        sender.isEnabled = true
        sender.alpha = 1.0
    }

    private func showAlert(_ title: String, _ message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
