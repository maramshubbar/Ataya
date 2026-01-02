//
//  NotificationService.swift
//  Ataya
//
//  Created by BP-36-224-15 on 02/01/2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

final class NotificationService {

    static let shared = NotificationService()
    private init() {}

    private let db = Firestore.firestore()
    private let notifCollection = "notification"

    // MARK: - Realtime listen notifications
    func listenNotifications(uid: String,
                             role: AppRole,
                             onChange: @escaping ([AppNotification]) -> Void) -> ListenerRegistration {

        db.collection(notifCollection)
            .whereField("toUserId", isEqualTo: uid)
            .whereField("role", isEqualTo: role.rawValue)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snap, error in
                if let error = error {
                    print("listenNotifications error:", error.localizedDescription)
                    onChange([])
                    return
                }

                let items: [AppNotification] = (snap?.documents ?? []).compactMap { doc in
                    AppNotification(id: doc.documentID, data: doc.data())
                }
                onChange(items)
            }
    }

    // MARK: - Create Firestore notification + local banner
    func createNotification(toUserId: String,
                            role: AppRole,
                            title: String,
                            message: String,
                            completion: ((Error?) -> Void)? = nil) {

        let data: [String: Any] = [
            "toUserId": toUserId,
            "role": role.rawValue,
            "title": title,
            "message": message,
            "createdAt": FieldValue.serverTimestamp(),
            "isRead": false
        ]

        db.collection(notifCollection).addDocument(data: data) { [weak self] err in
            completion?(err)
            guard err == nil else { return }
            self?.showLocalBannerIfAllowed(role: role, title: title, body: message)
        }
    }

    // MARK: - Clear all for this role
    func clearAll(uid: String, role: AppRole, completion: ((Error?) -> Void)? = nil) {
        db.collection(notifCollection)
            .whereField("toUserId", isEqualTo: uid)
            .whereField("role", isEqualTo: role.rawValue)
            .getDocuments { snap, error in
                if let error = error {
                    completion?(error)
                    return
                }

                let batch = self.db.batch()
                snap?.documents.forEach { batch.deleteDocument($0.reference) }

                batch.commit { err in
                    completion?(err)
                }
            }
    }

    // MARK: - Settings per role
    func ensureDefaultSettings(uid: String, role: AppRole) {
        let ref = db.collection("users").document(uid)
            .collection("notificationSettings").document(role.rawValue)

        ref.getDocument { snap, _ in
            if snap?.exists == true { return }
            ref.setData([
                "allow": true,
                "silent": false,
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)
        }
    }

    func listenSettings(uid: String, role: AppRole,
                        onChange: @escaping (NotificationSettingsModel) -> Void) -> ListenerRegistration {

        let ref = db.collection("users").document(uid)
            .collection("notificationSettings").document(role.rawValue)

        return ref.addSnapshotListener { snap, error in
            if let error = error {
                print("listenSettings error:", error.localizedDescription)
                onChange(NotificationSettingsModel(allow: true, silent: false))
                return
            }

            let allow = snap?.get("allow") as? Bool ?? true
            let silent = snap?.get("silent") as? Bool ?? false
            onChange(NotificationSettingsModel(allow: allow, silent: silent))
        }
    }

    func saveSettings(uid: String, role: AppRole, allow: Bool, silent: Bool, completion: ((Error?) -> Void)? = nil) {
        let ref = db.collection("users").document(uid)
            .collection("notificationSettings").document(role.rawValue)

        ref.setData([
            "allow": allow,
            "silent": silent,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true, completion: completion)
    }

    // MARK: - Local banner respecting Firestore settings
    private func showLocalBannerIfAllowed(role: AppRole, title: String, body: String) {

        guard let uid = Auth.auth().currentUser?.uid else { return }

        let ref = db.collection("users").document(uid)
            .collection("notificationSettings").document(role.rawValue)

        ref.getDocument { snap, _ in
            let allow = snap?.get("allow") as? Bool ?? true
            let silent = snap?.get("silent") as? Bool ?? false
            guard allow else { return }

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = silent ? nil : .default
            content.userInfo = ["role": role.rawValue]

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { err in
                if let err = err { print("Local banner error:", err.localizedDescription) }
            }
        }
    }
}
