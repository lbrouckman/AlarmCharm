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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //Ways for the AppDelegate to know the users response to a notification
    private struct ActionConstants{
        static let SNOOZE_IDENTIFIER = "snooze"
        static let WAKE_IDENTIFIER = "WAKE UP"
        static let SNOOZE_TIME = 300.0
    }
    
    override init(){
        super.init()
        FIRApp.configure()
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier("60e000e2856448d286fbe2c11df11e20")
        // Do some additional configuration if needed here
        BITHockeyManager.sharedHockeyManager().startManager()
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()


        //Make sure that current alarm is set for later than the current time
        UserDefaults.ensureAlarmTime()
        application.registerUserNotificationSettings(Notifications.getNotificationSettings())
        //Wake up about every 5 minutes to fetch alarms from DB
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(300)
        FetchViewController.fetch {}
        return true
    }
    
  //  Function that is called every 5ish minutes to fetch alarms from DB
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
            UserDefaults.ensureAlarmTime()
            FetchViewController.fetch {
                completionHandler(.NewData)
            }
    }
    
    //Handling a notification response
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?,
                       forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject],completionHandler: () -> Void){
        if identifier != nil{
            switch identifier!{
            case ActionConstants.SNOOZE_IDENTIFIER:
                //We want to get current notification and push back 1 minute
                let date = notification.fireDate?.dateByAddingTimeInterval(ActionConstants.SNOOZE_TIME)
                notification.fireDate = date
                notification.alertBody = "Has been Snoozed"
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
                
            case ActionConstants.WAKE_IDENTIFIER:
                let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let goingOff : AlarmGoingOffViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlarmGoingOff") as! AlarmGoingOffViewController
                self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                self.window?.rootViewController = goingOff
                
                self.window?.makeKeyAndVisible()
            default:
                break
            }
        }
        completionHandler()
    }
    
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if notification.category == ActionConstants.WAKE_IDENTIFIER{
            let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let goingOff : AlarmGoingOffViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlarmGoingOff") as! AlarmGoingOffViewController
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window?.rootViewController = goingOff
            self.window?.makeKeyAndVisible()
        }
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "edu.stanford.lbrouckm.AlarmCharm" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
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

