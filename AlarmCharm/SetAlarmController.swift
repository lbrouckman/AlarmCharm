//
//  SetAlarmController.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/13/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
// 
// Alexander Carlisle

import UIKit
import Firebase

/* This controller has a date picker that lets the user choose what time they want their alarm to be set to. They can then set/remove their 
 alarm and it will be changed in the remote database and in NSUserdefaults */
class SetAlarmController: UIViewController {
        
    @IBOutlet weak var datePicker: UIDatePicker!
    //We rely on previous view controller to set if we have a previous date.
    var previousDate : Date?
    fileprivate var remoteDB = Database()
    
    @IBAction func removeAlarm() {
        //Make alarm needs to be set false in database
        let userId = Foundation.UserDefaults.standard.value(forKey: "PhoneNumber") as? String
        let x = userId! //It was crashing without this, maybe later we can change but im confuesd
        remoteDB.userNeedsAlarmToBeSet(forUser: x, toBeSet: false)
        remoteDB.userInProcessOfBeingSet(forUser: x, inProcess: false)
        
        
        UIApplication.shared.cancelAllLocalNotifications()
        UserDefaults.clearAlarmDate()
    }
    
    
    @IBAction func setAlarm() {
        var date = ensureDateIsTomorrow(datePicker.date)
        UserDefaults.setAlarmDate(date)
        remoteDB.addAlarmTimeToDatabase(date)
        Notifications.AddAlarmNotification(date)
        print(date)
        print("is the date")
        print(UserDefaults.getAlarmDate())
        }
    
    //If they set an alarm for earlier than the current time, then set that alarm to go off the following day
    fileprivate func ensureDateIsTomorrow(_ date: Date) -> Date{
        let currentDay = Date()
        var newDate = date
        if (currentDay as NSDate).earlierDate(date) == date {
            newDate = date.addingTimeInterval(60*60*24)
        }
        return newDate
        //if the set date is earlier than current date, return less date + a day.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.backgroundColor = Colors.offwhite
        datePicker.setValue(Colors.cherry, forKeyPath: "textColor")
        
        if previousDate != nil{
            datePicker.date = previousDate!
        }
        
        datePicker.datePickerMode = UIDatePickerMode.time        
    }
}
