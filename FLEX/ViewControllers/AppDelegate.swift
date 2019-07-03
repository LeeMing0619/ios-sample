//
//  AppDelegate.swift
//  FLEX
//
//  Created by Admin on 10/06/2019.
//  Copyright © 2019 Flex.Inc. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var pendingUserId: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        //FOR IQKeyboard
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses.append(UIStackView.self)
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysShow

        
        //Firebase initialization
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        //Google map initialization
        GMSServices.provideAPIKey(Config.googleMapApiKey)
        GMSPlacesClient.provideAPIKey(Config.googleMapApiKey)
        
        // Register for remote notifications
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // detect where to go.
        let userId = FirebaseManager.mAuth.currentUser?.uid
        if !Utils.isStringNullOrEmpty(text: userId) {
            // open splash screen temporately
            let splashVC = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
            self.window?.rootViewController = splashVC
            
            //check connection
            if Constants.reachability.connection == .none {
                if let tutorial = UserDefaults.standard.value(forKey: Config.KEY_TUTORIAL) as? Bool, tutorial == true {
                    ///tutorial is true
                    ///go to SignIn ViewController
                    let storyboard = UIStoryboard(name: "Login", bundle: nil)
                    let signinVC = storyboard.instantiateViewController(withIdentifier: "SigninViewController") as! SigninViewController
                    let nav = storyboard.instantiateInitialViewController() as! UINavigationController
                    nav.viewControllers = [signinVC]
                    self.window?.rootViewController = nav
                } else {
                    ///tutorial is false
                    ///go to Onboarding viewcontroller
                    let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
                    let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
                    let nav = storyboard.instantiateInitialViewController() as! UINavigationController
                    nav.viewControllers = [onboardingVC]
                    self.window?.rootViewController = nav
                }
            } else {
                User.readFromDatabase(withId: userId!, completion: { (user) in
                    User.currentUser = user
                    if user != nil {
                        let userCurrent = User.currentUser!
                        if userCurrent.type == UserType.driver {
                            //go to home page for driver
                            //MainDriverViewController
                            let storyboard = UIStoryboard(name: "MainDriver", bundle: nil)
                            let maindriverVC = storyboard.instantiateViewController(withIdentifier: "MainDriverBaseViewController") as! MainDriverBaseViewController
                            //                            let nav = storyboard.instantiateInitialViewController() as! UINavigationController
                            //                            nav.viewControllers = [onboardingVC]
                            self.window?.rootViewController = maindriverVC
                        }
                        else if userCurrent.type == UserType.customer {
                            //go to home page for customer
                            //MainUserViewController
                            let storyboard = UIStoryboard(name: "MainUser", bundle: nil)
                            let mainuserVC = storyboard.instantiateViewController(withIdentifier: "MainUserBaseViewController") as! MainUserBaseViewController
//                            let nav = storyboard.instantiateInitialViewController() as! UINavigationController
//                            nav.viewControllers = [onboardingVC]
                            self.window?.rootViewController = mainuserVC
                        }
                        else {
                            let storyboard = UIStoryboard(name: "MainUser", bundle: nil)
                            let mainuserVC = storyboard.instantiateViewController(withIdentifier: "MainUserBaseViewController") as! MainUserBaseViewController
                            //                            let nav = storyboard.instantiateInitialViewController() as! UINavigationController
                            //                            nav.viewControllers = [onboardingVC]
                            self.window?.rootViewController = mainuserVC
                        }
                    } else {
                        ///go to SignIn viewController
                        let storyboard = UIStoryboard(name: "Login", bundle: nil)
                        let signinVC = storyboard.instantiateViewController(withIdentifier: "SigninViewController") as! SigninViewController
                        let nav = storyboard.instantiateInitialViewController() as! UINavigationController
                        nav.viewControllers = [signinVC]
                        self.window?.rootViewController = nav
                    }
                })
            }
        } else {
            if let tutorial = UserDefaults.standard.value(forKey: Config.KEY_TUTORIAL) as? Bool, tutorial == true {
                ///tutorial is true
                ///go to SignIn ViewController
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let signinVC = storyboard.instantiateViewController(withIdentifier: "SigninViewController") as! SigninViewController
                let nav = storyboard.instantiateInitialViewController() as! UINavigationController
                nav.viewControllers = [signinVC]
                self.window?.rootViewController = nav
            } else {
                ///tutorial is false
                ///go to Onboarding viewcontroller
                let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
                let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
                let nav = storyboard.instantiateInitialViewController() as! UINavigationController
                nav.viewControllers = [onboardingVC]
                self.window?.rootViewController = nav
            }
        }
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if let strUserId = self.pendingUserId {
            // go to message page
            let rootViewController = self.window!.rootViewController as! UINavigationController
            let chatVC = ChatViewController(nibName: "ChatViewController", bundle: nil)
            chatVC.userToId = strUserId
            rootViewController.pushViewController(chatVC, animated: true)
            // clear pending user info
            self.pendingUserId = nil
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "FLEX")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("fcm token:\(fcmToken)")
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("fcm message received:\(remoteMessage.appData)")
    }
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        //        if let messageID = userInfo[gcmMessageIDKey] {
        //            print("Message ID: \(messageID)")
        //        }
        
        self.processNotification(application, userInfo: userInfo)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        //        if let messageID = userInfo[gcmMessageIDKey] {
        //            print("Message ID: \(messageID)")
        //        }
        //
        // Print full message.
        self.processNotification(application, userInfo: userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func processNotification(_ application: UIApplication,
                             userInfo: [AnyHashable: Any]) {
        print(userInfo)
        
        if application.applicationState != .active {
            // tapped notification from background
            self.pendingUserId = userInfo[Message.PN_FIELD_USER_ID] as? String
        }
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
}
