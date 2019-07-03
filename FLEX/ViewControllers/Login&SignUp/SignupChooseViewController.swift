//
//  SignupChooseViewController.swift
//  FLEX
//
//  Created by Admin on 11/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit

class SignupChooseViewController: UIViewController {

    @IBOutlet weak var riderView: UIView!
    @IBOutlet weak var driverView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI Effect
        riderView.makeRound(radius: riderView.frame.width / 2)
        driverView.makeRound(radius: riderView.frame.width / 2)
    }
    

    // MARK: - Button Actions
    @IBAction func backButton_TouchUpInside(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func riderButton_TouchUpInside(_ sender: Any) {
        gotoTerm(type: UserType.customer)
    }
    
    @IBAction func driverButton_TouchUpInside(_ sender: Any) {
        gotoTerm(type: UserType.driver)
    }
    
    // MARK: - Go To Term View
    func gotoTerm(type: UserType) {
        //Save user type
        let userCurrent = User.currentUser!
        userCurrent.type = type
        userCurrent.saveToDatabase(withField: User.FIELD_TYPE, value: type.rawValue) { (error, ref) in
            if userCurrent.type == UserType.customer {
                //payment integration
            }
        }
        
        // go to term page
        self.performSegue(withIdentifier: "goTermFromSignUpSegue", sender: nil)
    }
}
