//
//  PhotoHelper.swift
//  FLEX
//
//  Created by Admin on 12/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol updateImageDelegate: HelperDelegate {
    func onUpdateImage(_ image: UIImage, tag: Int)
}

class PhotoHelper: NSObject {
    var viewController: UIViewController
    var delegate: updateImageDelegate
    
    init(_ delegate: updateImageDelegate) {
        viewController = delegate.getViewController()
        self.delegate = delegate
    }
    
    func selectImageFromPicker(_ tag: Int = 0) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take a new photo", style: .default, handler: { (action) in
            self.takePhoto(tag)
        }))
        alert.addAction(UIAlertAction(title: "Select from gallery", style: .default, handler: { (action) in
            self.loadFromGallery(tag)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func takePhoto(_ tag: Int = 0) {
        let cameraMediaType = AVMediaType.video
        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        switch cameraAuthStatus {
        case .denied: fallthrough
        case .restricted:
            viewController.alert(title: "Camera", message: "You are restricted using the camera. Go to settings to enable it", okButton: "Go to Settings", cancelButton: "Cancel", okHandler: { (_) in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                }
            }, cancelHandler: nil)
            break
        case .authorized:
            doTakePhoto(tag)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: cameraMediaType, completionHandler: { granted in
                if granted {
                    self.doTakePhoto(tag)
                }
            })
        default:
            break
        }
    }
    
    func doTakePhoto(_ tag: Int = 0) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            viewController.alert(title: "Camera", message: "You are restricted using the camera. Go to settings to enable it", okButton: "Go to Settings", cancelButton: "Cancel", okHandler: { (_) in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                }
            }, cancelHandler: nil)
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .camera
        picker.view.tag = tag
        
        viewController.present(picker, animated: true, completion: nil)
    }
    
    func loadFromGallery(_ tag: Int = 0) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            doLoadFromGallery(tag)
            break
        case .denied, .restricted:
            viewController.alert(title: "Camera", message: "You are restricted using the camera. Go to settings to enable it", okButton: "Go to Settings", cancelButton: "Cancel", okHandler: { (_) in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                }
            }, cancelHandler: nil)
            return
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ status in
                switch status {
                case .authorized:
                    self.doLoadFromGallery(tag)
                    break
                case .denied, .restricted:
                    break
                case .notDetermined:
                    break
                default:
                    break
                }
            })
        default:
            break
        }
    }
    
    func doLoadFromGallery(_ tag: Int = 0) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.view.tag = tag
        
        viewController.present(picker, animated: true, completion: nil)
    }
}

extension PhotoHelper: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let chosenImg = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            let nTag = picker.view.tag
            delegate.onUpdateImage(chosenImg, tag: nTag)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
