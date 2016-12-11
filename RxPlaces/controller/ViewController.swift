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

protocol ViewControllerProtocol : class {
    func setupTableView()
    func setupRx()
}

struct CustomCellIdentifier {
    static let placeIdentifier = "PlaceTableCell"
}

class ViewController: UIViewController, UITableViewDelegate, ViewControllerProtocol {
    //outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var placeTableView: UITableView!
    @IBOutlet weak var progressBarView: ProgressBarView!
    
    //vars
    fileprivate let placeViewModel = PlaceViewModel()
    fileprivate let activityIndicator = ActivityIndicator()
    fileprivate var pagetoken:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupRx()
    }
    
    func setupTableView() {
        //setup custom cells
        let nib = UINib(nibName: CustomCellIdentifier.placeIdentifier, bundle: nil)
        placeTableView.register(nib, forCellReuseIdentifier: CustomCellIdentifier.placeIdentifier)
        
        // setup tableview delegate
        placeTableView
            .rx.setDelegate(self)
            .addDisposableTo(self.placeViewModel.disposeBag)
    }
    
    private func didSearch(type: String!) {
        placeViewModel.loadPlaces("34.052235,-118.243683", type: type, radius: 5000)
            .retry(3)
            .observeOn(MainScheduler.instance)
            .trackActivity(activityIndicator)
            .subscribe { event in
                switch event {
                case let .next(response):
                    if let places = response.places {
                        self.placeViewModel.places.value = places
                    }
                    self.pagetoken = response.nextPageToken
                case let .error(error):
                    print(error)
                case .completed():
                    print("completed")
                    self.progressBarView.isHidden = true
                }
            }
            .addDisposableTo(self.placeViewModel.disposeBag)
    }
    
    func setupRx() {
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
        .addDisposableTo(self.placeViewModel.disposeBag)
        
        activityIndicator
            .asObservable()
            .bindTo(progressBarView.rx.isNotHidden)
            .addDisposableTo(self.placeViewModel.disposeBag)
        
        // observable table view 👍
        placeViewModel.places
            .asObservable()
            .bindTo(self.placeTableView.rx.items(cellIdentifier: CustomCellIdentifier.placeIdentifier, cellType: PlaceTableCell.self)){ (row, element, cell) in
                cell.place = element
                cell.nameLabel?.text = element.name
                cell.iconImageView.sd_setImage(with: URL(string: element.iconURL!), placeholderImage: UIImage(named: "PlaceholderH"))
                cell.vicinityLabel.text = element.vicinity
                if let rating = element.rating {
                    cell.ratingLabel.text = String(format: "%.1f", rating)
                }
            }
            .addDisposableTo(self.placeViewModel.disposeBag)
        
        // item selected
        placeTableView.rx.itemSelected.subscribe { indexPath in
            self.performSegue(withIdentifier: "showDetails", sender: self.placeTableView.indexPathForSelectedRow)
        }
        .addDisposableTo(self.placeViewModel.disposeBag)
        
        // infinite scroll
        placeTableView.rx.didEndDisplayingCell
            .subscribe { 🤔 in
                if self.progressBarView.isHidden && !self.placeViewModel.places.value.isEmpty {
                    if let token = self.pagetoken {
                        self.placeViewModel.nextPage(token)
                            .retry(3)
                            .observeOn(MainScheduler.instance)
                            .trackActivity(self.activityIndicator)
                            .subscribe { event in
                                switch event {
                                case let .next(response):
                                    if let places = response.places {
                                        self.placeViewModel.places.value.append(contentsOf: places)
                                    }
                                    self.pagetoken = response.nextPageToken
                                case let .error(error):
                                    print(error)
                                case .completed():
                                    print("completed")
                                    self.progressBarView.isHidden = true
                                }
                            }
                        .addDisposableTo(self.placeViewModel.disposeBag)
                    }
                }
            }
            .addDisposableTo(self.placeViewModel.disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showDetails") {
            if let detailsViewController = segue.destination as? DetailsViewController {
                let cell = placeTableView.cellForRow(at: sender as! IndexPath) as! PlaceTableCell
                detailsViewController.place = cell.place
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
