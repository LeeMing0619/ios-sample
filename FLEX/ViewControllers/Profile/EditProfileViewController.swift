//
//  EditProfileViewController.swift
//  FLEX
//
//  Created by Admin on 20/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class EditProfileViewController: BaseViewController {
    
    @IBOutlet weak var profilePhotoBtn: UIButton!
    @IBOutlet weak var firstnameView: UIView!
    @IBOutlet weak var lastnameView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var firstnameTF: UITextField!
    @IBOutlet weak var lastnameTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var contactTF: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    
    var photohelper: PhotoHelper?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //bhavya -start
        let origImage = UIImage(named: "icon_menu")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        menuBtn.setImage(tintedImage, for: .normal)
        menuBtn.tintColor = .white
        //bhavya -end
        
        // Init photo view helper
        photohelper = PhotoHelper(self)
        
        // UI Effect
        profilePhotoBtn.makeRound(radius: profilePhotoBtn.frame.width / 2)
        profilePhotoBtn.makeBorder(color: UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0), width: 2.0)
        
        firstnameView.addBottomBorderWithColor(color: UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0), width: 1.0)
        lastnameView.addBottomBorderWithColor(color: UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0), width: 1.0)
        locationView.addBottomBorderWithColor(color: UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0), width: 1.0)
        contactView.addBottomBorderWithColor(color: UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0), width: 1.0)
        

        // fill info
        if let user = User.currentUser {
            if let photoUrl = user.photoUrl {
                profilePhotoBtn.sd_setImage(with: URL(string: photoUrl),
                                            for: .normal,
                                            placeholderImage: UIImage(named: "UserDefault"),
                                            options: .progressiveDownload,
                                            completed: nil)
            }
            
            firstnameTF.text = user.firstName
            lastnameTF.text = user.lastName
            locationTF.text = user.location
            contactTF.text = user.phone
        }
        
    }
    
    // MARK: - Button Actions
    @IBAction func profilePhotoButton_TouchUpInside(_ sender: Any) {
        photohelper?.selectImageFromPicker()
    }
    
    @IBAction func menuButton_TouchUpInside(_ sender: Any) {
        panel?.openLeft(animated: true)
    }
    
    @IBAction func saveButton_TouchUpInside(_ sender: Any) {
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
        
        // Save Info
        uploadImageAndSetupUserInfo()
        
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
        let user = User.currentUser
        // save info
        user?.firstName = getFirstName()
        user?.lastName = getLastName()
        user?.location = locationTF.text!
        user?.phone = contactTF.text!
        user?.saveToDatabase()
        // hide loading
        showLoadingView(show: false)
        // go to signup choose page
        
        //bhavya -start
        // self.performSegue(withIdentifier: "goSignupChooseSegue", sender: nil)
        alertOk(title: "Edit Profile", message: "Profile data edited successfully", cancelButton: "OK", cancelHandler: nil)
        return
        //bhavya -end
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
}

extension EditProfileViewController: UITextFieldDelegate {
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

extension EditProfileViewController: updateImageDelegate {
    func onUpdateImage(_ image: UIImage, tag: Int) {
        profilePhotoBtn.setImage(image, for: .normal)
    }
    func getViewController() -> UIViewController {
        return self
    }
}


