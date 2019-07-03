//
//  MainDriverBaseViewController.swift
//  FLEX
//
//  Created by Admin on 6/17/19.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit
import FAPanels

class MainDriverBaseViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let storyboard = UIStoryboard(name: "MainDriver", bundle: nil)
        let sideMenuVC = storyboard.instantiateViewController(withIdentifier: "DriverSideMenuViewController") as! DriverSideMenuViewController
        let centerVC = storyboard.instantiateViewController(withIdentifier: "DriverMainViewController") as! DriverMainViewController
        let rootController = FAPanelController()
        _ = rootController.center(centerVC)
        _ = rootController.left(sideMenuVC)
        
        self.addChild(rootController)
        rootController.view.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
        self.containerView.addSubview(rootController.view)
        rootController.didMove(toParent: self)
    }

}
