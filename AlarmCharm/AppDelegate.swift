//
//  AppDelegate.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 5/13/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    private struct ActionConstants{
        static let SNOOZE_IDENTIFIER = "snooze"
        static let SNOOZE_TITLE = "SNOOZE"
        static let WAKE_IDENTIFIER = "WAKE UP"
        static let WAKE_TILE = "Wake up silly gooose"
        static let ALARM_GOES_OFF_IDENTIFER = "alarm is going off"
        static let FRIENDS_SETS_ALARM_CATEGORY = "friend has set alarm"
    }
    let alarmGoesOffCategory = UIMutableUserNotificationCategory()
    let friendSetsAlarmCategory = UIMutableUserNotificationCategory()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // App just launched, we need to ask user if we can use notifications
        //look into doing custom actions on alerts in UIUserNotificationSettings
        
        let snoozeAction = UIMutableUserNotificationAction()
        snoozeAction.identifier = ActionConstants.SNOOZE_IDENTIFIER
        snoozeAction.destructive = false
        snoozeAction.title = ActionConstants.SNOOZE_TITLE
        //Maybe change this to back ground
        snoozeAction.activationMode = .Background
        snoozeAction.authenticationRequired = false
        
        let wakeAction = UIMutableUserNotificationAction()
        wakeAction.identifier = ActionConstants.WAKE_IDENTIFIER
        wakeAction.destructive = false
        wakeAction.title = ActionConstants.WAKE_TILE
        wakeAction.activationMode = .Foreground
        wakeAction.authenticationRequired = false
        
        alarmGoesOffCategory.identifier = ActionConstants.ALARM_GOES_OFF_IDENTIFER
        alarmGoesOffCategory.setActions([snoozeAction, wakeAction], forContext: .Default)
        let alarmGoesOffSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: Set(arrayLiteral: alarmGoesOffCategory))
        
        friendSetsAlarmCategory.identifier = ActionConstants.FRIENDS_SETS_ALARM_CATEGORY
        //Implement this later for this tupe of notification
        application.registerUserNotificationSettings(alarmGoesOffSettings)
        
        
        
        
        let opt = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey]
        print(opt)
        //Look up to see how user got there, if user pushes snooze, change current notification time by 5 minutes
        //If user pushed wake me up, go to scene of friend
        //Note we will need to get asked to wake up before notification
        
        
        
        return true
    }
    //THIS SHOULD ONLY BE CALLED IF APP IS CURRENTLY RUNNING OR IN BACKGROUND BUT WE STILL NEED TO HANDLE IT THE SAME WAY
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print(notification)
    }
    
    //This gets called if user hits wake up or snooze
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?,
                       forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject],completionHandler: () -> Void){
        if identifier != nil{
            switch identifier!{
            case ActionConstants.SNOOZE_IDENTIFIER:
                //We want to get current notification and push back 1 minute
                let date = notification.fireDate?.dateByAddingTimeInterval(60.0)
                notification.fireDate = date
                notification.alertBody = "Has been Snoozed"
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
                print("snoozed and reset alarm")
            case ActionConstants.WAKE_IDENTIFIER:
                print("wake me up")
                //AND LAUNCH? BUT THIS MIGHT BE IN BACKGROUND
            default:
                break
            }
        }
        completionHandler()
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

