////
////  UIImageView+Remote.swift
////  Ataya
////
////  Created by Fatema Maitham on 27/12/2025.
////
//
//import Foundation
//import UIKit
//
//extension UIImageView {
//    func setRemoteImage(_ urlString: String?) {
//        self.image = nil
//
//        guard let s = urlString?.trimmingCharacters(in: .whitespacesAndNewlines),
//              let url = URL(string: s) else { return }
//
//        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
//            guard let data, let img = UIImage(data: data) else { return }
//            DispatchQueue.main.async { self?.image = img }
//        }.resume()
//    }
//}
