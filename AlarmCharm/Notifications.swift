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
        notification.fireDate = NSDate()
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    static func AddAlarmNotification(date: NSDate){
        let notification = UILocalNotification()
        notification.alertBody = "Friend wakes you up" // message user sees
        notification.alertAction = "slide"
        notification.category = Constants.WAKE_UP_CATEGORY
        notification.fireDate =  date
        
        //Setting the sound to be the user's default sound preference
        var alarmDefaultDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(Constants.USER_ALARM_DEFAULT)
        if let songName = alarmDefaultDict?[Constants.USER_KEY_TO_GET_SONG_DEFAULT] as? String{
            print("user has a default set song")
            notification.soundName = songName + ".wav"
        }else{
            notification.soundName = UILocalNotificationDefaultSoundName
        }
        
        //CANCEL ALL PREVIOUS NOTIFICATIONS BECAUSE USER HAS CHANGED THEIR ALARM TIME
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    static func getNotificationSettings()-> UIUserNotificationSettings{
        let alarmGoesOffCategory = UIMutableUserNotificationCategory()
        let friendSetsAlarmCategory = UIMutableUserNotificationCategory()
        alarmGoesOffCategory.identifier = ActionConstants.ALARM_GOES_OFF_IDENTIFER
        alarmGoesOffCategory.setActions([Notifications.getSnoozeAction(), Notifications.getWakeAction()], forContext: .Default)
        let alarmGoesOffSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: Set(arrayLiteral: alarmGoesOffCategory))
        friendSetsAlarmCategory.identifier = ActionConstants.FRIENDS_SETS_ALARM_CATEGORY
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
    
    
    static func UpdateNotification(fileNameOfSound: String, fileNameOfImage: String){
        
        
    }
    static func CancelNotification(){
        
    }
    
    
    
}