//
//  FirestoreSmokeTest.swift
//  Ataya
//
//  Created by Fatema Maitham on 17/12/2025.
//

import Foundation
import FirebaseFirestore

final class FirestoreSmokeTest {

    // to avoid writing many times
    private static var didRun = false

    static func runOnce() {
        guard !didRun else { return }
        didRun = true

        let db = Firestore.firestore()

        db.collection("debug_smoke").addDocument(data: [
            "message": "Firestore is working ✅",
            "deviceTime": Date().description,
            "createdAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("❌ Firestore write FAILED:", error.localizedDescription)
            } else {
                print("✅ Firestore write SUCCESS: check Firestore → debug_smoke")
            }
        }
    }
}
