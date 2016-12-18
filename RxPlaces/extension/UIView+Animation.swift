//
//  UISearchBar+Animation.swift
//  RxPlaces
//
//  Created by Vitor Venturin Linhalis on 17/12/16.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import Foundation
import UIKit

enum Position {
    case header, footer
}

extension UIView {
    func showHide(from position:Position) {
        if isHidden {
            self.isHidden = false
            self.alpha = 0.0
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
                if position == .header {
                    self.frame.origin.y += self.bounds.size.height
                } else {
                    self.frame.origin.y -= self.bounds.size.height
                }
                self.alpha = 1.0
            }, completion: nil)
        } else {
            self.alpha = 1.0
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                if position == .header {
                    self.frame.origin.y -= self.bounds.size.height
                } else {
                    self.frame.origin.y += self.bounds.size.height
                }
                self.alpha = 0.0
            }, completion: { (completed) in
                self.isHidden = true
            })
        }
    }
}
