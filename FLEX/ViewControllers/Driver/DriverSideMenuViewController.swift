//
//  DriverSideMenuViewController.swift
//  FLEX
//
//  Created by Admin on 6/17/19.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit

class DriverSideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblView: UITableView!
    
    var arrSlideInfo = NSMutableArray()
    override func viewDidLoad() {
        
        self.setInitparam()
        super.viewDidLoad()
    }

    func setInitparam()  {
        arrSlideInfo.removeAllObjects()
        
        let dict = NSMutableDictionary()
        dict.setValue("HOME", forKey: "title")
        dict.setValue("m_home", forKey: "icon")
        arrSlideInfo.add(dict)
        
        let dict1 = NSMutableDictionary()
        dict1.setValue("PROFILE", forKey: "title")
        dict1.setValue("m_profile", forKey: "icon")
        arrSlideInfo.add(dict1)
        
        let dict2 = NSMutableDictionary()
        dict2.setValue("PAYMENT", forKey: "title")
        dict2.setValue("m_payment", forKey: "icon")
        arrSlideInfo.add(dict2)
        
        let dict3 = NSMutableDictionary()
        dict3.setValue("RATE APP", forKey: "title")
        dict3.setValue("m_rate", forKey: "icon")
        arrSlideInfo.add(dict3)
        
        let dict4 = NSMutableDictionary()
        dict4.setValue("SEND FEEDBACK", forKey: "title")
        dict4.setValue("m_feedback", forKey: "icon")
        arrSlideInfo.add(dict4)
        
        let dict5 = NSMutableDictionary()
        dict5.setValue("ABOUT", forKey: "title")
        dict5.setValue("m_about", forKey: "icon")
        arrSlideInfo.add(dict5)
        
        let dict6 = NSMutableDictionary()
        dict6.setValue("LOGOUT", forKey: "title")
        dict6.setValue("m_logout", forKey: "icon")
        arrSlideInfo.add(dict6)
        
        tblView.reloadData()
    }

    /*
    @IBAction func onHome(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MainDriver", bundle: nil)
        let centerVC = storyboard.instantiateViewController(withIdentifier: "DriverMainViewController") as! DriverMainViewController
        panel?.configs.bounceOnCenterPanelChange = true
        _ = panel?.center(centerVC)
    }
    
    @IBAction func onProfile(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let centerVC = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        panel?.configs.bounceOnCenterPanelChange = true
        _ = panel?.center(centerVC)
    }
    @IBAction func onPayment(_ sender: Any) {
    }
    @IBAction func onRate(_ sender: Any) {
    }
    @IBAction func onFeedback(_ sender: Any) {
    }
    @IBAction func onAbout(_ sender: Any) {
    }
    @IBAction func onLogout(_ sender: Any) {
        FirebaseManager.signOut()
        User.currentUser = nil
        
        self.performSegue(withIdentifier: "goLogOutFromDriverSegue", sender: nil)
    }
    */
    
    // MARK: - Button Actions
    @IBAction func onPrivacy(_ sender: Any) {
    }
    
    @IBAction func onTerms(_ sender: Any) {
    }

    
    // MARK: - UITableview Datasurce And Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSlideInfo.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier: String = "cell \(Int(indexPath.row))"
        var cell: Cell_SideMenu? = (tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as? Cell_SideMenu)
        
        if cell == nil {
            let topLevelObjects: [Any] = Bundle.main.loadNibNamed("Cell_SideMenu", owner: nil, options: nil)!
            cell = (topLevelObjects[0] as? Cell_SideMenu)
            cell?.backgroundColor = UIColor.clear
            cell?.selectionStyle = .none
            
            let dictCell = (arrSlideInfo.object(at: indexPath.row) as! NSDictionary)
            cell?.lblTitle.text = dictCell.object(forKey: "title") as? String
            
            let imagename = dictCell.object(forKey: "icon") as! String
            let image : UIImage = UIImage(named:imagename)!
            cell?.imgIcon.image = image
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0
        {
            //HOME
            let storyboard = UIStoryboard(name: "MainDriver", bundle: nil)
            let centerVC = storyboard.instantiateViewController(withIdentifier: "DriverMainViewController") as! DriverMainViewController
            panel?.configs.bounceOnCenterPanelChange = true
            _ = panel?.center(centerVC)
        }
        else if indexPath.row == 1
        {
            //PROFILE
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let centerVC = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
            panel?.configs.bounceOnCenterPanelChange = true
            _ = panel?.center(centerVC)
        }
        else if indexPath.row == 2
        {
            //PAYMENT
            let storyboard = UIStoryboard(name: "Payment", bundle: nil)
            let centerVC = storyboard.instantiateViewController(withIdentifier: "CardsViewController") as! CardsViewController
            panel?.configs.bounceOnCenterPanelChange = true
            _ = panel?.center(centerVC)
        }
        else if indexPath.row == 3
        {
            //RATE APP
        }
        else if indexPath.row == 4
        {
            //SEND FEEDBACK
        }
        else if indexPath.row == 5
        {
            //ABOUT
        }
        else if indexPath.row == 6
        {
            //LOGOUT
            FirebaseManager.signOut()
            User.currentUser = nil
            self.performSegue(withIdentifier: "goLogOutFromDriverSegue", sender: nil)
        }
    }

}
