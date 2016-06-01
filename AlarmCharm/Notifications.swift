//
//  Notifications.swift
//  AlarmCharm
//
//  Created by Alexander Carlisle on 5/28/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit
class Notifications{
    private struct ActionConstants{
        static let SNOOZE_IDENTIFIER = "snooze"
        static let SNOOZE_TITLE = "SNOOZE"
        static let WAKE_IDENTIFIER = "WAKE UP"
        static let WAKE_TILE = "Wake up silly gooose"
        static let ALARM_GOES_OFF_IDENTIFER = "alarm is going off"
        static let FRIENDS_SETS_ALARM_CATEGORY = "friend has set alarm"
    }
    
    static func addFriendSetAlarmNotification(friendName: String){
        let notification = UILocalNotification()
        notification.alertBody = friendName + " has set your alarm!"
        notification.category = ActionConstants.FRIENDS_SETS_ALARM_CATEGORY
        notification.fireDate = NSDate().dateByAddingTimeInterval(60)
        print("firing notification for ", notification.fireDate)
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    static func AddAlarmNotification(date: NSDate){
        let notification = UILocalNotification()
        notification.alertBody = "Friend wakes you up" // message user sees
        notification.alertAction = "slide"
        notification.category = Constants.WAKE_UP_CATEGORY
        notification.fireDate =  date
        
        //Setting the sound to be the user's default sound preference
       
            notification.soundName =  UserDefaults.getDefaultSongName() + ".wav"

        //CANCEL ALL PREVIOUS NOTIFICATIONS BECAUSE USER HAS CHANGED THEIR ALARM TIME
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    static func getNotificationSettings()-> UIUserNotificationSettings{
        let friendSetsAlarmCategory = UIMutableUserNotificationCategory()
        friendSetsAlarmCategory.identifier = ActionConstants.FRIENDS_SETS_ALARM_CATEGORY

        let alarmGoesOffCategory = UIMutableUserNotificationCategory()
        alarmGoesOffCategory.identifier = ActionConstants.ALARM_GOES_OFF_IDENTIFER
        alarmGoesOffCategory.setActions([Notifications.getSnoozeAction(), Notifications.getWakeAction()], forContext: .Default)
        
        let alarmGoesOffSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: Set(arrayLiteral: alarmGoesOffCategory, friendSetsAlarmCategory))
        return alarmGoesOffSettings
    }
    
    ///Move all logic into notifications
    static func getWakeAction() ->UIMutableUserNotificationAction{
        let wakeAction = UIMutableUserNotificationAction()
        wakeAction.identifier = ActionConstants.WAKE_IDENTIFIER
        wakeAction.destructive = false
        wakeAction.title = ActionConstants.WAKE_TILE
        wakeAction.activationMode = .Foreground
        wakeAction.authenticationRequired = false
        return wakeAction
    }
    static func getSnoozeAction() -> UIMutableUserNotificationAction{
        let snoozeAction = UIMutableUserNotificationAction()
        snoozeAction.identifier = ActionConstants.SNOOZE_IDENTIFIER
        snoozeAction.destructive = false
        snoozeAction.title = ActionConstants.SNOOZE_TITLE
        //Maybe change this to back ground
        snoozeAction.activationMode = .Background
        snoozeAction.authenticationRequired = false
        return snoozeAction
    }
    
    
    /*
     This function will be moved to Notification Class soon
     Grabs the notificationm and changes the soundName to be the sound name of the user
     */
    static func setNotificationFromFileSystem(){
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        if notifications?.count > 0 {
            if let oldNotification = notifications?[0]
            {
                oldNotification.soundName = "test.caf"
                UIApplication.sharedApplication().cancelAllLocalNotifications()
                UIApplication.sharedApplication().scheduleLocalNotification(oldNotification)
            }
        }
    }
    
    
    
    static func UpdateNotification(fileNameOfSound: String, fileNameOfImage: String){
        
        
    }
    static func CancelNotification(){
        
    }
    
    
    
}