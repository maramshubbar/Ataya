import Foundation
import FirebaseFirestore

struct CardDesign {

    enum Keys {
        static let name = "name"
        static let imageName = "imageName"
        static let isActive = "isActive"
        static let isDefault = "isDefault"
        static let imageURL = "imageURL"
        static let imagePublicId = "imagePublicId"
        static let ngoId = "ngoId"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }

    var id: String
    var name: String

    // UI fallback (Assets) – نخليها عشان UI عندك يعتمد عليها
    var imageName: String

    var isActive: Bool
    var isDefault: Bool

    // Cloudinary
    var imageURL: String?
    var imagePublicId: String?

    // Tracking
    var ngoId: String?
    var createdAt: Timestamp?
    var updatedAt: Timestamp?

    init(
        id: String = UUID().uuidString,
        name: String,
        imageName: String = "c1",
        isActive: Bool = true,
        isDefault: Bool = false,
        imageURL: String? = nil,
        imagePublicId: String? = nil,
        ngoId: String? = nil,
        createdAt: Timestamp? = nil,
        updatedAt: Timestamp? = nil
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.isActive = isActive
        self.isDefault = isDefault
        self.imageURL = imageURL
        self.imagePublicId = imagePublicId
        self.ngoId = ngoId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// لو ما عندنا URL نرجع اسم asset
    var displayImageName: String { imageName.isEmpty ? "c1" : imageName }
}

// MARK: - Firestore mapping
extension CardDesign {

    func toFirestoreDict() -> [String: Any] {
        var data: [String: Any] = [
            Keys.name: name,
            Keys.imageName: imageName,
            Keys.isActive: isActive,
            Keys.isDefault: isDefault,
            Keys.updatedAt: FieldValue.serverTimestamp()
        ]

        if let imageURL, !imageURL.isEmpty { data[Keys.imageURL] = imageURL }
        if let imagePublicId, !imagePublicId.isEmpty { data[Keys.imagePublicId] = imagePublicId }
        if let ngoId, !ngoId.isEmpty { data[Keys.ngoId] = ngoId }

        // createdAt يتم ضبطه مرة واحدة من الـ Service (إذا جديد)
        return data
    }

    init?(doc: DocumentSnapshot) {
        let d = doc.data() ?? [:]
        guard let name = d[Keys.name] as? String else { return nil }

        self.id = doc.documentID
        self.name = name
        self.imageName = (d[Keys.imageName] as? String) ?? "c1"

        self.isActive = (d[Keys.isActive] as? Bool) ?? true
        self.isDefault = (d[Keys.isDefault] as? Bool) ?? false

        self.imageURL = d[Keys.imageURL] as? String
        self.imagePublicId = d[Keys.imagePublicId] as? String

        self.ngoId = d[Keys.ngoId] as? String
        self.createdAt = d[Keys.createdAt] as? Timestamp
        self.updatedAt = d[Keys.updatedAt] as? Timestamp
    }
}
