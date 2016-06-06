//
//  SetAlarmController.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/13/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//

import UIKit
import Firebase

/* This controller has a date picker that lets the user choose what time they want their alarm to be set to. They can then set/remove their 
 alarm and it will be changed in the remote database and in NSUserdefaults */
class SetAlarmController: UIViewController {
        
    @IBOutlet weak var datePicker: UIDatePicker!
    //We rely on previous view controller to set if we have a previous date.
    var previousDate : NSDate?
    private var remoteDB = Database()
    
    @IBAction func removeAlarm() {
        //Make alarm needs to be set false in database
        let userId = NSUserDefaults.standardUserDefaults().valueForKey("PhoneNumber") as? String
        let x = userId! //It was crashing without this, maybe later we can change but im confuesd
        remoteDB.userNeedsAlarmToBeSet(forUser: x, toBeSet: false)
        remoteDB.userInProcessOfBeingSet(forUser: x, inProcess: false)
        
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        UserDefaults.clearAlarmDate()
    }
    
    
    @IBAction func setAlarm() {
        let date = ensureDateIsTomorrow(datePicker.date)
        UserDefaults.setAlarmDate(date)
        remoteDB.addAlarmTimeToDatabase(date)
        Notifications.AddAlarmNotification(date)
        }
    
    //If they set an alarm for earlier than the current time, then set that alarm to go off the following day
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
        datePicker.backgroundColor = Colors.offwhite
        datePicker.setValue(Colors.cherry, forKeyPath: "textColor")
        
        if previousDate != nil{
            datePicker.date = previousDate!
        }
        
        datePicker.datePickerMode = UIDatePickerMode.Time        
    }
}
