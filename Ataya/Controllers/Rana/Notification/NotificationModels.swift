//
//  NotificationModels.swift
//  Ataya
//
//  Created by BP-36-224-15 on 02/01/2026.
//

import Foundation
import FirebaseFirestore

struct AppNotification {
    let id: String
    let toUserId: String
    let role: AppRole
    let title: String
    let message: String
    let createdAt: Date
    let isRead: Bool

    init?(id: String, data: [String: Any]) {
        guard
            let toUserId = data["toUserId"] as? String,
            let roleStr  = data["role"] as? String,
            let role     = AppRole(rawValue: roleStr),
            let title    = data["title"] as? String,
            let message  = data["message"] as? String
        else { return nil }

        let ts = data["createdAt"] as? Timestamp
        self.createdAt = ts?.dateValue() ?? Date()

        self.id = id
        self.toUserId = toUserId
        self.role = role
        self.title = title
        self.message = message
        self.isRead = data["isRead"] as? Bool ?? false
    }
}

struct NotificationSettingsModel {
    let allow: Bool
    let silent: Bool
}
