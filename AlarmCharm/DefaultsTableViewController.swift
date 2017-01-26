//
//  DefaultsTableViewController.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/30/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//
// Laura Brouckman

import UIKit

class DefaultsTableViewController: UITableViewController {

    @IBOutlet weak var timeCell: UITableViewCell!
    @IBOutlet weak var messageCell: UITableViewCell!
    @IBOutlet weak var soundCell: UITableViewCell!
    
    @IBOutlet weak var confirmCell: UITableViewCell!
    //Set the tab bar and navigation controller styles to match the color scheme (since this is one of the 2 root navigation controllers)
    override func viewDidLoad() {
        super.viewDidLoad()
                self.navigationController?.navigationBar.barTintColor = Colors.offyellow
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.plum]
        self.navigationController?.navigationBar.tintColor = Colors.plum
        tableView.backgroundColor = Colors.offwhite
        self.tabBarController?.tabBar.tintColor = Colors.plum
        self.tabBarController?.tabBar.barTintColor = Colors.offyellow
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("state is ", UserDefaults.getState())
        confirmCell.backgroundColor = Colors.cherry
        confirmCell.textLabel?.textColor = Colors.offwhite
        if UserDefaults.getState() != State.friendHasSetAlarm{
            confirmCell.isHidden = true
        }else{
            confirmCell.textLabel?.text = UserDefaults.getFriendWhoSetAlarm() + "wants to charm your alarm..."
            confirmCell.isHidden = false
        }
        setLabels()
    }
    
    //Set the labels to be set to the user's default values for time/sound/message
    fileprivate func setLabels() {
        var alarmTime: String? = nil
        let date = UserDefaults.getAlarmDate()
        if date != nil{
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            alarmTime = formatter.string(from: date! as Date)
            if UserDefaults.hasAlarmBeenSet(){
                let friendName = UserDefaults.getFriendWhoSetAlarm()
                let suffix = " set by " + friendName
                alarmTime = alarmTime! + suffix
                
            }
        }
        else {
            alarmTime = "Not Set"
        }
        
        timeCell.textLabel?.text = alarmTime!
        if let defaultMessage = Foundation.UserDefaults.standard.value(forKey: "User Default Message") as? String {
            messageCell.textLabel?.text = "'" + defaultMessage + "'"
        } else {
            messageCell.textLabel?.text = "Set your message for friends..."
        }
        
        soundCell.textLabel?.text = UserDefaults.getDefaultSongName()
    }
}
