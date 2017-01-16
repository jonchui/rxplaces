//
//  Product
//
//  Created by Vitor Venturin Linhalis.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import Foundation
import Mapper

struct Place : Mappable {
    var id: String!
    var name: String!
    var vicinity: String?
    var iconURL: String?
    var rating: Double?
    var photos: [Photo]?
    
    init(map: Mapper) throws {
        try id = map.from("id")
        try name = map.from("name")
        vicinity = map.optionalFrom("vicinity")
        iconURL = map.optionalFrom("icon")
        rating = map.optionalFrom("rating")
        if rating == nil {
            rating = 0.0
        }
        photos = map.optionalFrom("photos")
    }
    
    init() {
        
    }
}
