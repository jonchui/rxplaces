//
//  Place.swift
//
//  Created by Vitor Venturin Linhalis on 27/11/16.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import Foundation
import Mapper

struct Result : Mappable {
    var nextPageToken: String!
    var places: [Place]?
    var status: String!
    
    init(map: Mapper) throws {
        try nextPageToken = map.from("next_page_token")
        places = map.optionalFrom("results")
        try status = map.from("status")
    }
    
    init() {
    }
    
}
