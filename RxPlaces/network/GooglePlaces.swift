//
//  ProductService.swift
//
//  Created by Vitor Venturin Linhalis.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import Foundation
import Moya

struct GooglePlacesAPI {
    static let token = "AIzaSyDffA3hy-NGKiioEwNg6jtSFI3qaOsxCpA"
}

// MARK: - TargetType Protocol Implementation
enum GooglePlaces : TargetType {
    case getPlaces(location: String, type: Type, radius: Int, key: String)
    case getPhoto(photo: Photo, key: String)
    case getNextPage(nextPageToken: String, key: String)

    var baseURL: URL { return URL(string: "https://maps.googleapis.com/maps/api/place")! }
    
    var path: String {
        switch self {
        case .getPlaces:
            return "/nearbysearch/json"
        case .getPhoto:
            return "/photo"
        case .getNextPage:
            return "/nearbysearch/json"
        }
    }
    var method: Moya.Method {
        switch self {
        case .getPlaces, .getPhoto, .getNextPage:
            return .get
        }
    }
    var parameters: [String: Any]? {
        switch self {
        case .getPlaces(let location, let type, let radius, let key):
            return ["location": location, "type": type, "radius": radius, "key": key]
        case .getPhoto(let photo, let key):
            return ["maxwidth": photo.w, "maxheight": photo.h, "photoreference": photo.reference, "key": key]
        case .getNextPage(let nextPageToken, let key):
            return ["pagetoken": nextPageToken, "key": key]
        }
    }
    var sampleData: Data { return Data() }
    
    var task: Task {
        switch self {
        case .getPlaces, .getPhoto, .getNextPage:
            return .request
        }
    }
}
