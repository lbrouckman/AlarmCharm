//
//  SetAlarmController.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 5/13/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit

class SetAlarmController: UIViewController {
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    //We rely on previous view controller to set if we have a previous date
    var previousDate : NSDate?
    
    @IBAction func removeAlarm() {
    }
    
    @IBAction func setAlarm() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        print( dateFormatter.stringFromDate(datePicker.date))
        
        //we can store the .date and then when we set it, if we ever need to just print we use the date formatter
        // If we need to set the default date picker time as in view did load, we set its .date to our stored .date
        //Check the days as well, to always set alarm to later than current time.
        
        
        
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
