//
//  Type.swift
//  RxPlaces
//
//  Created by Vitor Venturin Linhalis on 12/12/16.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import Foundation

enum Type:Int, CustomStringConvertible {
    case
    accounting,
    airport,
    amusementPark,
    aquarium,
    artGallery,
    atm,
    bakery,
    bank,
    bar,
    beautySalon,
    bicycleStore,
    bookStore,
    bowlingAlley,
    busStation,
    cafe,
    campground,
    carDealer,
    carRental,
    carRepair,
    carWash,
    casino,
    cemetery,
    church,
    cityHall,
    clothingStore,
    convenienceStore,
    courthouse,
    dentist,
    departmentStore,
    doctor,
    electrician,
    electronicsStore,
    embassy,
    establishment,
    finance,
    fireStation,
    florist,
    food,
    funeralHome,
    furnitureStore,
    gasStation,
    generalContractor,
    groceryOrSupermarket,
    gym,
    hairCare,
    hardwareStore,
    health,
    hinduTemple,
    homeGoodsStore,
    hospital,
    insuranceAgency,
    jewelryStore,
    laundry,
    lawyer,
    library,
    liquorStore,
    localGovernmentOffice,
    locksmith,
    lodging,
    mealDelivery,
    mealTakeaway,
    mosque,
    movieRental,
    movieTheater,
    movingCompany,
    museum,
    nightClub,
    painter,
    park,
    parking,
    petStore,
    pharmacy,
    physiotherapist,
    placeOfWorship,
    plumber,
    police,
    postOffice,
    realEstateAgency,
    restaurant,
    roofingContractor,
    rvPark,
    school,
    shoeStore,
    shoppingMall,
    spa,
    stadium,
    storage,
    store,
    subwayStation,
    synagogue,
    taxiStand,
    trainStation,
    travelAgency,
    university,
    veterinaryCare,
    zoo
    
    var description : String {
        get {
            switch(self) {
            case .accounting: return "accounting"
            case .airport: return "airport"
            case .amusementPark: return "amusement_park"
            case .aquarium: return "aquarium"
            case .artGallery: return "art_gallery"
            case .atm: return "atm"
            case .bakery: return "bakery"
            case .bank: return "bank"
            case .bar: return "bar"
            case .beautySalon: return "beauty_salon"
            case .bicycleStore: return "bicycle_store"
            case .bookStore: return "book_store"
            case .bowlingAlley: return "bowling_alley"
            case .busStation: return "bus_station"
            case .cafe: return "cafe"
            case .campground: return "campground"
            case .carDealer: return "car_dealer"
            case .carRental: return "car_rental"
            case .carRepair: return "car_repair"
            case .carWash: return "car_wash"
            case .casino: return "casino"
            case .cemetery: return "cemetery"
            case .church: return "church"
            case .cityHall: return "city_hall"
            case .clothingStore: return "clothing_store"
            case .convenienceStore: return "convenience_store"
            case .courthouse: return "courthouse"
            case .dentist: return "dentist"
            case .departmentStore: return "department_store"
            case .doctor: return "doctor"
            case .electrician: return "electrician"
            case .electronicsStore: return "electronics_store"
            case .embassy: return "embassy"
            case .establishment: return "establishment"
            case .finance: return "finance"
            case .fireStation: return "fire_station"
            case .florist: return "florist"
            case .food: return "food"
            case .funeralHome: return "funeral_home"
            case .furnitureStore: return "furniture_store"
            case .gasStation: return "gas_station"
            case .generalContractor: return "general_contractor"
            case .groceryOrSupermarket: return "grocery_or_supermarket"
            case .gym: return "gym"
            case .hairCare: return "hair_care"
            case .hardwareStore: return "hardware_store"
            case .health: return "health"
            case .hinduTemple: return "hindu_temple"
            case .homeGoodsStore: return "home_goods_store"
            case .hospital: return "hospital"
            case .insuranceAgency: return "insurance_agency"
            case .jewelryStore: return "jewelry_store"
            case .laundry: return "laundry"
            case .lawyer: return "lawyer"
            case .library: return "library"
            case .liquorStore: return "liquor_store"
            case .localGovernmentOffice: return "local_government_office"
            case .locksmith: return "locksmith"
            case .lodging: return "lodging"
            case .mealDelivery: return "meal_delivery"
            case .mealTakeaway: return "meal_takeaway"
            case .mosque: return "mosque"
            case .movieRental: return "movie_rental"
            case .movieTheater: return "movie_theater"
            case .movingCompany: return "moving_company"
            case .museum: return "museum"
            case .nightClub: return "night_club"
            case .painter: return "painter"
            case .park: return "park"
            case .parking: return "parking"
            case .petStore: return "pet_store"
            case .pharmacy: return "pharmacy"
            case .physiotherapist: return "physiotherapist"
            case .placeOfWorship: return "place_of_worship"
            case .plumber: return "plumber"
            case .police: return "police"
            case .postOffice: return "post_office"
            case .realEstateAgency: return "real_estate_agency"
            case .restaurant: return "restaurant"
            case .roofingContractor: return "roofing_contractor"
            case .rvPark: return "rv_park"
            case .school: return "school"
            case .shoeStore: return "shoe_store"
            case .shoppingMall: return "shopping_mall"
            case .spa: return "spa"
            case .stadium: return "stadium"
            case .storage: return "storage"
            case .store: return "store"
            case .subwayStation: return "subway_station"
            case .synagogue: return "synagogue"
            case .taxiStand: return "taxi_stand"
            case .trainStation: return "train_station"
            case .travelAgency: return "travel_agency"
            case .university: return "university"
            case .veterinaryCare: return "veterinary_care"
            case .zoo: return "zoo"
            }
        }
    }
    
    static func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
        var i = 0
        return AnyIterator {
            let next = withUnsafePointer(to: &i) {
                $0.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
            }
            if next.hashValue != i { return nil }
            i += 1
            return next
        }
    }
}
