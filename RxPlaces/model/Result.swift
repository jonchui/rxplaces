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
    dynamic var places: [Place]?
    dynamic var status: String!
    
    required init(map: Mapper) throws {
        nextPageToken = map.optionalFrom("next_page_token")
        places = map.optionalFrom("results")
        try status = map.from("status")
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
