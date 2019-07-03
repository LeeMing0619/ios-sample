//
//  TermViewController.swift
//  FLEX
//
//  Created by Admin on 13/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit

class TermViewController: UIViewController {

    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var checkBtn: UIButton!
    
    var ischecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        acceptBtn.makeEnable(enable: false)
    }
    
    // MARK: - Button Action
    @IBAction func acceptButton_TouchUpInside(_ sender: Any) {
        let userCurrent = User.currentUser!
        if userCurrent.type == UserType.driver {
            //go to application page for driver
            //SignupApplicationViewController
            self.performSegue(withIdentifier: "goSignupApplicationFromTermSegue", sender: self)
        }
        else if userCurrent.type == UserType.customer {
            //go to home page for customer
            //MainUserViewController
            let storyboard = UIStoryboard(name: "MainUser", bundle: nil)
            let mainuserVC = storyboard.instantiateViewController(withIdentifier: "MainUserBaseViewController") as! MainUserBaseViewController
            UIApplication.shared.keyWindow?.rootViewController = mainuserVC
        }
    }
    
    @IBAction func checkButton_TouchUpInside(_ sender: Any) {
        if ischecked {
            ischecked = false
            checkBtn.setImage(UIImage(named: "uncheck"), for: .normal)
            acceptBtn.makeEnable(enable: false)
        } else {
            ischecked = true
            checkBtn.setImage(UIImage(named: "check"), for: .normal)
            acceptBtn.makeEnable(enable: true)
        }
    }
    
    
}
