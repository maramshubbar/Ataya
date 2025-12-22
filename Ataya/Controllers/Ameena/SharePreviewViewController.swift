import UIKit

final class SharePreviewViewController: UIViewController {
    
    @IBOutlet weak var previewImageView: UIImageView!

        var imageToShare: UIImage?
        var shareText: String = ""

        override func viewDidLoad() {
            super.viewDidLoad()

            title = "Share Impact"
            navigationItem.largeTitleDisplayMode = .never

            previewImageView.image = imageToShare

            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .action,
                target: self,
                action: #selector(shareNow)
            )
        }

        @objc private func shareNow() {
            guard let image = imageToShare else { return }

            let vc = UIActivityViewController(
                activityItems: [shareText, image],
                applicationActivities: nil
            )

            if let pop = vc.popoverPresentationController {
                pop.barButtonItem = navigationItem.rightBarButtonItem
            }

            present(vc, animated: true)
        }
    }
