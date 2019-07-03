//
//  JobRequestViewController.swift
//  FLEX
//
//  Created by Admin on 6/17/19.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit
import GoogleMaps

class JobRequestViewController: UIViewController {

    @IBOutlet weak var mLblPrice: UILabel!
    @IBOutlet weak var mLblDistance: UILabel!
    
    @IBOutlet weak var mViewUserinfo: UIView!
    @IBOutlet weak var mButUser: UIButton!
    @IBOutlet weak var mLblUsername: UILabel!
    
    @IBOutlet weak var mViewAddress: UIView!
    @IBOutlet weak var mLblAddressFrom: UILabel!
    @IBOutlet weak var mLblAddressTo: UILabel!
    
    @IBOutlet weak var mButAccept: UIButton!
    @IBOutlet weak var mButDecline: UIButton!
    
    @IBOutlet weak var mViewRide: UIView!
    
    var mViewRideMode: RideModeView?
    var userId: String?
    var mOrder: Order?
    var parentVC: DriverMainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // init UI
        mButDecline.makeRound(radius: 10.0)
        mButUser.makeRound(radius: mButUser.frame.width / 2)
        
        // init ride mode view
        mViewRideMode = RideModeView.getView() as? RideModeView
        mViewRideMode?.enableSwitch(false)
        mViewRide.addSubview(mViewRideMode!)
        
        // init page content
        mLblPrice.text = "--"
        mLblDistance.text = "-- km"
        mLblUsername.text = ""
        
        mLblAddressFrom.text = "------"
        mLblAddressTo.text = "------"
        
        enableButtons(false)
        
        // fetch user
        self.fetchUser()
        
        // fetch order
        self.fetchOrder()
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mViewRideMode?.frame = self.mViewRide.bounds
        mViewRideMode?.showView(true)
    }

    func enableButtons(_ enable: Bool) {
        mButAccept.makeEnable(enable: enable)
        mButDecline.makeEnable(enable: enable)
    }
    
    func fetchUser() {
        User.readFromDatabase(withId: self.userId!) { (user) in
            guard let user = user else {
                return
            }
            
            // photo
            if let photoUrl = user.photoUrl {
                self.mButUser.sd_setImage(with: URL(string: photoUrl),
                                          for: .normal,
                                          placeholderImage: UIImage(named: "UserDefault"),
                                          options: .progressiveDownload,
                                          completed: nil)
            }
            
            // name
            self.mLblUsername.text = user.userFullName()
        }
    }
    
    func fetchOrder() {
        let dbRef = FirebaseManager.ref()
        let query = dbRef.child(Order.TABLE_NAME_REQUEST).child(self.userId!)
        
        query.observeSingleEvent(of: .value) { (snapshot) in
            // order not found
            if !snapshot.exists() {
                return
            }
            
            let order = Order(snapshot: snapshot)
            self.updateOrder(order)
        }
    }
    
    /// update order info
    func updateOrder(_ order: Order) {
        // price
        mLblPrice.text = "USD \(order.fee.format(f: ".2"))"
        
        // distance
        if let from = parentVC?.mCoordinate, let to = order.from?.location {
            let locationFrom = CLLocation(latitude: from.latitude, longitude: from.longitude)
            let locationTo = CLLocation(latitude: to.latitude, longitude: to.longitude)
            let dist = locationTo.distance(from: locationFrom) / 1000.0
            
            mLblDistance.text = "\(dist.format(f: ".1")) km"
        }
        
        // address
        mLblAddressFrom.text = order.from?.name
        mLblAddressTo.text = order.to?.name
        
        // ride mode
        mViewRideMode?.updateRideView(order.rideMode)
        
        self.enableButtons(true)
        
        self.mOrder = order
    }
    
    @IBAction func onButMap(_ sender: Any) {
        mLblAddressFrom.text = self.mOrder?.from?.name
    }
    
    @IBAction func onButAccept(_ sender: Any) {
        
        // check if request is cancelled or taken by other driver
        mOrder?.isExistInDb(completion: { (snapshot) in
            if let data = snapshot {
                if data.exists() {
                    self.doAcceptOrder()
                    return
                }
            }
            
            // notice and return
            self.alertOk(title: "Sorry, you are a bit late",
                         message: "The request is already taken or cancelled by user",
                         cancelButton: "OK",
                         cancelHandler: { (action) in
                            self.backToMain()
            })
        })
        
        enableButtons(false)
    }
    
    func doAcceptOrder() {
        let userCurrent = User.currentUser!
        
        // add driver id in request order data
        mOrder?.saveToDatabase(withField: Order.FIELD_DRIVERID, value: userCurrent.id)
        mOrder?.driverId = userCurrent.id
        
        // update ride request count & ride accpet count
        userCurrent.rideAccepts += 1
        userCurrent.rideRequests += 1
        
        userCurrent.saveToDatabase(withField: User.FIELD_COUNT_RIDEACCEPT, value: userCurrent.rideAccepts)
        userCurrent.saveToDatabase(withField: User.FIELD_COUNT_RIDEREQUEST, value: userCurrent.rideRequests)
        
        self.parentVC?.setOrder(mOrder)
        
        backToMain()
    }
    
    @IBAction func onButDecline(_ sender: Any) {
        // remove "accept" mark and return
        FirebaseManager.ref().child(Order.TABLE_NAME_ACCEPT)
            .child(User.currentUser!.id)
            .child(self.userId!)
            .removeValue()
        
        backToMain()
    }
    
    func backToMain() {
//        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
