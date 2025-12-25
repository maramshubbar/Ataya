//
//  CloudinaryManager.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//

import UIKit

// A singleton manager that stores the Cloudinary configuration
// for the entire app. Use this class to access Cloudinary settings
// from anywhere in the project.
final class CloudinaryManager {

    // A shared single instance of CloudinaryManager (Singleton pattern).
    // Instead of creating new instances, always use:
    // `CloudinaryManager.shared`
    static let shared = CloudinaryManager()

    // Private initializer to prevent creating new instances
    // from outside the class. This enforces the Singleton design.
    private init() {}
    
    let cloudName: String = "dwdh8pxx7"

    let uploadPreset: String = "peyuzo8a"
    
    enum CloudinaryError: Error {
            case invalidImageData
            case invalidResponse
}
    // Uploads an image to Cloudinary and returns the secure_url string.
        func upload(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {

            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                completion(.failure(CloudinaryError.invalidImageData))
                return
            }


            let urlString = "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload"
            guard let url = URL(string: urlString) else {
                completion(.failure(CloudinaryError.invalidResponse))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"


            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            var body = Data()
            let lineBreak = "\r\n"


            body.append("--\(boundary)\(lineBreak)")
            body.append("Content-Disposition: form-data; name=\"upload_preset\"\(lineBreak)\(lineBreak)")
            body.append("\(uploadPreset)\(lineBreak)")


            body.append("--\(boundary)\(lineBreak)")
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\(lineBreak)")
            body.append("Content-Type: image/jpeg\(lineBreak)\(lineBreak)")
            body.append(imageData)
            body.append(lineBreak)


            body.append("--\(boundary)--\(lineBreak)")

            request.httpBody = body


            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                func finish(_ result: Result<String, Error>) {
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }

                if let error = error {
                    finish(.failure(error))
                    return
                }

                guard
                    let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode),
                    let data = data
                else {
                    finish(.failure(CloudinaryError.invalidResponse))
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let secureURL = json["secure_url"] as? String {
                        finish(.success(secureURL))
                    } else {
                        finish(.failure(CloudinaryError.invalidResponse))
                    }
                } catch {
                    finish(.failure(error))
                }
            }

            task.resume()
        }
    }

    private extension Data {
        mutating func append(_ string: String) {
            if let data = string.data(using: .utf8) {
                append(data)
            }
        }
    }
