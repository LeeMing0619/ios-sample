//
//  Card.swift
//  FLEX
//
//  Created by Admin on 12/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import Foundation
import Stripe

class Card {
    var last4 = ""
    var brand: STPCardBrand = .unknown
    
    init() {}
    
    init(withSTPCard card: STPCard) {
        last4 = card.last4
        brand = card.brand
    }
}
