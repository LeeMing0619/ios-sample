//
//  Address.swift
//  FLEX
//
//  Created by Admin on 12/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import Foundation
import Firebase

enum AddressType: String {
    case home = "home"
    case restaurant = "restaurant"
}

class Address: BaseModel {
    static let TABLE_NAME = "addresses"
    
    static let FIELD_LATITUDE = "latitude"
    static let FIELD_LONGITUDE = "longitude"
    static let FIELD_LOCATION = "location"
    static let FIELD_TYPE = "type"
    
    var latitude = 0.0
    var longitude = 0.0
    
    var location = ""
    var type = AddressType.home
    
    override func tableName() -> String {
        return Address.TABLE_NAME
    }
    
    override init() {
        super.init()
    }
    
    override init(snapshot: DataSnapshot) {
        super.init(snapshot: snapshot)
        let info = snapshot.value! as! [String: Any?]
        self.latitude = info[Address.FIELD_LATITUDE] as! Double
        self.longitude = info[Address.FIELD_LONGITUDE] as! Double
        self.location = info[Address.FIELD_LOCATION] as! String
        self.type = AddressType(rawValue: info[Address.FIELD_TYPE] as! String) ?? AddressType.home
    }
    
    func typeString() -> String {
        if type == AddressType.home {
            return "Home"
        }
        else {
            return "Restaurant"
        }
    }
    
    override func toDictionary() -> [String: Any] {
        var dict = super.toDictionary()
        dict[Address.FIELD_LATITUDE] = self.latitude
        dict[Address.FIELD_LONGITUDE] = self.longitude
        dict[Address.FIELD_LOCATION] = self.location
        dict[Address.FIELD_TYPE] = self.type.rawValue
        return dict
    }
    
    func removeFromDatabase(_ userId: String) {
        getDatabaseRef(parentID: userId).removeValue()
    }
}
