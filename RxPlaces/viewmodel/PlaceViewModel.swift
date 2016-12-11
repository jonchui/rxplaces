//
//  ViewModel.swift
//
//  Created by Vitor Venturin Linhalis on 27/11/16.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class PlaceViewModel {
    var disposeBag:DisposeBag! = DisposeBag()
    var provider:RxMoyaProvider<GooglePlaces>! = RxMoyaProvider<GooglePlaces>()
    var places:Variable<[Place]>! = Variable([Place]())
    
    func loadPlaces(_ location: String, type: String, radius: Int) -> Observable<Result> {
        return self.provider!
            .request(.getPlaces(location: location, type: type, radius: radius, key: GooglePlacesAPI.token))
            .mapObject(type: Result.self)
    }
    
    func nextPage(_ pagetoken: String) -> Observable<Result> {
        return self.provider!
            .request(.getNextPage(nextPageToken: pagetoken, key: GooglePlacesAPI.token))
            .mapObject(type: Result.self)
    }
}
