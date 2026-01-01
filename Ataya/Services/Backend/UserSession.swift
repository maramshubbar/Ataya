//
//  UserSession.swift
//  Ataya
//
//  Created by Maram on 21/12/2025.
//

import Foundation

final class UserSession {
    static let shared = UserSession()
    private init() {}

    // مؤقت لين يخلصون اللوقن في البرانش الثاني
    // يولد UUID أول مرة ويخزنه
    private let key = "temp_user_id"

    var currentUserId: String {
        if let saved = UserDefaults.standard.string(forKey: key), !saved.isEmpty {
            return saved
        }
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }

    // لما يدمجون اللوقن: بدلّي currentUserId يرجع FirebaseAuth UID
    // وخلي هذا الاحتياطي لو احتجتيه
    func setUserIdFromAuth(_ uid: String) {
        UserDefaults.standard.set(uid, forKey: key)
    }
}

