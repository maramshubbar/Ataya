//
//  ImageLoader.swift
//  Ataya
//
//  Created by Fatema Maitham on 26/12/2025.
//


import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()

    private init() {}

    func setImage(on imageView: UIImageView,
                  from urlString: String,
                  placeholder: UIImage? = nil) {
        imageView.image = placeholder

        guard let url = URL(string: urlString) else { return }

        if let cached = cache.object(forKey: url as NSURL) {
            imageView.image = cached
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let image = UIImage(data: data) else { return }

            self.cache.setObject(image, forKey: url as NSURL)

            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }
}
