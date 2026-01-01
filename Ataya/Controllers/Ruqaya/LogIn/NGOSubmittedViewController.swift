//import UIKit
//import FirebaseAuth
//import FirebaseFirestore
//
import UIKit

final class NGOSubmittedViewController: UIViewController {

    @IBOutlet weak var cardView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)

        cardView.layer.cornerRadius = 8
        cardView.clipsToBounds = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        if !cardView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
}
