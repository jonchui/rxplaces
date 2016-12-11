//
//  UIViewController+Alert.swift
//
//  Created by Vitor Venturin Linhalis on 29/11/16.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func alertController(title : String?, message : String?, preferredStyle : UIAlertControllerStyle, actions: [UIAlertAction]) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        return alertController
        
    }
}
