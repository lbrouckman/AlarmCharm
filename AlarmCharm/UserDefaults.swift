//
//  UserDefaults.swift
//  AlarmCharm
//
//  Created by Alexander Carlisle on 5/31/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import Foundation

class UserDefaults{
    
    static var messageKey = "messageKey"
    static var friendKey = "friendKey"
    static var defaultSongKey = "defaultKey"
    static var dateKey = "dateKey"
    static func addWakeUpMessage(wakeUpMessage: String){
        NSUserDefaults.standardUserDefaults().setValue(wakeUpMessage, forKey: messageKey)
    }
    static func storeFriendWhoSetAlarm(friend: String){
        NSUserDefaults.standardUserDefaults().setValue(friend, forKey: friendKey)
    }
    static func getFriendWhoSetAlarm() -> String?{
        return NSUserDefaults.standardUserDefaults().valueForKey(friendKey) as? String
    }
    static func getWakeUpMessage() -> String?{
        return NSUserDefaults.standardUserDefaults().valueForKey(messageKey) as? String
    }
    static func setDefaultSongName(songName: String){
        NSUserDefaults.standardUserDefaults().setValue(songName, forKey: defaultSongKey)
    }
    static func getDefaultSongName() -> String{
        if let defaultSong =  NSUserDefaults.standardUserDefaults().valueForKey(defaultSongKey) as? String{
            return defaultSong
        }
        return "Alarm_Soothing_Piano"
    }
    static func setAlarmDate(date: NSDate){
        NSUserDefaults.standardUserDefaults().setValue(date, forKey: dateKey)
    }
    static func getAlarmDate() -> NSDate?{
       return NSUserDefaults.standardUserDefaults().valueForKey(dateKey) as? NSDate
    }
    static func clearAlarmDate(){
        NSUserDefaults.standardUserDefaults().removeObjectForKey(dateKey)

    }

    
}