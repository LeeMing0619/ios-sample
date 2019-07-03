//
//  ApiManager.swift
//  FLEX
//
//  Created by Admin on 16/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import Foundation
import GoogleMaps
import Alamofire
import SwiftyJSON

class ApiManager {
    private static let mInstance = ApiManager()
    
    /// shared object
    static func shared() -> ApiManager {
        return mInstance
    }
    
    //
    // Google Apis
    //
    private let urlBaseMapApi = "https://maps.googleapis.com/maps/api"
    
    func googleMapGetDistance(pointFrom: CLLocationCoordinate2D,
                              pointTo: CLLocationCoordinate2D,
                              completion: @escaping (_ data: JSON?, _ error: Error?)->()) {
        var url = urlBaseMapApi + "/distancematrix/json?units=imperial"
        url += "&origins=\(pointFrom.latitude),\(pointFrom.longitude)"
        url += "&destinations=\(pointTo.latitude),\(pointTo.longitude)"
        url += "&key=\(Config.googleMapApiKey)"
        
        Alamofire.request(url)
            .validate()
            .responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let val):
                    let json = JSON(val)
                    
                    //                    print("JSON: \(json)")
                    
                    let row = json["rows"][0]
                    let element = row["elements"][0]
                    
                    completion(element, nil)
                    
                case .failure(let error):
                    completion(nil, error)
                }
            })
    }
    
    
    func googleMapGetRoutes(pointFrom: CLLocationCoordinate2D,
                            pointTo: CLLocationCoordinate2D,
                            completion: @escaping (_ data: [JSON], _ error: Error?)->()) {
        
        let strLocFrom = "\(pointFrom.latitude),\(pointFrom.longitude)"
        let strLocTo = "\(pointTo.latitude),\(pointTo.longitude)"
        
        var url = urlBaseMapApi + "/directions/json?"
        url += "origin=\(strLocFrom)"
        url += "&destination=\(strLocTo)"
        url += "&key=\(Config.googleMapApiKey)"
        
        Alamofire.request(url)
            .validate()
            .responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let val):
                    let json = JSON(val)
                    let routes = json["routes"].arrayValue
                    
                    completion(routes, nil)
                    
                case .failure(let error):
                    completion([], error)
                }
            })
    }
}
