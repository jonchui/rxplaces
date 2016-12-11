//
//  ComponentSingleton.swift
//
//  Created by Vitor Venturin Linhalis on 23/09/16.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import UIKit
import SDWebImage

enum PlaceholderOrientation:Int{
    case horizontal = 0
    case vertical = 1
}

class ImageCacheSingleton {
    //MARK: Shared Instance
    static let shared = ImageCacheSingleton()
    
    //MARK: Local Variable
    fileprivate let cache:SDImageCache!
    fileprivate let placeholderH:UIImage!
    fileprivate let placeholderV:UIImage!
    
    //MARK: Init
    fileprivate init() {
        // placeholders
        placeholderH = UIImage(named: "PlaceholderH")
        placeholderV = UIImage(named: "PlaceholderV")
        
        // cache de imagens
        cache = SDImageCache(namespace: "RxPlacesImageCache")
    }
    
    func imageCache() -> SDImageCache {
        return cache
    }
    
    func placeholder(_ orientation: PlaceholderOrientation) -> UIImage {
        switch orientation {
        case .horizontal:
            return placeholderH
        case .vertical:
            return placeholderV
        }
    }
}
