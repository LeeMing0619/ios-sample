//
//  BaseCustomView.swift
//  FLEX
//
//  Created by Admin on 6/17/19.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import Foundation
import UIKit

class BaseCustomView: UIView {
    
    static func getView(nibName: String) -> UIView {
        let nib = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        let view = nib?[0] as? UIView
        return view!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.alpha = 0
    }
    
    func showView(_ bShow: Bool, animated: Bool = false) {
        if (animated) {
            UIView.animate(withDuration: 0.3,
                           animations: {
                            self.isHidden = false
                            self.alpha = bShow ? 1 : 0
            }) { (finished) in
                self.isHidden = !bShow
            }
        }
        else {
            self.alpha = bShow ? 1 : 0
            self.isHidden = !bShow
        }
    }
}
