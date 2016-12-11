//
//  Reactive+ProgressBarView.swift
//
//  Created by Vitor Venturin Linhalis on 29/11/16.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
    
extension Reactive where Base: UIView {
    /// Bindable sink for `not hidden` property.
    public var isNotHidden: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { view, hidden in
            view.isHidden = !hidden
        }
    }
}
