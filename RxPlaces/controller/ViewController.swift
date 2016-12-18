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
    @IBOutlet weak var typePickerView: UIPickerView!
    @IBOutlet var tableHeaderView: UIView!
    @IBOutlet weak var tableHeaderLabel: UILabel!
    @IBOutlet weak var typeBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var searchBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var sortBarButtonItem: UIBarButtonItem!
    
    //vars
    private var places:[Place]! = []
    private var rxPlaces:Variable<[Place]>! = Variable([])
    private let activityIndicator = ActivityIndicator()
    private var pagetoken:String?
    private var provider:RxMoyaProvider<GooglePlaces>! = RxMoyaProvider<GooglePlaces>()
    private var disposeBag:DisposeBag! = DisposeBag()
    private var pickerDatasource:[String]! = []
    private var selectedType:Type?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupReachability()
        setupSearchBar()
        setupTableView()
        setupPickerView()
        setupBarButtonItems()
        setupRx()
    }
    
    func setupBarButtonItems() {
        self.typeBarButtonItem
            .rx
            .tap
            .asDriver()
            .debounce(0.25)
            .drive(onNext: { [unowned self] in
                self.typePickerView.showHide()
            })
            .addDisposableTo(self.disposeBag)
        
        self.searchBarButtonItem
        .rx
        .tap
        .asDriver()
        .debounce(0.25)
        .drive(onNext: { [unowned self] in
            self.searchBar.showHide()
        })
        .addDisposableTo(self.disposeBag)
        
        self.addBarButtonItem
        .rx
        .tap
        .asDriver()
        .drive(onNext: { [unowned self] in
            var newPlace = Place()
            newPlace.id = String(arc4random()%100)
            newPlace.name = "hidden place"
            newPlace.vicinity = "hidden street"
            newPlace.rating = Double(arc4random()%5)
            self.places.append(newPlace)
            self.rxPlaces.value = self.places
            })
            .addDisposableTo(self.disposeBag)
        
        self.sortBarButtonItem
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [unowned self] in
                self.rxPlaces.value.sort(by: { (a, b) -> Bool in
                    return floor(a.rating!) > floor(b.rating!)
                })
            })
            .addDisposableTo(self.disposeBag)
    }
    
    func setupSearchBar() {
        
    }

    func setupPickerView() {
        self.typePickerView.dataSource = self
        self.typePickerView.delegate = self
        
        Type.iterateEnum(Type.self).forEach { (element) in
            pickerDatasource.append(element.description)
        }
        
        typePickerView
            .rx
            .itemSelected
            .subscribe { (event) in
                switch event {
                case let .next(response):
                    self.selectedType = Type(rawValue: response.0)!
                    self.didSearch(type: self.selectedType!)
                default:
                    break
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
        placeTableView
            .rx
            .modelSelected(Place.self)
            .subscribe(onNext: { (place) in
                self.performSegue(withIdentifier: "showDetails", sender: place)
            })
            .addDisposableTo(self.disposeBag)
    }
    
    public func setupRx() {
        // observable table view 👍
        self.rxPlaces
            .asDriver()
            .drive(self.placeTableView.rx.items(cellIdentifier: CustomCellIdentifier.placeIdentifier, cellType: PlaceTableCell.self)){ (row, element, cell) in
                cell.nameLabel?.text = element.name
                if let iconURL = element.iconURL {
                    cell.iconImageView.sd_setImage(with: URL(string: iconURL), placeholderImage: UIImage(named: "PlaceholderH"))
                }
                cell.vicinityLabel.text = element.vicinity
                if let rating = element.rating {
                    cell.ratingLabel.text = String(format: "%.1f", rating)
                }
//                self.typePickerView.showHide()
//                self.searchBar.showHide()
            }
            .addDisposableTo(self.disposeBag)
    }
    
    private func didSearch(type: Type) {
        self.loadPlaces("34.052235,-118.243683", type: type, radius: 5000)
            .trackActivity(activityIndicator)
            .subscribe { event in
                switch event {
                case let .next(response):
                    self.places = response.places
                    self.pagetoken = response.nextPageToken
                    self.rxPlaces.value = self.places
                    self.typePickerView.showHide()
                case .error:
                    let alertController = UIAlertController(title: "Error", message: "You are offline", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(action)
                    if !(self.navigationController!.visibleViewController!.isKind(of: UIAlertController.self)) {
                        self.navigationController?.present(alertController, animated: true, completion: nil)
                    }
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
                    let alertController = UIAlertController(title: "Error", message: reachable._reachability.currentReachabilityStatus.description, preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(action)
                    if !(self.navigationController!.visibleViewController!.isKind(of: UIAlertController.self)) {
                        self.navigationController?.present(alertController, animated: true, completion: nil)
                    }
                }
            default:
                break
            }
        }
        .addDisposableTo(self.disposeBag)
        
        activityIndicator
            .asDriver()
            .map { !$0 }
            .drive(progressBarView.rx.isHidden)
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
            .observeOn(MainScheduler.instance)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showDetails") {
            if let detailsViewController = segue.destination as? DetailsViewController {
                detailsViewController.place = sender as? Place
            }
        }
    }
    
    //MARK: UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDatasource[row]
    }
    
    //MARK: UIPickerViewDatasource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDatasource.count
    }
    
    //MARK: UITableViewDatasource
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.tableHeaderLabel.text = self.selectedType?.description
        return self.tableHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (self.selectedType != nil) {
            return 44
        } else {
            return 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
