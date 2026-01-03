import UIKit
import Foundation

extension UIImageView {
    func setRemoteImage(_ urlString: String?, placeholder: UIImage? = nil) {
        image = placeholder

        guard let s = urlString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !s.isEmpty,
              let url = URL(string: s) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { self?.image = img }
        }.resume()
    }
}
