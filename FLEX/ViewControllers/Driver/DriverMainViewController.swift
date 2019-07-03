//
//  DriverMainViewController.swift
//  FLEX
//
//  Created by Admin on 6/17/19.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit
import GoogleMaps
import GeoFire
import Firebase

class DriverMainViewController: BaseHomeViewController {
    
    @IBOutlet weak var switchBtn: UIButton!
    
    @IBOutlet weak var mViewMenu: UIView!
    @IBOutlet weak var mViewInfo: UIView!
    
    @IBOutlet weak var mLblAcceptance: UILabel!
    @IBOutlet weak var mLblRating: UILabel!
    @IBOutlet weak var mLblCancellation: UILabel!
    
    @IBOutlet weak var mViewPanel: UIView!
    @IBOutlet weak var mButComplete: UIButton!
    @IBOutlet weak var mLblPrice: UILabel!
    
    var mqueryRequest: DatabaseReference?
    var mqueryPickup: DatabaseReference?
    var mUserIds: [String] = []
    
    var sendUserID: String?
    var sendUserTo: User?
    var isAvailable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mViewMenu.makeRound(radius: 20)
        mViewInfo.makeRound(radius: 20)
        
        let userCurrent = User.currentUser!
        
        //broken state
        self.setUserBroken(isbool: !userCurrent.broken)
        
        // wait for user request
        mqueryRequest = FirebaseManager.ref().child(Order.TABLE_NAME_ACCEPT).child(userCurrent.id)
        mqueryRequest?.observe(.childAdded, with: { (snapshot) in
            if !snapshot.exists() {
                return
            }
            //
            // a request has been added
            //
//            if !userCurrent.accepted {
//                // not approved driver
//                self.alertOk(title: "Not approved yet",
//                             message: "Your driver account should be accepted by Admin",
//                             cancelButton: "OK",
//                             cancelHandler: nil)
//                return
//            }
            // if in broken state, cannot accept any request
            if userCurrent.broken {
                return
            }
            // if in order, cannot accept any request
            if let _ = self.mOrder {
                return
            }
            let userId = snapshot.key
            // popup request page
            self.sendUserID = userId
            self.performSegue(withIdentifier: "goJobSegue", sender: self)
//            let requestVC = JobRequestViewController(nibName: "JobRequestViewController", bundle: nil)
//            requestVC.userId = userId
//            requestVC.parentVC = self
//
//            let nav = UINavigationController(rootViewController: requestVC)
//            self.present(nav, animated: true, completion: nil)
        })
        
        // listener for order complete
        listenOrderComplete()
        
        // fetch current order
        getOrderInfo()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userCurrent = User.currentUser!
        if userCurrent.rideRequests > 0 {
            let dAccept = Double(userCurrent.rideAccepts) / Double(max(userCurrent.rideRequests, 1))
            mLblAcceptance.text = (dAccept * 100.0).format(f: ".2") + " %"
            mLblCancellation.text = ((1 - dAccept) * 100.0).format(f: ".2") + " %"
        }
        mLblRating.text = userCurrent.userRate().format(f: ".2")
    }
    
    deinit {
        // remove observers
        mqueryRequest?.removeAllObservers()
        mqueryPickup?.removeAllObservers()
    }
    
    func listenOrderComplete() {
        let userCurrent = User.currentUser!
        // wait for remove data from picked
        mqueryPickup = FirebaseManager.ref().child(Order.TABLE_NAME_PICKED).child(userCurrent.id)
        mqueryPickup?.observe(.value, with: { (snapshot) in
            // order has completed, update order
            if !snapshot.exists() {
                self.orderComplete()
            }
        })
    }
    
    func setOrder(_ order: Order?) {
        mOrder = order
        updateOrder()
    }
    
    override func updateOrder() {
        super.updateOrder()
        // in order
        if let order = mOrder {
            mViewInfo.isHidden = true
            mViewPanel.isHidden = false
            // price
            mLblPrice.text = "$\(order.fee.format(f: ".2"))"
            // fetch driver
            if order.customer == nil {
                User.readFromDatabase(withId: order.customerId) { (user) in
                    order.customer = user
                    self.showLoadingView(show: false)
                }
            }
            else {
                showLoadingView(show: false)
            }
        }
        else {
            mViewInfo.isHidden = false
            mViewPanel.isHidden = true
        }
    }
    
    func orderComplete() {
        // clear order
        let _ = showMyLocation(location: mCoordinate, updateForce: true)
        setOrder(nil)
        // clear map
        mViewMap.clear()
        updateMap()
    }
    
    // MARK: - Button Actions
    
    @IBAction func switchButton_TouchUpInside(_ sender: Any) {
        
        if isAvailable {
            isAvailable = false
            switchBtn.setImage(UIImage(named: "s_available"), for: .normal)
        } else {
            isAvailable = true
            switchBtn.setImage(UIImage(named: "s_unavailable"), for: .normal)
        }
        self.setUserBroken(isbool: isAvailable)
    }
    
    private func setUserBroken(isbool: Bool) {
        let userCurrent = User.currentUser!
        userCurrent.broken = !isAvailable
        print(userCurrent.broken)
        userCurrent.saveToDatabase(withField: User.FIELD_BROKEN, value: userCurrent.broken)
    }
    
    @IBAction func menuButton_TouchUpInside(_ sender: Any) {
        panel?.openLeft(animated: true)
    }
    
    @IBAction func cancelButton_TouchUpInside(_ sender: Any) {
        self.alert(title: "Are you sure to cancel this ride?",
                   message: "You may cause no income for this ride",
                   okButton: "OK",
                   cancelButton: "Cancel",
                   okHandler: { (_) in
                    self.doCancelRide()
        }, cancelHandler: nil)
    }
    
    @IBAction func chatButton_TouchUpInside(_ sender: Any) {
        guard let order = mOrder else {
            return
        }
        guard let customer = order.customer else {
            return
        }
        self.sendUserTo = customer
        // go to chat page
        self.performSegue(withIdentifier: "goChatFromDriverSegue", sender: self)
//        let chatVC = ChatViewController(nibName: "ChatViewController", bundle: nil)
//        chatVC.userTo = customer
//        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @IBAction func completeButton_TouchUpInside(_ sender: Any) {
        self.alert(title: "Arrived Destination?",
                   message: "You can ask payment to user for this trip",
                   okButton: "Yes",
                   cancelButton: "No",
                   okHandler: { (_) in
                    self.doCompleteRide()
        }, cancelHandler: nil)
    }
    
    /// complete ride
    func doCompleteRide() {
        guard let order = mOrder else {
            return
        }
        // set order status
        order.status = Order.STATUS_ARRIVED
        let userCurrent = User.currentUser!
        // add a mark to "arrived" table
        let dbRef = FirebaseManager.ref().child(Order.TABLE_NAME_ARRIVED)
        dbRef.child(order.customerId).child(userCurrent.id).setValue(true)
    }
    
    /// cancel ride
    func doCancelRide() {
        guard let order = mOrder else {
            return
        }
        // clear data in database
        order.clearFromDatabase()
        orderComplete()
    }
    
    
    /// Called when location has updated
    override func showMyLocation(location: CLLocationCoordinate2D?, updateForce: Bool = false) -> Bool {
        
        let _ = super.showMyLocation(location: location, updateForce: updateForce)
        
        guard let l = location else {
            return false
        }
        
        let cLoc = CLLocation(latitude: l.latitude, longitude: l.longitude)
        // update location driver status
        let driverStatusRef = FirebaseManager.ref().child(DriverStatus.TABLE_NAME)
        let geoFire = GeoFire(firebaseRef: driverStatusRef)
        
        if User.currentUser != nil {
            geoFire.setLocation(cLoc, forKey: User.currentUser!.id)
        }
                
        return true
    }
    
    // MARK: - Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goJobSegue" {
            let vc = segue.destination as! JobRequestViewController
            vc.userId = self.sendUserID
            vc.parentVC = self
        } else if segue.identifier == "goChatFromDriverSegue" {
            let vc = segue.destination as! ChatViewController
            vc.userTo = self.sendUserTo
        }
    }
}
