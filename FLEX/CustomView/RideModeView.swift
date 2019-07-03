//
//  RideModeView.swift
//  FLEX
//
//  Created by Admin on 6/17/19.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import Foundation
import UIKit

protocol RideModeDelegate: Any {
    func onChangeMode(_ mode: Int)
}

class RideModeView: BaseCustomView {
    
    @IBOutlet weak var mImgViewRideNormal: UIImageView!
    @IBOutlet weak var mImgViewRideSuv: UIImageView!
    
    @IBOutlet weak var mButNormal: UIButton!
    @IBOutlet weak var mButSuv: UIButton!
    
    @IBOutlet weak var mNormalBottomV: UIView!
    @IBOutlet weak var mSuvBottomV: UIView!
    
    
    var delegate: RideModeDelegate?
    
    static func getView() -> UIView {
        return super.getView(nibName: "RideModeView")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // init images
//        mImgViewRideNormal.image = mImgViewRideNormal.image!.withRenderingMode(.alwaysTemplate)
//        mImgViewRideSuv.image = mImgViewRideSuv.image!.withRenderingMode(.alwaysTemplate)
        
        clearModeColor()
    }
    
    func enableSwitch(_ enable: Bool) {
        mButNormal.makeEnable(enable: enable)
        mButSuv.makeEnable(enable: enable)
    }
    
    func clearModeColor() {
        mSuvBottomV.backgroundColor = UIColor.clear
        mNormalBottomV.backgroundColor = UIColor.clear
    }
    
    /// update switch based on current mode
    func updateRideView(_ rideMode: Int) {
        clearModeColor()
        
        switch rideMode {
        case Order.RIDE_MODE_NORMAL:
            mNormalBottomV.backgroundColor = Constants.gColorMain
        case Order.RIDE_MODE_SUV:
            mSuvBottomV.backgroundColor = Constants.gColorMain
            
        default:
            break
        }
    }
    
    @IBAction func onButRideNormal(_ sender: Any) {
        let mode = Order.RIDE_MODE_NORMAL
        
        // update UI
        updateRideView(mode)
        delegate?.onChangeMode(mode)
    }
    
    @IBAction func onButRideSuv(_ sender: Any) {
        let mode = Order.RIDE_MODE_SUV
        
        // update UI
        updateRideView(mode)
        delegate?.onChangeMode(mode)
    }
    
}
