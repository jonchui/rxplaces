//
//  TypePickerView.swift
//  RxPlaces
//
//  Created by Vitor Venturin Linhalis on 12/12/16.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TypePickerView: UIView {
    //outlets
    @IBOutlet var view: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    func initialize() {
        Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        self.addSubview(self.view);
    }
    
    func showHide() {
        if isHidden {
            self.isHidden = false
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
                self.frame.origin.y -= self.bounds.size.height
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.frame.origin.y += self.bounds.size.height
            }, completion: { (completed) in
                self.isHidden = true
            })
        }
    }
}
