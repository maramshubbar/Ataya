//
//  GiftCardDesign.swift
//  Ataya
//
//  Created by Fatema Maitham on 01/01/2026.
//

import FirebaseFirestore

struct GiftCardDesign {
    let id: String
    let title: String
    let imageURL: String?
    let isActive: Bool

    init?(_ doc: DocumentSnapshot) {
        let data = doc.data() ?? [:]

        let title = (data["title"] as? String) ?? ""
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return nil }

        self.id = doc.documentID
        self.title = title
        self.imageURL = (data["imageURL"] as? String)
            ?? (data["imageUrl"] as? String)
            ?? (data["url"] as? String)

        self.isActive = (data["isActive"] as? Bool) ?? true
    }
}
