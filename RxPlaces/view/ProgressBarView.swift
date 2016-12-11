//
//  ProgressBarView.swift
//
//  Created by Vitor Venturin Linhalis on 29/11/16.
//  Copyright © 2016 Vitor Venturin Linhalis. All rights reserved.
//

import UIKit

class ProgressBarView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.alpha = 0.1
        }, completion: nil)
    }

}
