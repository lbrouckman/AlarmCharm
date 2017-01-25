//
//  AppDelegate.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/13/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//
// We both made changes here

import UIKit
import CoreData
import Firebase
//import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate{
    
    var window: UIWindow?
    
    //Ways for the AppDelegate to know the users response to a notification
    fileprivate struct ActionConstants{
        static let SNOOZE_IDENTIFIER = "snooze"
        static let WAKE_IDENTIFIER = "WAKE UP"
        static let SNOOZE_TIME = 300.0
        static let DOWNLOAD_CATEGORY = "download category"
        static let DOWNLOAD_ACTION = "download action"
    }
    
    override init(){
        super.init()
        FIRApp.configure()
    }
    func registerForRemoteNotifications(_ application: UIApplication){
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            FIRMessaging.messaging().remoteMessageDelegate = self
        }
        application.registerForRemoteNotifications()
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //THIS gets called a billion times.
        NotificationCenter.default.addObserver(self, selector: #selector(tokenRefreshNotification(_:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object:nil )
        
        //Make sure that current alarm is set for later than the current time
        UserDefaults.ensureAlarmTime()
        if #available(iOS 10, *){
            Notifications.setNoticationsSettings10()
        }
        else{
            application.registerUserNotificationSettings(Notifications.getNotificationSettings())
        }
        registerForRemoteNotifications(application)
        print(FIRInstanceID.instanceID().token(), "is the token")
        //Wake up about every 5 minutes to fetch alarms from DB
        //        UIApplication.shared.setMinimumBackgroundFetchInterval(300)
        FetchViewController.fetch {}
        connectToFcm()
        
        print(FIRInstanceID.instanceID().token(), "is real token")
        print(FIRInstanceID.instanceID().token()?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, "is the token string")
        
        return true
    }
    func tokenRefreshNotification(_ notification: Notification) {
        
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            if let userNameStored = Foundation.UserDefaults.standard.value(forKey: "Username"){
                //update token in database
                let userID = Foundation.UserDefaults.standard.value(forKey: "PhoneNumber")
                //            let tokenName =  refreshedToken.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let remoteDB = Database()
                remoteDB.updateTokenForUser( forUser: userID as! String, forToken:refreshedToken)
            }
            // ADD TO USER DEFAULTS
            // IF THE USER HAS A NAME,IF NOT THEN WAIT.
            connectToFcm()
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
    }
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken, "is our device token")
        connectToFcm()
        FIRInstanceID.instanceID().setAPNSToken(deviceToken as Data, type: .sandbox)
        print(FIRInstanceID.instanceID().token(), "is allowed token now")
    }
    
    //Handling a notification response in ios < 10.
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?,
                     for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable: Any],completionHandler: @escaping () -> Void){
        if identifier != nil{
            switch identifier!{
            case ActionConstants.SNOOZE_IDENTIFIER:
                //We want to get current notification and push back 1 minute
                let date = notification.fireDate?.addingTimeInterval(ActionConstants.SNOOZE_TIME)
                notification.fireDate = date
                notification.alertBody = "Has been Snoozed"
                UIApplication.shared.scheduleLocalNotification(notification)
            case ActionConstants.WAKE_IDENTIFIER:
                alarmGoesOff()
            default:
                break
            }
        }
        completionHandler()
    }
    
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print("IN did recieve notification for local")
        if notification.category == ActionConstants.WAKE_IDENTIFIER{
            let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let goingOff : AlarmGoingOffViewController = mainStoryboard.instantiateViewController(withIdentifier: "AlarmGoingOff") as! AlarmGoingOffViewController
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = goingOff
            self.window?.makeKeyAndVisible()
        }
    }
    
    //Remote Notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // Print message ID.
        UserDefaults.setState(State.friendHasSetAlarm)
        print("receiving in old ios, calling handler now")
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func alarmGoesOff(){
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let goingOff : AlarmGoingOffViewController = mainStoryboard.instantiateViewController(withIdentifier: "AlarmGoingOff") as! AlarmGoingOffViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = goingOff
        self.window?.makeKeyAndVisible()
    }
    func goToConfirmPage(_ friendWhoSetAlarm: String?){
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let goingOff : ConfirmViewController = mainStoryboard.instantiateViewController(withIdentifier: "ConfirmViewControllerIdentifier") as! ConfirmViewController
        goingOff.charmer = friendWhoSetAlarm
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = goingOff
        self.window?.makeKeyAndVisible()
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "edu.stanford.lbrouckm.AlarmCharm" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
//Receiving notifications in the foreground ios 10!
@available(iOS 10, *)
extension AppDelegate {
    // Receive displayed notifications for iOS 10 devices.
    @objc(userNotificationCenter:willPresentNotification:withCompletionHandler:) func userNotificationCenter(_ center: UNUserNotificationCenter,
                                                                                                             willPresent notification: UNNotification,
                                                                                                             withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //Same logic on switching if it is local...
        completionHandler( [.alert,.sound])
        
    }
}


// To deal with handling actions the user made to our notifications...
extension AppDelegate{
    @objc(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:) @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("download in withCompletionHandler", response)
        // If we get a remote notification and they say download this is where it is handled (Once confirmed, do a download and grab info).
        //Handles Alarm going off
        //When we add the request the completion handler is easy to define, so maybe to that later.
        if response.actionIdentifier ==  ActionConstants.SNOOZE_IDENTIFIER{
            let snoozeDate = Date().addingTimeInterval(ActionConstants.SNOOZE_TIME)
            Notifications.AddAlarmNotification10(at: snoozeDate as Date)
        }
        else if response.actionIdentifier ==  ActionConstants.WAKE_IDENTIFIER{
            alarmGoesOff()
        }
        else if response.actionIdentifier == ActionConstants.DOWNLOAD_ACTION{
            print("User said to download alarm")
            //Go to a confirm page, this should happen whenever we get our alarm set by a friend
            //Should be (blank set your alarm, consent to the charm?
            FetchViewController.fetch {
                goToConfirmPage(UserDefaults.getFriendWhoSetAlarm())
                print("all fetched")
            }
        }
    }
}
extension AppDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        FetchViewController.fetch {}
        print("receiving it in firebase handler")
        print("%@", remoteMessage.appData)
    }
}
