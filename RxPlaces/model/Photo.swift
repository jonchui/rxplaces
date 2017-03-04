//
//  Photo.swift
//  bestbuy
//
//  Created by Vitor Venturin Linhalis on 23/11/16.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import Foundation
import Mapper
import RealmSwift
import Realm

class Photo : Object, Mappable {
    dynamic var reference: String!
    dynamic var w:Int = 0
    dynamic var h:Int = 0
    
    required init(map: Mapper) throws {
        try reference = map.from("photo_reference")
        try w = map.from("width")
        try h = map.from("height")
        super.init()
    }
    
    override static func primaryKey() -> String? {
        return "reference"
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
