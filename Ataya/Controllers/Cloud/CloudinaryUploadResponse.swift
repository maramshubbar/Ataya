//
//  CloudinaryUploadResponse.swift
//  Ataya
//
//  Created by Fatema Maitham on 27/12/2025.
//


//
//  CloudinaryUploadResponse.swift
//  Ataya
//
//  Created by Fatema Maitham on 27/12/2025.
//


import UIKit

// MARK: - Models

struct CloudinaryUploadResponse: Decodable {
    let secure_url: String
    let public_id: String
    let width: Int?
    let height: Int?
}

struct CloudinaryErrorResponse: Decodable {
    struct CloudinaryErr: Decodable { let message: String }
    let error: CloudinaryErr
}

// MARK: - Errors

enum CloudinaryUploadError: Error, LocalizedError {
    case invalidEndpoint
    case invalidImageData
    case badStatus(Int, String)
    case decodeFailed

    var errorDescription: String? {
        switch self {
        case .invalidEndpoint:
            return "Cloudinary upload endpoint is invalid."
        case .invalidImageData:
            return "Could not convert image to JPEG data."
        case .badStatus(let code, let msg):
            return "Upload failed (\(code)): \(msg)"
        case .decodeFailed:
            return "Could not decode Cloudinary response."
        }
    }
}

// MARK: - Uploader

final class CloudinaryUploader {

    static let shared = CloudinaryUploader()
    private init() {}

    /// Upload image to Cloudinary (Unsigned) and return (secureUrl, publicId).
    func uploadImage(
        _ image: UIImage,
        folder: String? = nil,
        completion: @escaping (Result<(secureUrl: String, publicId: String), Error>) -> Void
    ) {
        guard let endpoint = CloudinaryManager.shared.uploadEndpoint else {
            completion(.failure(CloudinaryUploadError.invalidEndpoint))
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.85) else {
            completion(.failure(CloudinaryUploadError.invalidImageData))
            return
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // upload_preset
        body.append(multipartField(name: "upload_preset",
                                   value: CloudinaryManager.shared.uploadPreset,
                                   boundary: boundary))

        // optional folder
        if let folder = folder, !folder.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            body.append(multipartField(name: "folder", value: folder, boundary: boundary))
        }

        // file
        body.append(multipartFile(name: "file",
                                 filename: "image.jpg",
                                 mimeType: "image/jpeg",
                                 fileData: imageData,
                                 boundary: boundary))

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let http = response as? HTTPURLResponse,
                      let data = data else {
                    completion(.failure(CloudinaryUploadError.decodeFailed))
                    return
                }

                // Handle non-2xx with Cloudinary error message
                if !(200...299).contains(http.statusCode) {
                    let msg = (try? JSONDecoder().decode(CloudinaryErrorResponse.self, from: data).error.message)
                        ?? String(data: data, encoding: .utf8)
                        ?? "Unknown error"
                    completion(.failure(CloudinaryUploadError.badStatus(http.statusCode, msg)))
                    return
                }

                // Decode success
                guard let decoded = try? JSONDecoder().decode(CloudinaryUploadResponse.self, from: data) else {
                    completion(.failure(CloudinaryUploadError.decodeFailed))
                    return
                }

                completion(.success((secureUrl: decoded.secure_url, publicId: decoded.public_id)))
            }
        }.resume()
    }
}

// MARK: - Multipart Helpers

private func multipartField(name: String, value: String, boundary: String) -> Data {
    var data = Data()
    data.appendString("--\(boundary)\r\n")
    data.appendString("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
    data.appendString("\(value)\r\n")
    return data
}

private func multipartFile(name: String,
                           filename: String,
                           mimeType: String,
                           fileData: Data,
                           boundary: String) -> Data {
    var data = Data()
    data.appendString("--\(boundary)\r\n")
    data.appendString("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
    data.appendString("Content-Type: \(mimeType)\r\n\r\n")
    data.append(fileData)
    data.appendString("\r\n")
    return data
}

private extension Data {
    mutating func appendString(_ string: String) {
        if let d = string.data(using: .utf8) { append(d) }
    }
}
