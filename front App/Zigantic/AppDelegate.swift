//
//  AppDelegate.swift
//  Bityo
//
//  Created by Chirag Ganatra on 28/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import GooglePlaces
import GoogleMaps
import FBSDKShareKit
import FBSDKLoginKit
import FBSDKCoreKit
//import GoogleSignIn
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseMessaging
import Fabric
import TwitterKit
import Crashlytics
import UserNotifications
import SDWebImage

var DELEGATE : AppDelegate!
var googleMapAPIKey = "AIzaSyBxd_VOcPZ1EDWAuUprkZpExj9FxwvYJlQ"
var myLocation = CLLocationCoordinate2D()
var statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, CLLocationManagerDelegate
{
    var window: UIWindow?
    var firstRun: Bool?
    let gcmMessageIDKey = "gcm.message_id"
    var notifies = [FSNotification]()
    var curConversationId : String = ""

    func showLoader()
    {
        let indicator = RTSpinKitView(frame: CGRect(x: (UIScreen.main.bounds.width-80)/2, y: (UIScreen.main.bounds.height - 80)/2, width: 80, height: 80))
        indicator.style = RTSpinKitViewStyle.styleFadingCircleAlt
        indicator.spinnerSize = 50.0
        indicator.color = themeOrangeColor
        indicator.startAnimating()
        self.window?.isUserInteractionEnabled = false
        DELEGATE?.window?.addSubview(indicator)
    }
    
    func hideLoader()
    {
        for views in (DELEGATE?.window?.subviews)!
        {
            if views is RTSpinKitView
            {
                views.removeFromSuperview()
            }
        }
        self.window?.isUserInteractionEnabled = true
    }
    
    func goHomePage(transition: Bool)
    {
        let sideMenuNavigationController = Utilities.viewController("sidemenuNav", onStoryboard: "Sidemenu")
        let homeNavigationController = Utilities.viewController("navFeeds", onStoryboard: "Feeds")
        let options : MVYSideMenuOptions = MVYSideMenuOptions()
        options.bezelWidth = UIScreen.main.bounds.width;
        options.contentViewScale = 1 //1.0 to disable scale
        options.contentViewOpacity = 0.5 // 0.0 to disable opacity
        options.animationDuration = 0.3
        let sideMenuController = MVYSideMenuController(menuViewController: sideMenuNavigationController, contentViewController: homeNavigationController,options: options)
        let screenSize = UIScreen.main.bounds.size
        sideMenuController?.menuFrame = CGRect(x: 0, y: 0, width: screenSize.width - 50, height: screenSize.height)
        let transitionOption = transition ? UIViewAnimationOptions.transitionFlipFromLeft : UIViewAnimationOptions.showHideTransitionViews
        gotoViewController(viewController: sideMenuController!, transition: transitionOption)
    }
    
    func goLoginPage(transition: Bool)
    {
        let sideMenuNavigationController = Utilities.viewController("sidemenuNav", onStoryboard: "Sidemenu")
        let homeNavigationController = Utilities.viewController("navAuthentication", onStoryboard: "Authentication")
        let options : MVYSideMenuOptions = MVYSideMenuOptions()
        options.bezelWidth = UIScreen.main.bounds.width;
        options.contentViewScale = 1 //1.0 to disable scale
        options.contentViewOpacity = 0.5 // 0.0 to disable opacity
        options.animationDuration = 0.3
        let sideMenuController = MVYSideMenuController(menuViewController: sideMenuNavigationController, contentViewController: homeNavigationController,options: options)
        let screenSize = UIScreen.main.bounds.size
        sideMenuController?.menuFrame = CGRect(x: 0, y: 0, width: screenSize.width - 50, height: screenSize.height)
        let transitionOption = transition ? UIViewAnimationOptions.transitionFlipFromLeft : UIViewAnimationOptions.showHideTransitionViews
        gotoViewController(viewController: sideMenuController!, transition: transitionOption)
    }
    
    func gotoViewController(viewController: UIViewController, transition: UIViewAnimationOptions)
    {
        if transition != UIViewAnimationOptions.showHideTransitionViews
        {
            UIView.transition(with: self.window!, duration: 0.5, options: transition, animations: { () -> Void in
                self.window!.rootViewController = viewController
            }, completion: { (finished: Bool) -> Void in
                // do nothing
            })
        } else {
            window!.rootViewController = viewController
        }
    }
    
    func checkForLocation(vc : UIViewController) -> Bool
    {

        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined:
                return false
                
            case .restricted:
                return false

            case .denied :
                
                showDialogu(vcc: vc)
                return false
            case .authorizedAlways, .authorizedWhenInUse:
        
                    //locationManager.startUpdatingHeading()
                
                return true
            }
        } else {
            print("showDialog")
            showDialogu(vcc: vc)
            return false
        }
    }
    
    func showDialogu(vcc : UIViewController){
        
        let alertController = UIAlertController(
            title:  "Location Access Disabled",
            message: "Location settings",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        alertController.addAction(openAction)
        vcc.present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: - CLLocation MAnager Delegate -
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        myLocation = (manager.location?.coordinate)!
        
        //guard let loc = locations.last else { return }
        //        let time = loc.timestamp
        //        guard let startTime = startTime else
        //        {
        //            self.startTime = time // Saving time of first location, so we could use it to compare later with second location time.
        //            return //Returning from this function, as at this moment we don't have second location.
        //        }
        //        let elapsed = time.timeIntervalSince(startTime) // Calculating time interval between first and second (previously saved) locations timestamps.
        //        if elapsed > 10 { //If time interval is more than 30 seconds
        //            print("Upload updated location to server")
        //            myLocation = loc.coordinate
        //            self.startTime = time //Changing our timestamp of previous location to timestamp of location we already uploaded.
        //            
        //        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //AIzaSyBxd_VOcPZ1EDWAuUprkZpExj9FxwvYJlQ <- Google Map API Key
        DELEGATE = UIApplication.shared.delegate as! AppDelegate!
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true

        GMSPlacesClient.provideAPIKey("\(googleMapAPIKey)")
        GMSServices.provideAPIKey("\(googleMapAPIKey)")
        
        statusBar?.backgroundColor = .clear
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
        FBSDKApplicationDelegate .sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn .sharedInstance().clientID = "716454410384-lu474cmkf0gl171ikar1s9sd38c50dhv.apps.googleusercontent.com"//"1059034196927-l5hh8vkrql7vg1qaguqtrr8aqjhukgog.apps.googleusercontent.com"
        
//        Fabric.with([[TWTRTwitter.self], [Crashlytics.self]])
        Fabric.with([Crashlytics.self])

        initData()
        initFirebase(application)
        SDWebImageManager.shared().imageDownloader?.maxConcurrentDownloads = kMaxConcurrentImageDownloads
        
        let locationManager = LocationManager.shared
        locationManager.requestWhenInUseAuthorization()
        
        return true
    }
    
    func initData() {
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: "p4bKIMTrrog3UQxLNMNNdjTR8", consumerSecret:"K58GnPpZW2wDGcIA9IRkEzjzh2zB2tBXwWucQAHjd0ZWuOngza")

        self.curConversationId = ""
        self.firstRun =  UserDefaults.standard.bool(forKey: "_firstRun")
        UserDefaults.standard.set(true, forKey: "_firstRun")
        UserDefaults.standard.synchronize()
        
        if self.firstRun == true {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    func initFirebase(_ application: UIApplication) {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
        if #available(iOS 10.0, *) {
            let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let actionText = UNTextInputNotificationAction(identifier: "ACTION_TEXT", title: "Reply", options: [])
            let category =  UNNotificationCategory(identifier: "ACTIONABLE", actions: [actionText], intentIdentifiers: [], options: [])
            
            UNUserNotificationCenter.current().setNotificationCategories([category])
            
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        application.registerForRemoteNotifications()
        
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        if (FSUserManager.sharedInstance.user != nil) {
            FSUserManager.sharedInstance.registerFirebaseToken()
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        if !(InstanceID.instanceID().token() != nil) {
            return
        }
        Messaging.messaging().disconnect()
        Messaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                if let token = InstanceID.instanceID().token() {
                    print("Connected to FCM with token \(token)")
                }
            }
        }
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Messaging.messaging().disconnect()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        UIApplication.shared.applicationIconBadgeNumber = 0
        connectToFcm()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "fb2021647104747581"{
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
        else if LISDKCallbackHandler.shouldHandle(url) {
            return LISDKCallbackHandler.application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
        else if url.scheme == "com.googleusercontent.apps.716454410384-lu474cmkf0gl171ikar1s9sd38c50dhv"
        {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
            
        }else{
            return true
        }
    }
    
    //FIRMessaging Delegate
    func application(received remoteMessage: MessagingRemoteMessage) {
    }

}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo as! NSDictionary
        let aps = userInfo["aps"] as! NSDictionary
        let alert = aps["alert"] as! NSDictionary
        let badge:Int = aps["badge"] as! Int
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        UIApplication.shared.applicationIconBadgeNumber = badge
        
        // Print message ID.-
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)

        if (userInfo["roomId"] as! String == self.curConversationId){
            completionHandler([])
        }
        else {
            let notiFication = FSNotification.init(senderId: userInfo["senderId"] as! String, senderName: alert["title"] as! String, timestamp:Date().iso8601, content:alert["body"] as! String, chatId: userInfo["chatId"] as! String)
            self.notifies.append(notiFication)

            completionHandler(UNNotificationPresentationOptions.alert)
        }
        // Change this to your preferred presentation option
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo as! NSDictionary
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}





