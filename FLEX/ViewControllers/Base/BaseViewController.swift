//
//  BaseViewController.swift
//  FLEX
//
//  Created by Admin on 16/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit
import SVProgressHUD

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    static func getMainViewController() -> UIViewController? {
        let userCurrent = User.currentUser!
        
        var vc: UIViewController?
        
        // go to home page with new navigation
        if userCurrent.type == UserType.driver {
//            vc = MainDriverViewController(nibName: "MainDriverViewController", bundle: nil)
        }
        else if userCurrent.type == UserType.customer {
//            vc = MainUserViewController(nibName: "MainUserViewController", bundle: nil)
        }
        else if userCurrent.type == UserType.notdetermined {
//            vc = SignupChooseViewController(nibName: "SignupChooseViewController", bundle: nil)
        }
        
        return vc
    }
    
    /// go to main page according to user type
    func goToMain() {
        if let vc = BaseViewController.getMainViewController() {
            // remove previous pages
//            self.navigationController?.setViewControllers([vc], animated: true)
        }
    }

}
