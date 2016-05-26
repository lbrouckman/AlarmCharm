//
//  SetAlarmController.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 5/13/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit
import Firebase

class SetAlarmController: UIViewController {
    
    //private var ref = FIRDatabaseReference.init()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    //We rely on previous view controller to set if we have a previous date.
    var previousDate : NSDate?
    
    @IBAction func removeAlarm() {
        //Remove from icloud as well as userDefaults
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        NSUserDefaults.standardUserDefaults().removeObjectForKey(Constants.USER_ALARM_NOTIFICATION_USER_DEFAULTS_KEY)
    }
    
    
    @IBAction func setAlarm() {
        // Still need to look to see if time should be today or tomorrow
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let date = datePicker.date
        
        var alarmDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(Constants.USER_ALARM_NOTIFICATION_USER_DEFAULTS_KEY) ?? Dictionary()
        
        alarmDictionary[Constants.USER_KEY_TO_GET_ALARM_TIME] = datePicker.date
        
        NSUserDefaults.standardUserDefaults().setObject(alarmDictionary, forKey: Constants.USER_ALARM_NOTIFICATION_USER_DEFAULTS_KEY)
        
        //Set this alarm time (as a unix timestamp) to be the user's alarm time on the server 
        if let userId = NSUserDefaults.standardUserDefaults().valueForKey("PhoneNumber") as? String {
            let timestamp = date.timeIntervalSince1970
            let ref = FIRDatabase.database().reference()
            let usersRef = ref.child("users")
            let currUserRef = usersRef.child(userId)
            let newTime = ["AlarmTime": timestamp]
            currUserRef.updateChildValues(newTime)
        }
        

        
        createAndAddNotification(date)
        
        //We will need to create and store the user's alarm in NsUser Defaults as a local notification
        // When someone else set's their alarm, we will just go and change either the noise or their action?
        
    }
    
    
    
    
    private func createAndAddNotification(date: NSDate){
        
        let notification = UILocalNotification()
        notification.alertBody = "Friend wakes you up" // message user sees
        notification.alertAction = "slide"
        //maybe we have to set its action to open or something
        notification.category = Constants.WAKE_UP_CATEGORY
        // In did finish with launching this will tell us that the user's alarm went off
        notification.fireDate =  datePicker.date //Date to wake up with
        
        var alarmDefaultDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(Constants.USER_ALARM_DEFAULT)
        print(alarmDefaultDict)
        if let songName = alarmDefaultDict?[Constants.USER_KEY_TO_GET_SONG_DEFAULT] as? String{
            let songNameFormatted = songName + ".wav"
            print(songNameFormatted)
            print("here")
            notification.soundName = songNameFormatted
        }else{
            notification.soundName = UILocalNotificationDefaultSoundName
        }
        notification.userInfo = ["AlarmId": Constants.User_Alarm_ID ] // assign a unique identifier to the notification so that we can retrieve it later
        //CANCEL ALL PREVIOUS NOTIFICATIONS BECAUSE USER HAS CHANGED THEIR ALARM TIME
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        //Set new notification
        
        print("Made and set notification")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if previousDate != nil{
            datePicker.date = previousDate!
        }
        
        datePicker.datePickerMode = UIDatePickerMode.Time
        //set to previous time selected pass this in during the segue
        
    }
}
