//
//  Notifications.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/28/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//
// Alexander Carlisle

import UserNotifications
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
        static let DOWNLOAD_CATEGORY = "download category"
        static let DOWNLOAD_ACTION = "download action"
    }
    
    //Notification that tells user someone set their alarm
    static func addFriendSetAlarmNotification(_ friendName: String){
        let notification = UILocalNotification()
        notification.alertBody = friendName + " has set your alarm!"
        notification.category = ActionConstants.FRIENDS_SETS_ALARM_CATEGORY
        notification.fireDate = Date(timeIntervalSinceNow: 1)
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    @available(iOS 10.0, *)
    static func removeAlarmNotification(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    
    @available(iOS 10, *)
    static func AddAlarmNotification10(at date: Date, title: String, body: String, songName: String) {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound(named: songName)
        content.categoryIdentifier = ActionConstants.ALARM_GOES_OFF_IDENTIFER
        
        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
    
    //Wake up notification
    static func AddAlarmNotification9(at date: Date, title: String, body: String, songName: String){
        let notification = UILocalNotification()
        notification.alertBody = body
        notification.alertAction = "slide"
        notification.category = ActionConstants.ALARM_GOES_OFF_IDENTIFER
        notification.fireDate =  date
        //Setting the sound to be the user's default sound preference
        notification.soundName =  songName
        
        //CANCEL ALL PREVIOUS NOTIFICATIONS BECAUSE USER HAS CHANGED THEIR ALARM TIME
        UIApplication.shared.cancelAllLocalNotifications()
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    @available(iOS 10, *)
    static func setNoticationsSettings10(){
        let friendSetAlarmCategory = UNNotificationCategory(identifier: ActionConstants.FRIENDS_SETS_ALARM_CATEGORY, actions: [], intentIdentifiers: [], options: [])
        //Snooze
        let snoozeAction = UNNotificationAction(identifier: ActionConstants.SNOOZE_IDENTIFIER, title: "Snooze", options: [])
        let wakeAction = UNNotificationAction(identifier: ActionConstants.WAKE_IDENTIFIER, title: "See Alarm", options: [UNNotificationActionOptions.foreground])
        let alarmGoesOffCategory = UNNotificationCategory(identifier: ActionConstants.ALARM_GOES_OFF_IDENTIFER, actions: [wakeAction, snoozeAction], intentIdentifiers: [], options: [])
        
        let downloadAction =  UNNotificationAction(identifier: ActionConstants.DOWNLOAD_ACTION, title: "Download alarm", options: [UNNotificationActionOptions.foreground])
        let downloadAlarmCategory = UNNotificationCategory(identifier: ActionConstants.DOWNLOAD_CATEGORY, actions: [downloadAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([friendSetAlarmCategory, alarmGoesOffCategory, downloadAlarmCategory])
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
        if #available(iOS 10, *){
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            Notifications.AddAlarmNotification10(at: UserDefaults.getAlarmDate()!, title: "Wake up from: " + UserDefaults.getFriendWhoSetAlarm(), body: UserDefaults.getWakeUpMessage(), songName: "alarmSound.caf")
        }
        else{
            Notifications.AddAlarmNotification9(at: UserDefaults.getAlarmDate()!, title: "Wake up from: " + UserDefaults.getFriendWhoSetAlarm(), body: UserDefaults.getWakeUpMessage(), songName: UserDefaults.getDefaultSongName() + ".wav")
        }
    }
    
    static func changeDefaultNotificationSound(_ songName : String){
        Notifications.AddAlarmNotification9(at: UserDefaults.getAlarmDate()!, title: "Wake up", body: "You charmed yourself", songName: UserDefaults.getDefaultSongName() + ".wav")
    }
}
