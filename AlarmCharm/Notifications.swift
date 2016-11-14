//
//  Notifications.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/28/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//
// Alexander Carlisle

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

/* The Notifications class has all of the functionality related to notifications.
 */

class Notifications{
    fileprivate struct ActionConstants{
        static let SNOOZE_IDENTIFIER = "snooze"
        static let SNOOZE_TITLE = "SNOOZE"
        static let WAKE_IDENTIFIER = "WAKE UP"
        static let WAKE_TILE = "Wake up silly gooose"
        static let ALARM_GOES_OFF_IDENTIFER = "WAKE UP"
        static let FRIENDS_SETS_ALARM_CATEGORY = "friend has set alarm"
    }
    
    //Notification that tells user someone set their alarm
    static func addFriendSetAlarmNotification(_ friendName: String){
        let notification = UILocalNotification()
        notification.alertBody = friendName + " has set your alarm!"
        notification.category = ActionConstants.FRIENDS_SETS_ALARM_CATEGORY
        notification.fireDate = Date(timeIntervalSinceNow: 10)
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    //Wake up notification
    static func AddAlarmNotification(_ date: Date){
        let notification = UILocalNotification()
        
        notification.alertBody = "Wake up!"
        //If a friend has set your alarm for you, change the notification message
        if UserDefaults.hasAlarmBeenSet() {
            if let friendName = UserDefaults.getFriendWhoSetAlarm() {
                notification.alertBody = friendName + " wakes you up!" // message user sees
            }
        }
        notification.alertAction = "slide"
        notification.category = ActionConstants.ALARM_GOES_OFF_IDENTIFER
        notification.fireDate =  date
        
        //Setting the sound to be the user's default sound preference
        notification.soundName =  UserDefaults.getDefaultSongName() + ".wav"
        
        //CANCEL ALL PREVIOUS NOTIFICATIONS BECAUSE USER HAS CHANGED THEIR ALARM TIME
        UIApplication.shared.cancelAllLocalNotifications()
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    static func getNotificationSettings()-> UIUserNotificationSettings{
        let friendSetsAlarmCategory = UIMutableUserNotificationCategory()
        friendSetsAlarmCategory.identifier = ActionConstants.FRIENDS_SETS_ALARM_CATEGORY
        
        let alarmGoesOffCategory = UIMutableUserNotificationCategory()
        alarmGoesOffCategory.identifier = ActionConstants.ALARM_GOES_OFF_IDENTIFER
        
        alarmGoesOffCategory.setActions([Notifications.getSnoozeAction(), Notifications.getWakeAction()], for: .default)
        
        let alarmGoesOffSettings = UIUserNotificationSettings(types: [.alert, .sound], categories: Set(arrayLiteral: alarmGoesOffCategory, friendSetsAlarmCategory))
        return alarmGoesOffSettings
    }
    
    static func getWakeAction() ->UIMutableUserNotificationAction{
        let wakeAction = UIMutableUserNotificationAction()
        wakeAction.identifier = ActionConstants.WAKE_IDENTIFIER
        wakeAction.isDestructive = false
        wakeAction.title = ActionConstants.WAKE_TILE
        wakeAction.activationMode = .foreground
        wakeAction.isAuthenticationRequired = false
        return wakeAction
    }
    
    static func getSnoozeAction() -> UIMutableUserNotificationAction{
        let snoozeAction = UIMutableUserNotificationAction()
        snoozeAction.identifier = ActionConstants.SNOOZE_IDENTIFIER
        snoozeAction.isDestructive = false
        snoozeAction.title = ActionConstants.SNOOZE_TITLE
        snoozeAction.activationMode = .background
        snoozeAction.isAuthenticationRequired = false
        return snoozeAction
    }
    
    
    /*
     Grabs the notificationm and changes the soundName to be the sound name of the user
     */
    static func setNotificationFromFileSystem(){
        Notifications.changeDefaultSong("alarmSound.caf")
    }
    
    static func changeDefaultSong(_ songName : String){
        let notifications = UIApplication.shared.scheduledLocalNotifications
        if notifications?.count > 0 {
            for notif in notifications!{
                print("checking")
                if notif.category! == ActionConstants.ALARM_GOES_OFF_IDENTIFER{
                    //Try cancel all notifications...
                    UIApplication.shared.cancelAllLocalNotifications()
                    notif.soundName = songName
                    UIApplication.shared.scheduleLocalNotification(notif)
                }
            }
        }
    }
}
