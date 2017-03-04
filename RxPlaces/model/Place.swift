//
//  Product
//
//  Created by Vitor Venturin Linhalis.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import Foundation
import Mapper
import RealmSwift
import Realm

class Place : Object, Mappable  {
    dynamic var id: String!
    dynamic var name: String!
    dynamic var vicinity: String?
    dynamic var iconURL: String?
    dynamic var rating: Double = -1
    var photos: List<Photo>?
    
    required init(map: Mapper) throws {
        try id = map.from("id")
        try name = map.from("name")
        vicinity = map.optionalFrom("vicinity")
        iconURL = map.optionalFrom("icon")
        if let optionalRating : Double = map.optionalFrom("rating") {
            rating = optionalRating
        } else {
            rating = 0.0
        }
        if let photosList : [Photo] = map.optionalFrom("photos") {
            photos = List<Photo>()
            for photo in photosList {
                photos!.append(photo)
            }
        }
        super.init()
    }

    required init() {
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        fatalError("init(value:schema:) has not been implemented")
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        fatalError("init(realm:schema:) has not been implemented")
    }

}
