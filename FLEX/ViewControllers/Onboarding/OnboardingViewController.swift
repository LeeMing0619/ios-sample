//
//  OnboardingViewController.swift
//  FLEX
//
//  Created by Admin on 10/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit
import paper_onboarding

class OnboardingViewController: UIViewController {

    @IBOutlet weak var skipBtn: UIButton!
    
    fileprivate let items = [
        OnboardingItemInfo(informationImage: UIImage(named: "Applogo_gray")!, title: "Find a Ride", description: "Find a Flex ride nearby. By enabling GPS, \n users are able to find available drivers \n in close proximity.", pageIcon: UIImage(), color: UIColor.white, titleColor: UIColor.darkGray, descriptionColor: UIColor.lightGray, titleFont: UIFont.boldSystemFont(ofSize: 25.0), descriptionFont: UIFont.systemFont(ofSize: 16.0)),
        OnboardingItemInfo(informationImage: UIImage(named: "Applogo_gray")!, title: "Pick your Ride", description: "Find the type of car you would like to ride \n in or rideshare based on our class selection; \n Eco Friendly, Median Size, Luxury, or Truck/SUV. \n Riders will be notified of their ride’s location and \n expected time of arrival.", pageIcon: UIImage(), color: UIColor.white, titleColor: UIColor.darkGray, descriptionColor: UIColor.lightGray, titleFont: UIFont.boldSystemFont(ofSize: 25.0), descriptionFont: UIFont.systemFont(ofSize: 16.0)),
        OnboardingItemInfo(informationImage: UIImage(named: "Applogo_gray")!, title: "Chat Support", description: "We are available 24/7 to help assist with \n your needs. You also have the ability to \n  communicate with driver once booking is made.", pageIcon: UIImage(), color: UIColor.white, titleColor: UIColor.darkGray, descriptionColor: UIColor.lightGray, titleFont: UIFont.boldSystemFont(ofSize: 25.0), descriptionFont: UIFont.systemFont(ofSize: 16.0)),
        OnboardingItemInfo(informationImage: UIImage(named: "Applogo_gray")!, title: "Payment", description: "With the pay later option you can delay \n paying for your ride. As a Flex Driver you get paid \n more with the lowest booking fee in the industry!", pageIcon: UIImage(), color: UIColor.white, titleColor: UIColor.darkGray, descriptionColor: UIColor.lightGray, titleFont: UIFont.boldSystemFont(ofSize: 25.0), descriptionFont: UIFont.systemFont(ofSize: 16.0))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skipBtn.makeRound(radius: 15.0)
        skipBtn.isHidden = true
        setupPaperOnboardingView()
        view.bringSubviewToFront(skipBtn)
    }
    
    private func setupPaperOnboardingView() {
        let onboarding = PaperOnboarding()
        onboarding.delegate = self
        onboarding.dataSource = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0)
            view.addConstraint(constraint)
        }
    }
    
    //MARK: - Button Action
    @IBAction func skipButton_TouchUpInside(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: Config.KEY_TUTORIAL)
        self.performSegue(withIdentifier: "goLoginSegue", sender: nil)
    }
    
}

extension OnboardingViewController: PaperOnboardingDataSource {
    func onboardingItemsCount() -> Int {
        return items.count
    }
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return items[index]
    }
}

extension OnboardingViewController: PaperOnboardingDelegate {
    func onboardingWillTransitonToIndex(_ index: Int) {
        skipBtn.isHidden = index == items.count - 1 ? false : true
    }
}
