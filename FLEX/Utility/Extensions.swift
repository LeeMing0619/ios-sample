//
//  Extensions.swift
//  FLEX
//
//  Created by Admin on 12/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

extension UIViewController {
    func alert(title: String, message: String, okButton: String, cancelButton: String, okHandler: ((UIAlertAction) -> ())?, cancelHandler: ((UIAlertAction) -> ())?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButton, style: .default, handler: okHandler)
        let cancelAction = UIAlertAction(title: cancelButton, style: .cancel, handler: cancelHandler)
        alertController.view.tintColor = .darkGray
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func alertOk(title: String, message: String, cancelButton: String, cancelHandler: ((UIAlertAction) -> ())?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelButton, style: .default, handler: cancelHandler)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = .darkGray
        present(alertController, animated: true, completion: nil)
    }
    
    //show internet connection error
    func showConnectionError() {
        alertOk(title: "No internet connection", message: "Please connect to the internet and try again", cancelButton: "OK", cancelHandler: nil)
    }
    
    //show loading view
    func showLoadingView(show: Bool = true, desc: String? = nil) {
        if SVProgressHUD.isVisible() && show {
            // loading view is already shown
            return
        }
        
        SVProgressHUD.dismiss()
        if show {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.setDefaultMaskType(.gradient)
            SVProgressHUD.show(withStatus: desc)
        }
    }
    
}

extension UIView {
    //Make Round corner
    func makeRound(radius: CGFloat) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = radius
    }
    
    //Make Border
    func makeBorder(color: UIColor, width: CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    //Add Bottom border
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = UIView(frame: CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: width))
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        self.addSubview(border)
    }
}

extension Date {
    
    func getElapsedInterval() -> String {
        let interval = Calendar.current.dateComponents([.year, .month, .day], from: self, to: Date())
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year" :
                "\(year)" + " " + "years"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month" :
                "\(month)" + " " + "months"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day" :
                "\(day)" + " " + "days"
        } else {
            return "a moment ago"
        }
        
    }
}

extension UIImage {
    func resized(toWidth width: CGFloat, toHeight height: CGFloat) -> UIImage {
        let canvasSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

extension UIButton {
    func makeEnable(enable: Bool) {
        self.isEnabled = enable
        self.alpha = enable ? 1 : 0.5
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}


extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

