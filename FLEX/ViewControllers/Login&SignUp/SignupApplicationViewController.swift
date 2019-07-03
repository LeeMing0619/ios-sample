//
//  SignupApplicationViewController.swift
//  FLEX
//
//  Created by Admin on 11/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit

class SignupApplicationViewController: BaseViewController {

    @IBOutlet weak var mViewLicense: UIView!
    @IBOutlet weak var mViewInsurance: UIView!
    @IBOutlet weak var mViewRegistration: UIView!
    
    @IBOutlet weak var mImgViewLicense: UIImageView!
    @IBOutlet weak var mImgViewInsurance: UIImageView!
    @IBOutlet weak var mImgViewRegistration: UIImageView!
    
    @IBOutlet weak var mButLicense: UIButton!
    @IBOutlet weak var mButInsurance: UIButton!
    @IBOutlet weak var mButRegistration: UIButton!
    @IBOutlet weak var mButSubmit: UIButton!
    
    @IBOutlet weak var mButDeclare: UIButton!
    @IBOutlet weak var mImgViewCheck: UIImageView!
    
    var mButSelected: UIButton?
    
    var photoHelper: PhotoHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // init photo view helper
        photoHelper = PhotoHelper(self)
        
        // check box
        mImgViewCheck.image = UIImage(named: "uncheck")
        mButDeclare.isSelected = false
        
        mButSubmit.makeEnable(enable: false)
    }
    
    
    // MARK: - Button Actions
    
    @IBAction func backButton_TouchUpInside(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func licenseButton_TouchUpInside(_ sender: Any) {
        mButSelected = sender as? UIButton
        photoHelper?.selectImageFromPicker()
    }
    
    @IBAction func insuranceButton_TouchUpInside(_ sender: Any) {
        mButSelected = sender as? UIButton
        photoHelper?.selectImageFromPicker()
    }
    
    @IBAction func registrationButton_TouchUpInside(_ sender: Any) {
        mButSelected = sender as? UIButton
        photoHelper?.selectImageFromPicker()
    }
    
    @IBAction func declareButton_TouchUpInside(_ sender: Any) {
        if mButDeclare.isSelected == false {
            mImgViewCheck.image = UIImage(named: "check")
            mButDeclare.isSelected = true
            mButSubmit.makeEnable(enable: true)
        } else {
            mImgViewCheck.image = UIImage(named: "uncheck")
            mButDeclare.isSelected = false
            mButSubmit.makeEnable(enable: false)
        }
    }
    
    @IBAction func submitButton_TouchUpInside(_ sender: Any) {
        //Go to Payment system
        //////////
        //go to home page for driver
        //MainDriverViewController
        let storyboard = UIStoryboard(name: "MainDriver", bundle: nil)
        let maindriverVC = storyboard.instantiateViewController(withIdentifier: "MainDriverBaseViewController") as! MainDriverBaseViewController
        UIApplication.shared.keyWindow?.rootViewController = maindriverVC
    }
}

extension SignupApplicationViewController: updateImageDelegate {
    func onUpdateImage(_ image: UIImage, tag: Int) {
        if mButSelected == mButLicense {
            mImgViewLicense.image = image
        }
        else if mButSelected == mButInsurance {
            mImgViewInsurance.image = image
        }
        else if mButSelected == mButRegistration {
            mImgViewRegistration.image = image
        }
    }
    
    func getViewController() -> UIViewController {
        return self
    }
    
    
}
