//
//  UserDefaults.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/31/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//
// Alexander Carlisle

import Foundation

/* This class has all the user defaults functionality for interacting with NSUserDefaults.
 User defaults stores the current alarm time, whether or not a friend has set the alarm, the wake up message, who set the alarm,
 whether or not an image has been set, the default sound.
 */

class UserDefaults{
    
    static var messageKey       =   "messageKey"
    static var friendKey        =   "friendKey"
    static var defaultSongKey   =   "defaultKey"
    static var dateKey          =   "dateKey"
    static var setKey           =   "setKey"
    static var hasImageKey      =   "imageKey"
    static var hasRegisteredKey    =   "registeredKey"
    
    static func addWakeUpMessage(wakeUpMessage: String){
        NSUserDefaults.standardUserDefaults().setValue(wakeUpMessage, forKey: messageKey)
    }
    static func storeFriendWhoSetAlarm(friend: String){
        NSUserDefaults.standardUserDefaults().setValue(friend, forKey: friendKey)
    }
    static func getFriendWhoSetAlarm() -> String?{
        return NSUserDefaults.standardUserDefaults().valueForKey(friendKey) as? String
    }
    
    static func userAlarmBeenSet(hasBeenSet: Bool){
        NSUserDefaults.standardUserDefaults().setValue(hasBeenSet, forKey: setKey)
    }
    static func hasAlarmBeenSet() -> Bool{
        let hasBeenSet =  NSUserDefaults.standardUserDefaults().valueForKey(setKey) as? Bool
        if hasBeenSet != nil { return hasBeenSet!}
        else { return false }
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
        return "Soft Piano"
    }
    static func setAlarmDate(date: NSDate){
        NSUserDefaults.standardUserDefaults().setValue(date, forKey: dateKey)
    }
    static func getAlarmDate() -> NSDate?{
        return NSUserDefaults.standardUserDefaults().valueForKey(dateKey) as? NSDate
    }
    static func hasRegistered() -> Bool{
        if  NSUserDefaults.standardUserDefaults().valueForKey(hasRegisteredKey) != nil{
            return true
        }
        return false
    }
    static func userJustRegistered(){
        NSUserDefaults.standardUserDefaults().setValue(true, forKey: hasRegisteredKey)
    }
    
    //THis function ensures that if a user cancels out a notification, we set their has been set to false
    static func ensureAlarmTime(){
        if let userDate = UserDefaults.getAlarmDate(){
            print("userdat not nil")
            let bufferedDate = userDate.dateByAddingTimeInterval(120)
            let currentDay = NSDate()
            print("current date is", currentDay)
            print("buffered date is ", bufferedDate)
            if currentDay.timeIntervalSinceReferenceDate > bufferedDate.timeIntervalSinceReferenceDate{
                print("Alarm should have already gone off by now")
                NSUserDefaults.standardUserDefaults().setValue(nil, forKey: dateKey)
                UserDefaults.userAlarmBeenSet(false)
            }
        }
        else{
            UserDefaults.userAlarmBeenSet(false)
        }
    }
    
    static func clearAlarmDate(){
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(dateKey)
        NSUserDefaults.standardUserDefaults().setValue(false, forKey: setKey)
    }
    
    static func hasImage(imageAdded: Bool) {
        NSUserDefaults.standardUserDefaults().setValue(imageAdded, forKey: hasImageKey)
    }
    
    static func hasImage() -> Bool {
        if let x = NSUserDefaults.standardUserDefaults().valueForKey(hasImageKey) as? Bool {
            return x
        } else {
            return false
        }
    }
    
}