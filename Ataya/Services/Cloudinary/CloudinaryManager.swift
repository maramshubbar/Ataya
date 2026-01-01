//
//  File.swift
//  Ataya
//
//  Created by Maram on 27/12/2025.
//

import Foundation
//
//  CloudinaryManager.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
 
import Foundation
 
//Stores Cloudinary configuration for the whole app (Singleton).
final class CloudinaryManager {
 
    static let shared = CloudinaryManager()
    private init() {}
 
 
    let cloudName: String = "dwdh8pxx7"
 
    let uploadPreset: String = "peyuzo8a"
    // Unsigned upload endpoint
    var uploadEndpoint: URL? {
        URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")
    }
}
