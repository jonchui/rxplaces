//
//  DetailsViewController.swift
//
//  Created by Vitor Venturin Linhalis on 27/11/16.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import UIKit
import Moya
import RxSwift

class DetailsViewController: UIViewController {
    //outlets
    @IBOutlet weak var placeImageView:UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var vicinityLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //vars
    var place:Place?
    var disposeBag:DisposeBag! = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundImageView()
        showDetails()
    }
    
    func setupBackgroundImageView() {
        backgroundImageView.clipsToBounds = true
        self.makeBlurImage(backgroundImageView)
    }

    func showDetails() {
        let activityIndicator = ActivityIndicator()
        let reachable = try! DefaultReachabilityService.init()
        
        activityIndicator.asObservable()
            .bindTo(self.activityIndicator.rx.isAnimating)
            .addDisposableTo(self.disposeBag)
        
        nameLabel.text = place?.name
        vicinityLabel.text = place?.vicinity
        
        self.placeImageView?.image = UIImage(named: "PlaceholderH")
        
        let provider:RxMoyaProvider<GooglePlaces> = RxMoyaProvider<GooglePlaces>()
        
        if let firstPhoto = place?.photos?.first {
            
            if let cachedAvatarImage = ImageCacheSingleton.shared.imageCache().imageFromDiskCache(forKey: firstPhoto.reference) {
                self.placeImageView?.image = cachedAvatarImage
                self.backgroundImageView?.image = cachedAvatarImage
            } else {
                
                provider.request(.getPhoto(photo: firstPhoto, key: GooglePlacesAPI.token))
                    .asObservable()
                    .retryOnBecomesReachable(Response(statusCode: 404, data: Data()), reachabilityService: reachable)
                    .trackActivity(activityIndicator)
                    .mapImage()
                    .subscribe { event in
                        switch event {
                        case let .next(response):
                            self.placeImageView?.image = response
                            self.backgroundImageView?.image = response
                            
                            ImageCacheSingleton.shared.imageCache().store(response, forKey: firstPhoto.reference)
                            
                            
                        case let .error(error):
                            print(error)
                        default:
                            break
                        }
                    }
                    .addDisposableTo(disposeBag)
            }
        }
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        let shareItems:Array! = []
        let avc:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities:[])
        
        let excludeActivities:Array = [
            UIActivityType.airDrop,
            UIActivityType.copyToPasteboard,
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo]
        
        avc.excludedActivityTypes = excludeActivities
        
        avc.popoverPresentationController?.sourceView = self.view
        avc.popoverPresentationController?.barButtonItem = sender
        
        self.present(avc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func makeBlurImage(_ targetImageView:UIImageView?){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = targetImageView!.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        targetImageView?.addSubview(blurEffectView)
    }

}
