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
        self.navigationController?.navigationBar.barTintColor = Colors.offyellow
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.plum]
        self.navigationController?.navigationBar.tintColor = Colors.plum
        tableView.backgroundColor = Colors.offwhite
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setLabels()
    }
    
    private func setLabels() {
        var alarmTime: String? = nil
        let date = UserDefaults.getAlarmDate()
        if date != nil{
            let formatter = NSDateFormatter()
            formatter.timeStyle = .ShortStyle
            alarmTime = formatter.stringFromDate(date!)
        }
        else {
            alarmTime = "Not Set"
        }
        
        timeCell.textLabel?.text = alarmTime!
        
        if let defaultMessage = NSUserDefaults.standardUserDefaults().valueForKey("User Default Message") as? String {
            messageCell.textLabel?.text = "'" + defaultMessage + "'"
        } else {
            messageCell.textLabel?.text = "Set your message for friends..."
        }
        
        soundCell.textLabel?.text = UserDefaults.getDefaultSongName()
    }
}
