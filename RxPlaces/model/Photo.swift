//
//  Photo.swift
//  bestbuy
//
//  Created by Vitor Venturin Linhalis on 23/11/16.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import Foundation
import Mapper

struct Photo : Mappable {
    var reference: String!
    var w:Int!
    var h:Int!
    
    init(map: Mapper) throws {
        try reference = map.from("photo_reference")
        try w = map.from("width")
        try h = map.from("height")
    }
}
