//
//  MainUserBaseViewController.swift
//  FLEX
//
//  Created by Admin on 13/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit
import FAPanels

class MainUserBaseViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "MainUser", bundle: nil)
        let sideMenuVC = storyboard.instantiateViewController(withIdentifier: "UserSideMenuViewController") as! UserSideMenuViewController
        let centerVC = storyboard.instantiateViewController(withIdentifier: "UserMainViewController") as! UserMainViewController
        let rootController = FAPanelController()
        _ = rootController.center(centerVC)
        _ = rootController.left(sideMenuVC)
        
        self.addChild(rootController)
        rootController.view.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
        self.containerView.addSubview(rootController.view)
        rootController.didMove(toParent: self)
    }
}
