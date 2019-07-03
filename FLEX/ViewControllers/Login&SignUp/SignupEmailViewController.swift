//
//  SignupEmailViewController.swift
//  FLEX
//
//  Created by Admin on 11/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit


class SignupEmailViewController: UIViewController {
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var retypPasswordView: UIView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var retypepasswordTF: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var chooseDriverImgV: UIImageView!
    @IBOutlet weak var chooseRiderImgV: UIImageView!
    @IBOutlet weak var choosePTPImgV: UIImageView!
    
    var user_type: UserType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Effect
        emailView.addBottomBorderWithColor(color: UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0), width: 1.0)
        passwordView.addBottomBorderWithColor(color: UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0), width: 1.0)
        retypPasswordView.addBottomBorderWithColor(color: UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0), width: 1.0)
        
        //init type
        user_type = UserType.driver
    }
    

    // MARK: - Button Actions
    @IBAction func backButton_TouchUpInside(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func chooseDriverButton_TouchUpInside(_ sender: Any) {
        chooseDriverImgV.image = UIImage(named: "combocheck")
        chooseRiderImgV.image = UIImage(named: "combouncheck")
        choosePTPImgV.image = UIImage(named: "combouncheck")
        user_type = UserType.driver
    }
    
    @IBAction func chooseRiderButton_TouchUpInside(_ sender: Any) {
        chooseDriverImgV.image = UIImage(named: "combouncheck")
        chooseRiderImgV.image = UIImage(named: "combocheck")
        choosePTPImgV.image = UIImage(named: "combouncheck")
        user_type = UserType.customer
    }
    
    @IBAction func choosePTPButton_TouchUpInside(_ sender: Any) {
        chooseDriverImgV.image = UIImage(named: "combouncheck")
        chooseRiderImgV.image = UIImage(named: "combouncheck")
        choosePTPImgV.image = UIImage(named: "combocheck")
        
        user_type = UserType.peertopeer
    }
    
    @IBAction func nextButton_ToucheUpInside(_ sender: Any) {
        
        self.view.endEditing(true)
        
        var email = emailTF.text!
        var password = passwordTF.text!
        var passwordConfirm = retypepasswordTF.text!
        
        email = email.trimmingCharacters(in: .whitespaces)
        password = password.trimmingCharacters(in: .whitespaces)
        passwordConfirm = passwordConfirm.trimmingCharacters(in: .whitespaces)
        
        //check input validity
        if email == "" {
            alertOk(title: "Email Empty", message: "Please enter your email", cancelButton: "OK", cancelHandler: nil)
            return
        }
        if !email.contains("@") || !Utils.isEmailValid(email: email) {
            alertOk(title: "Email Invalid", message: "Please enter valid email address", cancelButton: "OK", cancelHandler: nil)
            return
        }
        if password == "" {
            alertOk(title: "Password Empty", message: "Please enter your password", cancelButton: "OK", cancelHandler: nil)
            return
        }
        if password != passwordConfirm {
            alertOk(title: "Password Invalid", message: "Confirm password does not match", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        //check connection
        if Constants.reachability.connection == .none {
            showConnectionError()
            return
        }
        
        //show loading view
        showLoadingView()
        
        // check if email has been used
        let database = FirebaseManager.ref()
        let query = database.child(User.TABLE_NAME)
        query.queryOrdered(byChild: User.FIELD_EMAIL)
            .queryEqual(toValue: "\(email)")
            .observeSingleEvent(of: .value, with: { snapshot in
            //hide loading view
            self.showLoadingView(show: false)
            
            if snapshot.exists() {
                self.alertOk(title: "Email is already in use", message: "Please enter other email address", cancelButton: "OK", cancelHandler: nil)
                return
            }
            
            // go to signup profile page
            self.performSegue(withIdentifier: "goSignupProfileSegue", sender: nil)
        })
    }
    
    // MARK: - Prepare Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goSignupProfileSegue" {
            let vc = segue.destination as! SignupProfileViewController
            vc.email = emailTF.text!.trimmingCharacters(in: .whitespaces)
            vc.password = passwordTF.text!.trimmingCharacters(in: .whitespaces)
            vc.usertype = self.user_type
        }
    }
    
    // MARK: - Touch Began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SignupEmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTF {
            passwordTF.becomeFirstResponder()
        } else  if textField == passwordTF {
            retypepasswordTF.becomeFirstResponder()
        } else if textField == retypepasswordTF {
            textField.resignFirstResponder()
        }
        return true
    }
}
