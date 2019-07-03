//
//  UserWaitPopup.swift
//  FLEX
//
//  Created by Admin on 18/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import Foundation
import UICircularProgressRing

protocol PopupDelegate: Any {
    func onClosePopup(_ sender: Any?)
}

class UserWaitPopup: BaseCustomView {
    @IBOutlet weak var mProgressTimer: UICircularProgressRing!
    @IBOutlet weak var mLblTimer: UILabel!
    @IBOutlet weak var waitingV: UIView!
    
    var timer: Timer?
    var nTime = 0
    
    var delegate: PopupDelegate?
    
    static func getView() -> UIView {
        return super.getView(nibName: "UserWaitPopup")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        waitingV.makeRound(radius: 30)
    }
    
    @IBAction func onButCancel(_ sender: Any?) {
        stopTimer()
        self.showView(false, animated: true)
        
        delegate?.onClosePopup(sender)
    }
    
    func updateTime(_ value: Int) {
        nTime = value
        
        let strTime = String(format: "%02d:%02d", nTime / 60, nTime % 60)
        mLblTimer.text = strTime

        mProgressTimer.value = CGFloat(value)
//        mProgressTimer.value = UICircularProgressRing.ProgressValue(value)
    }
    
    func startTimer() {
        // init progress
        updateTime(0)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.updateTime(self.nTime + 1)
            
            if self.nTime >= 120 {
                self.onButCancel(nil)
            }
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
}
