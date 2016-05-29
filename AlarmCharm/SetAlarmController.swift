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
        
    @IBOutlet weak var datePicker: UIDatePicker!
    //We rely on previous view controller to set if we have a previous date.
    var previousDate : NSDate?
    
    @IBAction func removeAlarm() {
        //Remove from icloud as well as userDefaults
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        NSUserDefaults.standardUserDefaults().removeObjectForKey(Constants.USER_ALARM_NOTIFICATION_USER_DEFAULTS_KEY)
    }
    
    
    @IBAction func setAlarm() {
        let date = ensureDateIsTomorrow(datePicker.date)
        var alarmDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(Constants.USER_ALARM_NOTIFICATION_USER_DEFAULTS_KEY) ?? Dictionary()
        
        alarmDictionary[Constants.USER_KEY_TO_GET_ALARM_TIME] = datePicker.date
        
        NSUserDefaults.standardUserDefaults().setObject(alarmDictionary, forKey: Constants.USER_ALARM_NOTIFICATION_USER_DEFAULTS_KEY)
        
        //This function should be in DataBase
        //Set this alarm time (as a unix timestamp) to be the user's alarm time on the server
        Database.addAlarmTimeToDatabase(date)
   
        Notifications.AddAlarmNotification(date)
        //We will need to create and store the user's alarm in NsUser Defaults as a local notification
        // When someone else set's their alarm, we will just go and change either the noise or their action?
        //This is just code to ensure user's db alarm gets saved locally, wouldnt go here
        var db = Database()
        let userId = NSUserDefaults.standardUserDefaults().valueForKey("PhoneNumber") as? String
        db.downloadFileToLocal(forUser: userId!)
    }
    
    private func ensureDateIsTomorrow(date: NSDate) -> NSDate{
        let currentDay = NSDate()
        if currentDay.earlierDate(date) == date {
            date.dateByAddingTimeInterval(60*60*24)
        }
        return date
        //if the set date is earlier than current date, return less date + a day.
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
