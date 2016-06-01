//
//  DefaultsTableViewController.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 5/30/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit

class DefaultsTableViewController: UITableViewController {

    @IBOutlet weak var timeCell: UITableViewCell!
    @IBOutlet weak var messageCell: UITableViewCell!
    @IBOutlet weak var soundCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setLabels()    }
    
    private func setLabels() {
        var alarmTime: String? = nil
        let alarmDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(Constants.USER_ALARM_NOTIFICATION_USER_DEFAULTS_KEY)
        if let dict = alarmDictionary as? [String: NSDate] {
            if let date = dict[Constants.USER_KEY_TO_GET_ALARM_TIME] {
                let formatter = NSDateFormatter()
                formatter.timeStyle = .ShortStyle
                alarmTime = formatter.stringFromDate(date)
            }
        }
        if alarmTime == nil {
            alarmTime = "Not Set"
        }
        timeCell.textLabel?.text = alarmTime!
        
        if let defaultMessage = NSUserDefaults.standardUserDefaults().valueForKey("User Default Message") as? String {
            messageCell.textLabel?.text = "'" + defaultMessage + "'"
        } else {
            messageCell.textLabel?.text = "Set your message for friends..."
        }

        var soundString: String? = nil
        let defaultSongDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(Constants.USER_ALARM_DEFAULT)
        if let dict = defaultSongDict as? [String: String] {
            if let sound = dict[Constants.USER_KEY_TO_GET_SONG_DEFAULT] {
                soundString = sound
            }
        }
        if soundString == nil {
            soundString = "Choose default sound"
        }
        soundCell.textLabel?.text = soundString
    }
}
