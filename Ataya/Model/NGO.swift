//
//  NGO.swift
//  Ataya
//
//  Created by BP-36-224-14 on 30/12/2025.
//

import Foundation

class NGO {
    var name: String
    var type: String
    var rating: String
    var email: String
    var phone: String
    var mission: String
    
    // Add this property
    var profileImage: UIImage?
    
    init(name: String, type: String, rating: String, email: String, phone: String, mission: String, profileImage: UIImage? = nil) {
        self.name = name
        self.type = type
        self.rating = rating
        self.email = email
        self.phone = phone
        self.mission = mission
        self.profileImage = profileImage
    }
}
