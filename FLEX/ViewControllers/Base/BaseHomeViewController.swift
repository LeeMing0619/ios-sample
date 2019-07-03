//
//  BaseHomeViewController.swift
//  FLEX
//
//  Created by Admin on 16/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

class BaseHomeViewController: BaseMapViewController {

    @IBOutlet weak var profileBtn: UIButton!
    
    var mOrder: Order?
    var polygonRoads: [GMSPolyline] = []
    var mMarkerFrom: GMSMarker?
    var mMarkerTo: GMSMarker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileBtn.makeRound(radius: profileBtn.frame.width / 2)
        profileBtn.makeBorder(color: UIColor.init(red: 0/255, green: 204/255, blue: 157/255, alpha: 1.0), width: 2.0)
        // Do any additional setup after loading the view.
        // get fcm token
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                
                // remote token
                if let user = User.currentUser {
                    user.token = result.token
                    
                    // save to db
                    user.saveToDatabase(withField: User.FIELD_TOKEN, value: result.token)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // update user info
        updateUserInfo()
    }
    
    /// update current user info
    func updateUserInfo() {
        let user = User.currentUser!
        
        // photo
        if let photoUrl = user.photoUrl {
            profileBtn.sd_setImage(with: URL(string: photoUrl),
                                    for: .normal,
                                    placeholderImage: UIImage(named: "UserDefault"),
                                    options: .progressiveDownload,
                                    completed: nil)
        }
    }
    
    /// fetch current order info
    func getOrderInfo(completion: @escaping (()->()) = {}) {
        let userCurrent = User.currentUser!
        let dbRef = FirebaseManager.ref()
        
        showLoadingView()
        
        let query = dbRef.child(Order.TABLE_NAME_PICKED).child(userCurrent.id)
        query.observeSingleEvent(of: .value) { (snapshot) in
            // order not found
            if !snapshot.exists() {
                self.showLoadingView(show: false)
                return
            }
            
            self.mOrder = Order(snapshot: snapshot)
            
            self.updateMap()
            self.updateOrder()
            
            completion()
        }
    }
    
    /// update map - from, to
    func updateMap() {
        updateMapCamera()
        
        updateFromMark()
        updateToMark()
    }
    
    /// update map camera based on from & to locations
    ///
    /// - Parameter location: location description
    func updateMapCamera() {
        
        guard let order = mOrder else {
            return
        }
        
        if let coordFrom = order.from?.location, let coordTo = order.to?.location {
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(coordFrom)
            bounds = bounds.includingCoordinate(coordTo)
            
            if order.status > Order.STATUS_REQUEST {
                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 140 + 10, left: 20, bottom: 170 + 40, right: 20))
                mViewMap.animate(with: update)
                
                // draw a road path on the map
                if !self.polygonRoads.isEmpty {
                    return
                }
                
                ApiManager.shared().googleMapGetRoutes(pointFrom: coordFrom, pointTo: coordTo) { (routes, err) in
                    print("fetched routes: \(routes.count), \(err)")
                    for route in routes
                    {
                        let routeOverviewPolyline = route["overview_polyline"].dictionary
                        let points = routeOverviewPolyline?["points"]?.stringValue
                        let path = GMSPath.init(fromEncodedPath: points!)
                        let polyline = GMSPolyline.init(path: path)
                        polyline.strokeColor = UIColor.blue
                        polyline.strokeWidth = 3
                        polyline.map = self.mViewMap
                        
                        self.polygonRoads.append(polyline)
                    }
                }
            }
            else {
                removeRoadLines()
            }
            return
        }
        
        removeRoadLines()
        moveCameraToLocation(order.from?.location)
        moveCameraToLocation(order.to?.location)
    }
    
    /// remove lines on the map
    func removeRoadLines() {
        for polyline in self.polygonRoads {
            polyline.map = nil
        }
        
        self.polygonRoads.removeAll()
    }
    
    /// update "from marker" on the map
    func updateFromMark() {
        mMarkerFrom?.map = nil
        guard let order = mOrder else {
            return
        }
        if let l = order.from?.location {
            mMarkerFrom = GMSMarker()
            mMarkerFrom?.icon = UIImage(named: "MainLocationFrom")
            mMarkerFrom?.position = l
            mMarkerFrom?.map = mViewMap
        }
    }
    
    /// update "to marker" on the map
    func updateToMark() {
        mMarkerTo?.map = nil
        guard let order = mOrder else {
            return
        }
        if let l = order.to?.location {
            mMarkerTo = GMSMarker()
            mMarkerTo?.icon = UIImage(named: "MainLocationTo")
            mMarkerTo?.position = l
            mMarkerTo?.map = mViewMap
        }
    }
    
    /// update page based on order status
    func updateOrder() {
    }
    
    //
    // GMSMapViewDelegate
    //
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if self.isMapInited {
            return
        }
        updateMap()
        self.isMapInited = true
    }
    

    //MARK: - Button Actions
    @IBAction func onButProfile(_ sender: Any) {
        // go to profile page
    }
}
