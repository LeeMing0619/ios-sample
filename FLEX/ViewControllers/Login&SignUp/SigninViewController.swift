//
//  SigninViewController.swift
//  FLEX
//
//  Created by Admin on 11/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit
import Firebase


class SigninViewController: UIViewController {
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var checkBtn: UIButton!
    
    var ischecked = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Effect
        emailView.addBottomBorderWithColor(color: UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0), width: 1.0)
        passwordView.addBottomBorderWithColor(color: UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0), width: 1.0)
        
    }
    
    @IBAction func checkButton_TouchUpInside(_ sender: Any) {
        if ischecked {
            ischecked = false
            checkBtn.setImage(UIImage(named: "uncheck"), for: .normal)
        } else {
            ischecked = true
            checkBtn.setImage(UIImage(named: "check"), for: .normal)
        }
    }
    
    // MARK: - Button Actions
    @IBAction func loginButton_TouchUpInside(_ sender: Any) {
        self.view.endEditing(true)
        
        var email = emailTF.text!
        var password = passwordTF.text!
        
        //trim white spaces
        email = email.trimmingCharacters(in: .whitespaces)
        password = password.trimmingCharacters(in: .whitespaces)
        
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
        
        //check connection
        if Constants.reachability.connection == .none {
            showConnectionError()
            return
        }
        
        //show loading view
        showLoadingView()
        
        //auth
        FirebaseManager.mAuth.signIn(withEmail: email, password: password, completion: { (result, error) in
            if let error = error {
                self.showLoadingView(show: false)
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    if errorCode == AuthErrorCode.accountExistsWithDifferentCredential {
                        self.alertForOtherCredential(email: email)
                    } else {
                        self.alertOk(title: "Login Failed", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                    }
                }
            } else {
                self.fetchUserInfo(userInfo: result?.user, firstName: nil, lastName: nil, photoURL: nil, onFailed: {
                    FirebaseManager.signOut()
                    self.showLoadingView(show: false)
                })
            }
        })
    }
    
    @IBAction func forgotButton_TouchUpInside(_ sender: Any) {
    }
    
    @IBAction func facebookButton_TouchUpInside(_ sender: Any) {
    }
    
    @IBAction func googleButton_TouchUpInside(_ sender: Any) {
    }
    
    @IBAction func signupButton_TouchUpInside(_ sender: Any) {
        self.performSegue(withIdentifier: "goSignUpEmailSegue", sender: nil)
    }
    
    // MARK: - TouchBegan
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Fetch user info with basic user auth
    func fetchUserInfo(userInfo: Firebase.User? = nil, firstName: String?, lastName: String?, photoURL: String?, onFailed: @escaping(() -> ()) = {}, onCompleted: @escaping(() -> ()) = {}) {
        guard let userId = FirebaseManager.mAuth.currentUser?.uid else {
            onFailed()
            return
        }
        User.readFromDatabase(withId: userId, completion: { (u) in
            User.currentUser = u
            if User.currentUser == nil {
                if User.currentUser == nil {
                    let newUser = User(withId: userId)
                    newUser.email = (userInfo?.email)!
                    newUser.firstName = firstName!
                    newUser.lastName = lastName!
                    newUser.photoUrl = photoURL
                    User.currentUser = newUser
                }
                self.performSegue(withIdentifier: "goSignupProfileFromSigninSegue", sender: nil)
            } else {
                //Go To main
                let userCurrent = User.currentUser!
                if userCurrent.type == UserType.driver {
                    //go to home page for driver
                    //MainDriverViewController
                    let storyboard = UIStoryboard(name: "MainDriver", bundle: nil)
                    let maindriverVC = storyboard.instantiateViewController(withIdentifier: "MainDriverBaseViewController") as! MainDriverBaseViewController
                    //                            let nav = storyboard.instantiateInitialViewController() as! UINavigationController
                    //                            nav.viewControllers = [onboardingVC]
                    UIApplication.shared.keyWindow?.rootViewController = maindriverVC
                }
                else if userCurrent.type == UserType.customer {
                    //go to home page for customer
                    //MainUserViewController
                    let storyboard = UIStoryboard(name: "MainUser", bundle: nil)
                    let mainuserVC = storyboard.instantiateViewController(withIdentifier: "MainUserBaseViewController") as! MainUserBaseViewController
                    //                            let nav = storyboard.instantiateInitialViewController() as! UINavigationController
                    //                            nav.viewControllers = [onboardingVC]
                    UIApplication.shared.keyWindow?.rootViewController = mainuserVC
                }
            }
            onCompleted()
        })
    }
    
    func alertForOtherCredential(email: String) {
        FirebaseManager.mAuth.fetchProviders(forEmail: email, completion: { (providers, error) in
            if error == nil {
                if providers?[0] == "google.com" {
                    DispatchQueue.main.async {
                        self.alertOk(title: "Login", message: "You already signed in with Google. Please sign in with Google.", cancelButton: "OK", cancelHandler: nil)
                    }
                } else if providers?[0] == "facebook.com" {
                    DispatchQueue.main.async {
                        self.alertOk(title: "Login", message: "You already signed in with Facebook. Please sign in with Facebook.", cancelButton: "OK", cancelHandler: nil)
                    }
                }else {
                    DispatchQueue.main.async {
                        self.alertOk(title: "Login", message: "You already signed in with email. Please use email to log in.", cancelButton: "OK", cancelHandler: nil)
                    }
                }
            } else {}
        })
    }
}

extension SigninViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTF {
            passwordTF.becomeFirstResponder()
        } else if textField == passwordTF {
            textField.resignFirstResponder()
        }
        return true
    }
}

