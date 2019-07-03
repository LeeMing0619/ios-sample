//
//  Constants.swift
//  FLEX
//
//  Created by Admin on 12/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import Foundation
import UIKit
import Reachability

class Constants {
    
    static let reachability = Reachability(hostname: "www.google.com")!
    static let MAX_DISTANCE = 10.0 // 10km
    static let MILE_DIST = 1609.34
    static let gColorMain = UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0)
    static let gColorGray = UIColor.lightGray
}
