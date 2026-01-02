//
//  ImageLoader.swift
//  Ataya
//
//  Created by Fatema Maitham on 02/01/2026.
//


import UIKit

final class ImageLoader {

    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()

    private init() {}

    func setImage(
        on imageView: UIImageView,
        from urlString: String?,
        placeholder: UIImage? = nil
    ) {
        imageView.image = placeholder

        guard let urlString,
              !urlString.isEmpty,
              let url = URL(string: urlString) else { return }

        imageView.accessibilityIdentifier = urlString

        if let cached = cache.object(forKey: url as NSURL) {
            imageView.image = cached
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self, weak imageView] data, _, _ in
            guard let self,
                  let imageView,
                  let data,
                  let image = UIImage(data: data) else { return }

            self.cache.setObject(image, forKey: url as NSURL)

            DispatchQueue.main.async {
                if imageView.accessibilityIdentifier == urlString {
                    imageView.image = image
                }
            }
        }.resume()
    }
}
