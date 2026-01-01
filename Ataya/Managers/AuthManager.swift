//
//  AuthManager.swift
//  Ataya
//
//  Created by Fatema Maitham on 17/12/2025.
//

import Foundation
import FirebaseAuth

// Handles getting a donorId (uid) even if you don't have donor accounts yet.
// We use Anonymous Auth so Feature 1 can be completed end-to-end.
final class AuthManager {

    // Shared singleton instance
    static let shared = AuthManager()
    private init() {}

    // Ensures we have a logged-in Firebase user.
    // If user already exists → do nothing
    // If no user → sign in anonymously (creates a uid)
    func ensureSignedIn() async throws {
        if Auth.auth().currentUser != nil { return }          // already signed in
        _ = try await Auth.auth().signInAnonymously()          // create anonymous user
    }

    // The donorId we store inside donations (Firestore).
    // If empty, it means no user is signed in yet.
    var uid: String {
        Auth.auth().currentUser?.uid ?? ""
    }
}
