import UIKit

final class PopupConfirmPickupViewController: UIViewController {

    // optional outlets (no crash if not linked)
    @IBOutlet weak var dimView: UIView?
    @IBOutlet weak var giveFeedbackButton: UIButton?
    @IBOutlet weak var cardView: UIView?

    // ✅ callback if you ever want to do something when button tapped
    var onDone: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // transparent root
        view.backgroundColor = .clear

        // ✅ Freeze: no swipe-down dismiss
        isModalInPresentation = true

        // Dim overlay (create if not exists)
        let overlay: UIView
        if let dimView {
            overlay = dimView
        } else {
            overlay = UIView(frame: view.bounds)
            overlay.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(overlay, at: 0)
            NSLayoutConstraint.activate([
                overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                overlay.topAnchor.constraint(equalTo: view.topAnchor),
                overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            self.dimView = overlay
        }

        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        overlay.isUserInteractionEnabled = true
        // ❌ NO tap gesture => popup NEVER disappears

        // Card styling
        cardView?.layer.cornerRadius = 8
        cardView?.clipsToBounds = true

        // Button
        giveFeedbackButton?.addTarget(self, action: #selector(giveFeedbackTapped), for: .touchUpInside)
    }

    @objc private func giveFeedbackTapped() {
        onDone?()
        // إذا تبين يسكر هنا حطي:
        // dismiss(animated: true)
    }
}
