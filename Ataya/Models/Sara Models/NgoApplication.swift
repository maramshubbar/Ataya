//
//  NGOApplication.swift
//  Ataya
//
//  Created by BP-36-224-14 on 29/12/2025.
//
import UIKit

//struct NGOApplication {
//    let id: String
//    let name: String
//    let type: String
//    let email: String
//    let phone: String
//    let date: String
//    var status: String
//    var notes: String
//    var uploadedDocuments: [String] // file names or URLs
//    var ngoProfile: String
//}

import Foundation
import FirebaseFirestore

///Represents a single uploaded NGO document
struct NGODocument {
    let name: String //file name
    let url: String //firbase storage url

    init(data: [String: Any]) {
        self.name = data["name"] as? String ?? ""
        self.url = data["url"] as? String ?? ""
    }
}

///Represents one NGO application used by the admin verification screen
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
    let profile: String

    /// Initialize model from Firestore document
    init?(snapshot: DocumentSnapshot) {
        guard let data = snapshot.data() else { return nil }

        self.uid = data["uid"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.type = data["type"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.phone = data["phone"] as? String ?? ""
        self.notes = data["notes"] as? String ?? ""
        self.approveStatus = data["approveStatus"] as? String ?? "pending"

        if let ts = data["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = Date()
        }

        let docsData = data["documents"] as? [[String: Any]] ?? []
        self.documents = docsData.map { NGODocument(data: $0) }
        self.profile = data["profile"] as? String ?? ""
    }
}
