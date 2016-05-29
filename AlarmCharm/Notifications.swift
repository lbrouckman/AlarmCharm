//
//  Notifications.swift
//  AlarmCharm
//
//  Created by Alexander Carlisle on 5/28/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit
class Notifications{
    
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
    
    static func UpdateNotification(fileNameOfSound: String, fileNameOfImage: String){
        
        
    }
    static func CancelNotification(){
        
    }
    
    
    
}