//
//  CardDesign.swift
//  Ataya
//
//  Created by Fatema Maitham on 25/12/2025.
//


//
//  CardDesign.swift
//  Ataya
//

import Foundation

struct CardDesign {
    var id: String
    var name: String
    var imageName: String
    var isActive: Bool
    var isDefault: Bool

    init(id: String = UUID().uuidString,
         name: String,
         imageName: String,
         isActive: Bool = true,
         isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.isActive = isActive
        self.isDefault = isDefault
    }
}
