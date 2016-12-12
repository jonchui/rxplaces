//
//  ViewController.swift
//
//  Created by Vitor Venturin Linhalis on 26/11/16.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import Moya_ModelMapper
import SDWebImage

struct CustomCellIdentifier {
    static let placeIdentifier = "PlaceTableCell"
}

class ViewController: UIViewController, UITableViewDelegate {
    //outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var placeTableView: UITableView!
    @IBOutlet weak var progressBarView: ProgressBarView!
    
    //vars
    private var places:[Place]! = []
    
    private let activityIndicator = ActivityIndicator()
    private var pagetoken:String?
    private var provider:RxMoyaProvider<GooglePlaces>! = RxMoyaProvider<GooglePlaces>()
    private var disposeBag:DisposeBag! = DisposeBag()
    private var selectedPlace:Place!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupReachability()
        setupTableView()
        didSearch(type: .carRepair)
//        setupSearchBar()
    }
    
//    func setupSearchBar() {
//        searchBar
//            .rx.text
//            .throttle(0.5, scheduler: MainScheduler.instance) // Wait 0.5 for changes.
////            .distinctUntilChanged() // If they didn't occur, check if the new value is the same as old.
////            .filter { $0.characters.count > 0 }
//            .subscribe { [unowned self] (query) in
//                self.didSearch(type: query.element!)
//                self.places = []
//            }
//            .addDisposableTo(self.disposeBag)
//    }
    
    func setupTableView() {
        //setup custom cells
        let nib = UINib(nibName: CustomCellIdentifier.placeIdentifier, bundle: nil)
        placeTableView.register(nib, forCellReuseIdentifier: CustomCellIdentifier.placeIdentifier)
        
        // setup tableview delegate
        placeTableView
            .rx.setDelegate(self)
            .addDisposableTo(self.disposeBag)
        
        // observable table view 👍
        Observable.just(self.places)
            .bindTo(self.placeTableView.rx.items(cellIdentifier: CustomCellIdentifier.placeIdentifier, cellType: PlaceTableCell.self)){ (row, element, cell) in
                cell.nameLabel?.text = element.name
                cell.iconImageView.sd_setImage(with: URL(string: element.iconURL!), placeholderImage: UIImage(named: "PlaceholderH"))
                cell.vicinityLabel.text = element.vicinity
                if let rating = element.rating {
                    cell.ratingLabel.text = String(format: "%.1f", rating)
                }
            }
            .addDisposableTo(self.disposeBag)
        
        // item selected
//        placeTableView.rx.itemSelected.subscribe { [unowned self] (indexPath) in
//            let justPlaces = Observable.just(self.places)
//            self.selectedPlace = justPlaces[indexPath.row]
//            self.performSegue(withIdentifier: "showDetails", sender: self.placeTableView.indexPathForSelectedRow)
//            }
//            .addDisposableTo(self.disposeBag)
        
        // infinite scroll
//        placeTableView.rx.didEndDisplayingCell
//            .subscribe { [unowned self] 🤔 in
//                if self.progressBarView.isHidden && !self.places.value.isEmpty {
//                    if let token = self.pagetoken {
//                        self.nextPage(token)
//                            .trackActivity(self.activityIndicator)
//                            .subscribe { [unowned self] event in
//                                switch event {
//                                case let .next(response):
//                                    if let places = response.places {
//                                        self.places.value.append(contentsOf: places)
//                                    }
//                                    self.pagetoken = response.nextPageToken
//                                case .error:
//                                    print(🤔.element!.indexPath.row)
//                                    if (🤔.element!.indexPath.row == self.places.value.count) {
//                                        let alertController = self.alertController(title: "End of results", message: "There is no more results to show", preferredStyle: .actionSheet, actions: [UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)])
//                                        if !(self.navigationController!.visibleViewController!.isKind(of: UIAlertController.self)) {
//                                            DispatchQueue.main.async {
//                                                self.present(alertController, animated: true, completion: nil)
//                                            }
//                                        }
//                                    }
//                                case .completed():
//                                    print("completed")
//                                    self.progressBarView.isHidden = true
//                                }
//                            }
//                            .addDisposableTo(self.disposeBag)
//                    }
//                }
//            }
//            .addDisposableTo(self.disposeBag)

    }
    
    private func didSearch(type: Type) {
        self.loadPlaces("34.052235,-118.243683", type: type, radius: 500)
            .trackActivity(activityIndicator)
            .subscribe { [unowned self] event in
                switch event {
                case let .next(response):
                    if let places = response.places {
                        self.places = places
                    }
                    self.pagetoken = response.nextPageToken
                case let .error(error):
                    print(error)
                case .completed():
                    print("completed")
                    self.progressBarView.isHidden = true
                }
            }
            .addDisposableTo(self.disposeBag)
    }
    
    func setupReachability() {
        let reachable = try! DefaultReachabilityService.init()
        
        reachable.reachability.subscribe { [unowned self] event in
            switch (event) {
            case let .next(status):
                print("network is \(status)")
                if !reachable._reachability.isReachable {
                    let alertController = self.alertController(title: "Error", message: reachable._reachability.currentReachabilityStatus.description, preferredStyle: UIAlertControllerStyle.alert, actions: [UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)])
                    if !(self.navigationController!.visibleViewController!.isKind(of: UIAlertController.self)) {
                        DispatchQueue.main.async {
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            default:
                break
            }
        }
        .addDisposableTo(self.disposeBag)
        
        activityIndicator
            .asObservable()
            .bindTo(progressBarView.rx.isNotHidden)
            .addDisposableTo(self.disposeBag)
        
    }
    
    func loadPlaces(_ location: String, type: Type, radius: Int) -> Observable<Result> {
        return self.provider!
            .request(.getPlaces(location: location, type: type, radius: radius, key: GooglePlacesAPI.token))
            .mapObject(type: Result.self)
    }
    
    func nextPage(_ pagetoken: String) -> Observable<Result> {
        return self.provider!
            .request(.getNextPage(nextPageToken: pagetoken, key: GooglePlacesAPI.token))
            .mapObject(type: Result.self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showDetails") {
            if let detailsViewController = segue.destination as? DetailsViewController {
//                let cell = placeTableView.cellForRow(at: sender as! IndexPath) as! PlaceTableCell
                detailsViewController.place = self.selectedPlace
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
