//
//  BaseMapViewController.swift
//  FLEX
//
//  Created by Admin on 16/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit
import GoogleMaps

class BaseMapViewController: BaseViewController {

    var locationManager = CLLocationManager()
    var mCoordinate: CLLocationCoordinate2D?
    var isMapInited = false
    
    @IBOutlet weak var mViewMap: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initLocation()
        initMap()
    }
    
    func initLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
    }
    
    func initMap() {
        mViewMap.isMyLocationEnabled = true
        mViewMap.settings.myLocationButton = true
        mViewMap.delegate = self
        _ = showMyLocation(location: mViewMap.myLocation?.coordinate)
    }
    
    func showMyLocation(location: CLLocationCoordinate2D?, updateForce: Bool = false) -> Bool {
        if mCoordinate != nil && !updateForce {
            // alredy showed my location, return
            return false
        }
        moveCameraToLocation(location)
        return true
    }
    
    func moveCameraToLocation(_ location: CLLocationCoordinate2D?) {
        guard let l = location else { return }
        let camera = GMSCameraPosition.camera(withLatitude: l.latitude,
                                              longitude: l.longitude,
                                              zoom: 16.0)
        mViewMap.animate(to: camera)
    }

}

extension BaseMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        print("\(location.coordinate.latitude) \(location.coordinate.longitude)")
        _ = showMyLocation(location: location.coordinate)
        mCoordinate = location.coordinate
    }
}

extension BaseMapViewController: GMSMapViewDelegate {
}
