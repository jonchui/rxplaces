//
//  PlaceViewModel.swift
//  RxPlaces
//
//  Created by Vitor Venturin Linhalis on 17/01/17.
//  Copyright © 2017 Vitor Venturin Linhalis. All rights reserved.
//

import UIKit
import RxSwift
import Moya
import RealmSwift


class PlaceViewModel: NSObject {
//    var places: Results<Place> {
//        get {
//            return try! Realm().objects(Place.self)
//        }
//    }
    var places:[Place]!
    var rxPlaces:Variable<[Place]>? = Variable([])
    var pagetoken:String?
    var disposeBag:DisposeBag! = DisposeBag()
    var provider:RxMoyaProvider<GooglePlaces>! = RxMoyaProvider<GooglePlaces>()
    
    func loadPlaces(_ location: String, type: Type, radius: Int) -> Observable<Result> {
        return self.provider!
            .request(.getPlaces(location: location, type: type, radius: radius, key: GooglePlacesAPI.token))
            .mapObject(type: Result.self)
    }
    
    func nextPage(_ pagetoken: String) -> Observable<Result> {
        return self.provider!
            .request(.getNextPage(nextPageToken: pagetoken, key: GooglePlacesAPI.token))
            .mapObject(type: Result.self)
            .observeOn(MainScheduler.instance)
    }

    func addNewPlace(_ place: Place) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(place)
        }
    }

    //    losAngeles = "34.052235,-118.243683" (latitude, longitude)
}
