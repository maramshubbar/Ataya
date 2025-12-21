//
//  StorageService.swift
//  Ataya
//
//  Created by Maram on 21/12/2025.
//

import Foundation
import FirebaseStorage
import UIKit

final class StorageService {
    static let shared = StorageService()
    private init() {}

    private let storage = Storage.storage()

    func uploadImage(_ image: UIImage, path: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            completion(.failure(NSError(domain: "image", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode image"])))
            return
        }

        let ref = storage.reference(withPath: path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        ref.putData(data, metadata: metadata) { _, err in
            if let err = err { completion(.failure(err)); return }
            ref.downloadURL { url, err in
                if let err = err { completion(.failure(err)); return }
                completion(.success(url?.absoluteString ?? ""))
            }
        }
    }
}
