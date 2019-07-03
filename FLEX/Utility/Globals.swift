//
//  Globals.swift
//  FLEX
//
//  Created by Admin on 12/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import Foundation
import UIKit

class Globals {
    private static let instance = Globals()
    
    static func shared() -> Globals {
        return instance
    }
}

protocol HelperDelegate {
    func getViewController() -> UIViewController
}
