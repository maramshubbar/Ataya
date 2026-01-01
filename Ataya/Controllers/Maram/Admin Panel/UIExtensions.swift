//
//  UIExtensions.swift
//  Ataya
//
//  Created by Maram on 29/11/2025.
//

import UIKit

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 48))
        leftView = v
        leftViewMode = .always
    }
}

extension UILabel {
    convenience init(text: String) {
        self.init(frame: .zero)
        self.text = text
        self.font = .systemFont(ofSize: 15)
        self.textColor = .black
    }
}


import UIKit

private let _imgCache = NSCache<NSString, UIImage>()

extension UIImageView {

    func fetchRemoteImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        let key = urlString as NSString

        if let cached = _imgCache.object(forKey: key) {
            completion(cached)
            return
        }

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let img = UIImage(data: data) else {
                completion(nil)
                return
            }

            _imgCache.setObject(img, forKey: key)
            completion(img)
        }.resume()
    }
}

import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8) & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}


extension UIView {

    func applyCardStyleNoShadow(
        radius: CGFloat = 16,
        borderHex: String = "#E6E6E6",
        borderWidth: CGFloat = 1
    ) {
        layer.shadowColor = nil
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.shadowOffset = .zero
        layer.shadowPath = nil
        layer.shouldRasterize = false

        layer.cornerRadius = radius
        layer.borderWidth = borderWidth
        layer.borderColor = UIColor(hex: borderHex).cgColor

        clipsToBounds = true
        layer.masksToBounds = true
    }
}
