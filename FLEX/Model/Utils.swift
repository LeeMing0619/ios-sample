//
//  Utils.swift
//  FLEX
//
//  Created by Admin on 12/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    
    static func isEmailValid(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    static func isNameValid(name: String) -> Bool {
        let nameRegex = "[A-Za-z][A-Za-z\\s]*"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return nameTest.evaluate(with: name)
    }
    
    static func isStringNullOrEmpty(text: String?) -> Bool {
        return (text != nil && !((text?.isEmpty)!)) ? false : true
    }
    
    /// date formatted from unix timestamp
    static func stringFromTimestamp(timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a MM/dd/yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    static func stringElapsed(timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
        return date.getElapsedInterval()
    }
}
