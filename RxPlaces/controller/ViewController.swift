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
import CoreLocation
import RealmSwift

struct CustomCellIdentifier {
    static let placeIdentifier = "PlaceTableCell"
}

class ViewController: UIViewController {
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
    fileprivate var pickerDatasource:[String]! = []
    fileprivate var placeViewModel = PlaceViewModel()
    fileprivate let locationManager = CLLocationManager()
    private let activityIndicator = ActivityIndicator()
    private var sortOrder:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupReachability()
        setupGeolocation()
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
            .addDisposableTo(placeViewModel.disposeBag)
        
        self.searchBarButtonItem
        .rx
        .tap
        .asDriver()
        .debounce(0.25)
        .drive(onNext: { [unowned self] in
            self.searchBar.showHide()
        })
        .addDisposableTo(placeViewModel.disposeBag)
        
        self.addBarButtonItem
        .rx
        .tap
        .asDriver()
        .drive(onNext: { [unowned self] in
            var newPlace = Place()
            newPlace.id = String(arc4random()%10000)
            newPlace.name = "hidden place"
            newPlace.vicinity = "hidden street"
            newPlace.rating = Double(arc4random()%50)/10
            self.placeViewModel.addNewPlace(newPlace)
            })
            .addDisposableTo(placeViewModel.disposeBag)
        
        self.sortBarButtonItem
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [unowned self] in
                self.sortOrder = !self.sortOrder
                self.placeViewModel.rxPlaces.value.sort(by: { (a, b) -> Bool in
                    if (self.sortOrder) {
                        return a.rating > b.rating
                    } else {
                        return a.rating < b.rating
                    }
                })
            })
            .addDisposableTo(placeViewModel.disposeBag)
    }
    
    func setupSearchBar() {
        self.searchBar.isHidden = true
        searchBar
            .rx.text
            .orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] query in
                self.placeViewModel.rxPlaces.value = self.placeViewModel.places.filter { filteredPlace in
                    let hasPrefix = filteredPlace.name.hasPrefix(query)
                    return hasPrefix
                }
            })
            .addDisposableTo(self.placeViewModel.disposeBag)
    }

    public func setupRx() {
        // observable table view 👍
        self.placeViewModel.rxPlaces
            .asDriver()
            .drive(self.placeTableView.rx.items(cellIdentifier: CustomCellIdentifier.placeIdentifier, cellType: PlaceTableCell.self)){ (row, element, cell) in
                cell.nameLabel?.text = element.name
                if let iconURL = element.iconURL {
                    cell.iconImageView.sd_setImage(with: URL(string: iconURL), placeholderImage: UIImage(named: "PlaceholderH"))
                }
                cell.vicinityLabel.text = element.vicinity
                cell.ratingLabel.text = String(format: "%.1f", element.rating)
            }
            .addDisposableTo(placeViewModel.disposeBag)
    }
    
    fileprivate func fetchPlacesBy(type: Type) {
        let lat = self.locationManager.location?.coordinate.latitude
        let long = self.locationManager.location?.coordinate.longitude
        let stringLocation = "\(lat!), \(long!)"
        print(stringLocation)
        self.placeViewModel.loadPlaces(stringLocation, type: type, radius: 5000)
            .trackActivity(activityIndicator)
            .subscribe { event in
                switch event {
                case let .next(response):
                    if let places = response.places {
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(places)
                        }
                    self.placeViewModel.places = Array(places)
                    }
                    self.placeViewModel.pagetoken = response.nextPageToken
                    self.placeViewModel.rxPlaces.value = Array(self.placeViewModel.places)
                    self.typePickerView.showHide()
                case .error:
                    let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("You are offline", comment: "You are offline"), preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(action)
                    if !(self.navigationController!.visibleViewController!.isKind(of: UIAlertController.self)) {
                        OperationQueue.main.addOperation {
                            self.navigationController?.present(alertController, animated: true, completion: nil)
                        }
                    }
                case .completed():
                    self.progressBarView.isHidden = true
                }
            }
            .addDisposableTo(placeViewModel.disposeBag)
    }
    
    func setupReachability() {
        let reachable = try! DefaultReachabilityService.init()
        
        reachable.reachability.subscribe { event in
            switch (event) {
            case let .next(status):
                print("network is \(status)")
                if !reachable._reachability.isReachable {
                    let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString(reachable._reachability.currentReachabilityStatus.description, comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(action)
                    if !(self.navigationController!.visibleViewController!.isKind(of: UIAlertController.self)) {
                        OperationQueue.main.addOperation {
                            self.navigationController?.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            default:
                break
            }
        }
        .addDisposableTo(placeViewModel.disposeBag)
        
        activityIndicator
            .asDriver()
            .map { !$0 }
            .drive(progressBarView.rx.isHidden)
            .addDisposableTo(placeViewModel.disposeBag)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showDetails") {
            if let detailsViewController = segue.destination as? DetailsViewController {
                detailsViewController.place = sender as? Place
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController : UITableViewDelegate {
    func setupTableView() {
        //setup custom cells
        let nib = UINib(nibName: CustomCellIdentifier.placeIdentifier, bundle: nil)
        placeTableView.register(nib, forCellReuseIdentifier: CustomCellIdentifier.placeIdentifier)
        
        // setup tableview delegate
        placeTableView
            .rx
            .setDelegate(self)
            .addDisposableTo(placeViewModel.disposeBag)
        
        // table item selection
        placeTableView
            .rx
            .modelSelected(Place.self)
            .subscribe(onNext: { (place) in
                self.performSegue(withIdentifier: "showDetails", sender: place)
                self.view.endEditing(true)
            })
            .addDisposableTo(placeViewModel.disposeBag)
    }
}

extension ViewController : UIPickerViewDataSource {
    //MARK: UIPickerViewDatasource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDatasource.count
    }
    
    //MARK: UITableViewDatasource
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.tableHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if typePickerView.selectedRow(inComponent: 0) == -1 {
            return 0
        } else {
            return 44
        }
    }
}

extension ViewController : UIPickerViewDelegate {
    func setupPickerView() {
        self.typePickerView.dataSource = self
        self.typePickerView.delegate = self
        
        Type.iterateEnum(Type.self).forEach { (element) in
            pickerDatasource.append(NSLocalizedString(element.description, comment: ""))
        }
        
        typePickerView
            .rx
            .itemSelected
            .subscribe { (event) in
                switch event {
                case let .next(response):
                    let selectedType = Type(rawValue: response.0)!
                    self.tableHeaderLabel.text = NSLocalizedString(selectedType.description, comment: "")
                    self.fetchPlacesBy(type: selectedType)
                default:
                    break
                }
            }
            .addDisposableTo(placeViewModel.disposeBag)
    }

    //MARK: UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDatasource[row]
    }
}

extension ViewController : CLLocationManagerDelegate {
    func setupGeolocation() {
        // Ask for Authorization from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}
