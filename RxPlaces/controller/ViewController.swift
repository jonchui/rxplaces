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

class ViewController: UIViewController, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    //outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var placeTableView: UITableView!
    @IBOutlet weak var progressBarView: ProgressBarView!
    @IBOutlet weak var typePickerView: TypePickerView!
    
    //constraints
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickerViewHeightConstraint: NSLayoutConstraint!
    
    //vars
    private var places:[Place]! = []
    private var rxPlaces:Observable<[Place]>!
    private let activityIndicator = ActivityIndicator()
    private var pagetoken:String?
    private var provider:RxMoyaProvider<GooglePlaces>! = RxMoyaProvider<GooglePlaces>()
    private var disposeBag:DisposeBag! = DisposeBag()
    private var selectedPlace:Place!
    private var pickerDatasource:[String]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupReachability()
        setupSearchBar()
        setupTableView()
        setupPickerView()
        setupConstraints()
//        didSearch(type: .airport)
    }
    
    func setupConstraints() {
    }
    
    func setupSearchBar() {
    }

    func setupPickerView() {
        self.typePickerView.pickerView.translatesAutoresizingMaskIntoConstraints = false
        self.typePickerView.pickerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.typePickerView.pickerView.dataSource = self
        self.typePickerView.pickerView.delegate = self
        
        Type.iterateEnum(Type.self).forEach { (element) in
            pickerDatasource.append(element.description)
        }
        
        typePickerView.pickerView
            .rx
            .itemSelected
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe { (event) in
                switch event {
                case let .next(response):
                    self.didSearch(type: Type(rawValue: response.0)!)
                case let .error(error):
                    print(error)
                case let .completed(completed):
                    print(completed)
                }
            }
            .addDisposableTo(self.disposeBag)
    }
    
    func setupTableView() {
        //setup custom cells
        let nib = UINib(nibName: CustomCellIdentifier.placeIdentifier, bundle: nil)
        placeTableView.register(nib, forCellReuseIdentifier: CustomCellIdentifier.placeIdentifier)
        
        // setup tableview delegate
        placeTableView
            .rx
            .setDelegate(self)
            .addDisposableTo(self.disposeBag)
        
        
        // item selected
        placeTableView.rx.itemSelected.subscribe { (indexPath) in
            self.selectedPlace = self.places?[indexPath.element!.row]
            self.performSegue(withIdentifier: "showDetails", sender: nil)
            }
            .addDisposableTo(self.disposeBag)
        
        self.setTableObservable()
    }
    
    public func setTableObservable() {
        self.rxPlaces = Observable.just([], scheduler: MainScheduler.instance)
        
        // observable table view 👍
        self.rxPlaces
            .bindTo(self.placeTableView.rx.items(cellIdentifier: CustomCellIdentifier.placeIdentifier, cellType: PlaceTableCell.self)){ (row, element, cell) in
                cell.nameLabel?.text = element.name
                cell.iconImageView.sd_setImage(with: URL(string: element.iconURL!), placeholderImage: UIImage(named: "PlaceholderH"))
                cell.vicinityLabel.text = element.vicinity
                if let rating = element.rating {
                    cell.ratingLabel.text = String(format: "%.1f", rating)
                }
            }
            .addDisposableTo(self.disposeBag)

    }
    
    private func didSearch(type: Type) {
        self.loadPlaces("34.052235,-118.243683", type: type, radius: 5000)
            .subscribeOn(MainScheduler.instance)
            .trackActivity(activityIndicator)
            .subscribe { event in
                switch event {
                case let .next(response):
                    
                    self.places = response
//                    print(self.places)
                    
                    self.rxPlaces = Observable.just(self.places)
                    
//                    self.pagetoken = response.nextPageToken
//                    print("page token: \(self.pagetoken)")
                case let .error(error):
                    print(error)
                case .completed():
                    self.progressBarView.isHidden = true
                }
            }
            .addDisposableTo(self.disposeBag)
    }
    
    func setupReachability() {
        let reachable = try! DefaultReachabilityService.init()
        
        reachable.reachability.subscribe { event in
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
    
    func loadPlaces(_ location: String, type: Type, radius: Int) -> Observable<[Place]> {
        return self.provider!
            .request(.getPlaces(location: location, type: type, radius: radius, key: GooglePlacesAPI.token))
            .observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
            .mapArray(type: Place.self, keyPath: "results")
    }
    
    func nextPage(_ pagetoken: String) -> Observable<Result> {
        return self.provider!
            .request(.getNextPage(nextPageToken: pagetoken, key: GooglePlacesAPI.token))
            .mapObject(type: Result.self)
            .observeOn(MainScheduler.instance)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showDetails") {
            if let detailsViewController = segue.destination as? DetailsViewController {
                detailsViewController.place = self.selectedPlace
            }
        }
    }
    
    @IBAction func showHideSearchBar(_ sender: Any) {
        self.searchBar.isHidden = !self.searchBar.isHidden
        self.searchBarHeightConstraint.constant = self.searchBar.isHidden ? 0 : 44
    }
    
    @IBAction func chooseType(_ sender: Any) {
        self.typePickerView.isHidden = !self.typePickerView.isHidden
        self.pickerViewHeightConstraint.constant = self.typePickerView.isHidden ? 0 : 150
    }
    
    //Mark - UIPickerViewDelegate:
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDatasource[row]
    }
    
    //Mark - UIPickerViewDatasource:
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDatasource.count
    }
    
    @IBAction func addPlace(_ sender: Any) {
        var newPlace = Place()
        newPlace.id = "12312312321"
        newPlace.name = "hidden place"
        newPlace.vicinity = "hidden street"
        self.places.append(newPlace)
        
        self.rxPlaces = Observable.just(self.places)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
