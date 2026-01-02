import UIKit

class Ngo {
    var name: String
    var type: String
    var rating: String
    var email: String
    var phone: String
    var mission: String
    
    // For dummy testing
    var profileImage: UIImage?
    
    init(name: String,
         type: String,
         rating: String,
         email: String,
         phone: String,
         mission: String,
         profileImage: UIImage? = nil) {
        self.name = name
        self.type = type
        self.rating = rating
        self.email = email
        self.phone = phone
        self.mission = mission
        self.profileImage = profileImage
    }
}
