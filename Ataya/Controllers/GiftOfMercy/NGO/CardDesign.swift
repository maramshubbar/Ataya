import Foundation
import FirebaseFirestore

struct CardDesign {

    var id: String
    var name: String

    // UI fallback (Assets) – تظل موجودة لأن UI عندك يعتمد عليها
    var imageName: String

    var isActive: Bool
    var isDefault: Bool

    // Cloudinary (اختياري)
    var imageURL: String?
    var imagePublicId: String?

    // Ownership / tracking (اختياري)
    var ngoId: String?
    var createdAt: Timestamp?
    var updatedAt: Timestamp?

    init(
        id: String = UUID().uuidString,
        name: String,
        imageName: String,
        isActive: Bool = true,
        isDefault: Bool = false,
        imageURL: String? = nil,
        imagePublicId: String? = nil,
        ngoId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.isActive = isActive
        self.isDefault = isDefault
        self.imageURL = imageURL
        self.imagePublicId = imagePublicId
        self.ngoId = ngoId
    }
}

// MARK: - Firestore mapping
extension CardDesign {

    func toFirestoreDict() -> [String: Any] {
        var data: [String: Any] = [
            "name": name,
            "imageName": imageName,
            "isActive": isActive,
            "isDefault": isDefault
        ]

        if let imageURL { data["imageURL"] = imageURL }
        if let imagePublicId { data["imagePublicId"] = imagePublicId }
        if let ngoId { data["ngoId"] = ngoId }

        return data
    }

    init?(doc: DocumentSnapshot) {
        let d = doc.data() ?? [:]

        guard let name = d["name"] as? String else { return nil }
        let imageName = d["imageName"] as? String ?? "c1"

        self.id = doc.documentID
        self.name = name
        self.imageName = imageName

        self.isActive = d["isActive"] as? Bool ?? true
        self.isDefault = d["isDefault"] as? Bool ?? false

        self.imageURL = d["imageURL"] as? String
        self.imagePublicId = d["imagePublicId"] as? String

        self.ngoId = d["ngoId"] as? String
        self.createdAt = d["createdAt"] as? Timestamp
        self.updatedAt = d["updatedAt"] as? Timestamp
    }
}
