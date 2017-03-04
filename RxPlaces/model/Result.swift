//
//  Place.swift
//
//  Created by Vitor Venturin Linhalis on 27/11/16.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import Foundation
import Mapper
import RealmSwift
import Realm

class Result : Object, Mappable {
    dynamic var nextPageToken: String?
    var places: List<Place>?
    dynamic var status: String!
    
    required init(map: Mapper) throws {
        nextPageToken = map.optionalFrom("next_page_token")
        if let placesList : [Place] = map.optionalFrom("results") {
            places = List<Place>()
            for place in placesList {
                places!.append(place)
            }
        }
        try status = map.from("status")
        super.init()
    }
    
    required init() {
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init()
    }

    
}
