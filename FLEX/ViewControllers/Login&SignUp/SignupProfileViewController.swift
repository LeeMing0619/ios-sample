//
//  SignupProfileViewController.swift
//  FLEX
//
//  Created by Admin on 12/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class SignupProfileViewController: UIViewController {

    @IBOutlet weak var profilePhotoBtn: UIButton!
    @IBOutlet weak var firstnameView: UIView!
    @IBOutlet weak var lastnameView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var firstnameTF: UITextField!
    @IBOutlet weak var lastnameTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var contactTF: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    var photohelper: PhotoHelper?
    
    var email: String?
    var password: String?
    var usertype: UserType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Init photo view helper
        photohelper = PhotoHelper(self)
        
        // UI Effect
        profilePhotoBtn.makeRound(radius: profilePhotoBtn.frame.width / 2)
        profilePhotoBtn.makeBorder(color: UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0), width: 2.0)
        firstnameView.addBottomBorderWithColor(color: UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0), width: 1.0)
        lastnameView.addBottomBorderWithColor(color: UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0), width: 1.0)
        locationView.addBottomBorderWithColor(color: UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0), width: 1.0)
        contactView.addBottomBorderWithColor(color: UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0), width: 1.0)
        
    }

    
    // MARK: - Button Actions
    @IBAction func backButton_TouchUpInside(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func profilePhotoButton_TouchUpInside(_ sender: Any) {
        photohelper?.selectImageFromPicker()
    }
    
    @IBAction func nextButton_TouchUpInside(_ sender: Any) {
        
        self.view.endEditing(true)
        
        let _firstname = getFirstName()
        let _lastname = getLastName()
        if _firstname.isEmpty {
            alertOk(title: "First Name Empty", message: "First name cannot be empty", cancelButton: "OK", cancelHandler: nil)
            return
        }
        if !Utils.isNameValid(name: _firstname) {
            alertOk(title: "First Name Invalid", message: "First name can only be normal characters", cancelButton: "OK", cancelHandler: nil)
            return
        }
        if _lastname.isEmpty {
            alertOk(title: "Last Name Empty", message: "Last name cannot be empty", cancelButton: "OK", cancelHandler: nil)
            return
        }
        if !Utils.isNameValid(name: _lastname) {
            alertOk(title: "Last Name Invalid", message: "Last name can only be normal characters", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        //show loading view
        showLoadingView()
        
        FirebaseManager.mAuth.createUser(withEmail: email!, password: password!, completion: { (result, error) in
            if let error = error {
                //hide loading view
                self.showLoadingView(show: false)
                
                self.alertOk(title: "Sign up Failed", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                return
            }
            let userNew = User(withId: (result?.user.uid)!)
            userNew.email = self.email!
            User.currentUser = userNew
            self.uploadImageAndSetupUserInfo()
        })
        
    }
    
    // MARK: - processing
    func uploadImageAndSetupUserInfo() {
        // upload photo
        let user = User.currentUser!
        if let image = self.profilePhotoBtn.image(for: .normal) {
            showLoadingView()
            let path = "users/" + user.id + ".png"
            let resized = image.resized(toWidth: 200, toHeight: 200)
            FirebaseManager.uploadImageTo(path: path, image: resized, completionHandler: { (downloadURL, error) in
                if let error = error {
                    self.showLoadingView(show: false)
                    self.alertOk(title: "Failed Uploading Photo", message: error.localizedDescription, cancelButton: "OK", cancelHandler: nil)
                    return
                }
                if let url = downloadURL {
                    User.currentUser?.photoUrl = url
                    // save image to cache
                    SDWebImageManager.shared().saveImage(toCache: resized, for: URL(string: url))
                }
                self.saveUserInfo()
            })
        }
        else {
            self.saveUserInfo()
        }
    }
    
    func saveUserInfo() {
        let user = User.currentUser!
        // save info
        user.firstName = getFirstName()
        user.lastName = getLastName()
        user.location = locationTF.text!
        user.phone = contactTF.text!
        user.saveToDatabase()
        
        // save user type
        user.type = self.usertype!
        user.saveToDatabase(withField: User.FIELD_TYPE, value: self.usertype!.rawValue) { (error, ref) in
        }
        
        // hide loading
        showLoadingView(show: false)
        // go to signup choose page
        self.performSegue(withIdentifier: "goTermFromSignUpSegue", sender: nil)
    }
    
    // MARK: - get first/last name
    func getFirstName() -> String {
        let str = firstnameTF.text!
        return str.trimmingCharacters(in: .whitespaces)
    }
    
    func getLastName() -> String {
        let str = lastnameTF.text!
        return str.trimmingCharacters(in: .whitespaces)
    }
    
    // MARK: - Touch began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SignupProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstnameTF {
            lastnameTF.becomeFirstResponder()
        } else if textField == lastnameTF {
            locationTF.becomeFirstResponder()
        } else if textField == locationTF {
            contactTF.becomeFirstResponder()
        } else if textField == contactTF {
            textField.resignFirstResponder()
        }
        return true
    }
}

extension SignupProfileViewController: updateImageDelegate {
    func onUpdateImage(_ image: UIImage, tag: Int) {
        profilePhotoBtn.setImage(image, for: .normal)
    }
    func getViewController() -> UIViewController {
        return self
    }
}
