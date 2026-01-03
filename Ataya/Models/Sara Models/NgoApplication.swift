//
//  NGOApplication.swift
//  Ataya
//
//  Created by BP-36-224-14 on 29/12/2025.
//

import Foundation

/// Represents a single uploaded NGO document
struct NGODocument {
    let name: String   // File name
    let url: String    // Could be a Firebase URL or empty for dummy

    // Dummy initializer
    init(name: String, url: String = "") {
        self.name = name
        self.url = url
    }

    // Firestore initializer (if you want to keep original support)
    init(data: [String: Any]) {
        self.name = data["name"] as? String ?? ""
        self.url = data["url"] as? String ?? ""
    }
}

/// Represents one NGO application used by the admin verification screen
struct NGOApplication {
    let uid: String
    let name: String
    let type: String
    let email: String
    let phone: String
    let notes: String
    let approveStatus: String
    let createdAt: Date
    let documents: [NGODocument]
    let profile: String  // local image name or URL

    // Dummy initializer
    init(
        uid: String,
        name: String,
        type: String,
        email: String,
        phone: String,
        notes: String,
        approveStatus: String = "pending",
        createdAt: Date = Date(),
        documents: [NGODocument] = [],
        profile: String = ""
    ) {
        self.uid = uid
        self.name = name
        self.type = type
        self.email = email
        self.phone = phone
        self.notes = notes
        self.approveStatus = approveStatus
        self.createdAt = createdAt
        self.documents = documents
        self.profile = profile
    }

    // Firestore initializer (optional, if you still need Firebase)
    init?(snapshot: Any) {
        // If you remove Firebase, you can skip this
        return nil
    }
}
