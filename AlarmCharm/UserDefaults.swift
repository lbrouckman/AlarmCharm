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
    
    static func addWakeUpMessage(_ wakeUpMessage: String){
        Foundation.UserDefaults.standard.setValue(wakeUpMessage, forKey: messageKey)
    }
    static func storeFriendWhoSetAlarm(_ friend: String){
        Foundation.UserDefaults.standard.setValue(friend, forKey: friendKey)
    }
    static func getFriendWhoSetAlarm() -> String?{
        return Foundation.UserDefaults.standard.value(forKey: friendKey) as? String
    }
    
    static func userAlarmBeenSet(_ hasBeenSet: Bool){
        Foundation.UserDefaults.standard.setValue(hasBeenSet, forKey: setKey)
    }
    static func hasAlarmBeenSet() -> Bool{
        let hasBeenSet =  Foundation.UserDefaults.standard.value(forKey: setKey) as? Bool
        if hasBeenSet != nil { return hasBeenSet!}
        else { return false }
    }
    
    static func getWakeUpMessage() -> String?{
        return Foundation.UserDefaults.standard.value(forKey: messageKey) as? String
    }
    static func setDefaultSongName(_ songName: String){
        Foundation.UserDefaults.standard.setValue(songName, forKey: defaultSongKey)
    }
    static func getDefaultSongName() -> String{
        if let defaultSong =  Foundation.UserDefaults.standard.value(forKey: defaultSongKey) as? String{
            return defaultSong
        }
        return "Soft Piano"
    }
    static func setAlarmDate(_ date: Date){
        Foundation.UserDefaults.standard.setValue(date, forKey: dateKey)
    }
    static func getAlarmDate() -> Date?{
        return Foundation.UserDefaults.standard.value(forKey: dateKey) as? Date
    }
    static func hasRegistered() -> Bool{
        if  Foundation.UserDefaults.standard.value(forKey: hasRegisteredKey) != nil{
            return true
        }
        return false
    }
    static func userJustRegistered(){
        Foundation.UserDefaults.standard.setValue(true, forKey: hasRegisteredKey)
    }
    
    //THis function ensures that if a user cancels out a notification, we set their has been set to false
    static func ensureAlarmTime(){
        if let userDate = UserDefaults.getAlarmDate(){
            print("userdat not nil")
            let bufferedDate = userDate.addingTimeInterval(120)
            let currentDay = Date()
            print("current date is", currentDay)
            print("buffered date is ", bufferedDate)
            if currentDay.timeIntervalSinceReferenceDate > bufferedDate.timeIntervalSinceReferenceDate{
                print("Alarm should have already gone off by now")
                Foundation.UserDefaults.standard.setValue(nil, forKey: dateKey)
                UserDefaults.userAlarmBeenSet(false)
            }
        }
        else{
            UserDefaults.userAlarmBeenSet(false)
        }
    }
    
    static func clearAlarmDate(){
        
        Foundation.UserDefaults.standard.removeObject(forKey: dateKey)
        Foundation.UserDefaults.standard.setValue(false, forKey: setKey)
    }
    
    static func hasImage(_ imageAdded: Bool) {
        Foundation.UserDefaults.standard.setValue(imageAdded, forKey: hasImageKey)
    }
    
    static func hasImage() -> Bool {
        if let x = Foundation.UserDefaults.standard.value(forKey: hasImageKey) as? Bool {
            return x
        } else {
            return false
        }
    }
    
}
