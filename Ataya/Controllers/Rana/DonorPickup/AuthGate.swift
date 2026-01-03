//
//  AuthGate.swift
//  Ataya
//
//  Created by BP-36-224-15 on 02/01/2026.
//

// AuthGate.swift
import FirebaseAuth

enum AuthGate {

    static func ensureLoggedIn(_ completion: @escaping (Bool) -> Void) {
        if Auth.auth().currentUser != nil {
            completion(true)
            return
        }

        Auth.auth().signInAnonymously { _, error in
            completion(error == nil)
        }
    }
}
