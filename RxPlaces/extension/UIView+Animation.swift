//
//  UISearchBar+Animation.swift
//  RxPlaces
//
//  Created by Vitor Venturin Linhalis on 17/12/16.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func showHide() {
        if isHidden {
            self.isHidden = false
            self.alpha = 0.0
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
                self.alpha = 1.0
            }, completion: nil)
        } else {
            self.alpha = 1.0
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.alpha = 0.0
            }, completion: { (completed) in
                self.isHidden = true
            })
        }
    }
}
