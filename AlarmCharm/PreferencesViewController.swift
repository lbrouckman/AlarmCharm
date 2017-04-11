//
//  PreferencesViewController.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 2/2/17.
//  Copyright © 2017 Laura Brouckman. All rights reserved.
//

import UIKit

class PreferencesViewController: UIViewController {
    
    @IBOutlet weak var messageContentLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var soundNameLabel: UILabel!
    @IBOutlet weak var soundLabel: UILabel!
    @IBOutlet weak var addAlarmButton: UIButton!
    @IBOutlet weak var alarmTimeLabel: UILabel!
    @IBOutlet weak var editAlarmButton: UIButton!
    @IBOutlet weak var removeAlarmButton: UIButton!
    fileprivate var remoteDB = Database()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Colors.lightblue
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.darkblue]
        self.navigationController?.navigationBar.tintColor = Colors.darkblue
        self.tabBarController?.tabBar.tintColor = Colors.darkblue
        self.tabBarController?.tabBar.barTintColor = Colors.lightblue
        
        self.addAlarmButton.backgroundColor = Colors.white
        self.addAlarmButton.layer.cornerRadius = 6.0
        self.addAlarmButton.layer.borderWidth = 1.0
        self.addAlarmButton.layer.borderColor = Colors.midblue.cgColor
        self.addAlarmButton.layer.shadowColor = Colors.midblue.cgColor
        self.addAlarmButton.layer.shadowOpacity = 0.9
        self.addAlarmButton.layer.shadowRadius = 2.0
        self.addAlarmButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        editAlarmButton.backgroundColor = Colors.white
        editAlarmButton.layer.cornerRadius = 6
        editAlarmButton.layer.borderWidth = 1
        editAlarmButton.layer.borderColor = Colors.midblue.cgColor
        self.editAlarmButton.layer.shadowColor = Colors.midblue.cgColor
        self.editAlarmButton.layer.shadowOpacity = 0.9
        self.editAlarmButton.layer.shadowRadius = 2.0
        self.editAlarmButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        removeAlarmButton.backgroundColor = Colors.white
        removeAlarmButton.layer.cornerRadius = 6
        removeAlarmButton.layer.borderWidth = 1
        removeAlarmButton.layer.borderColor = Colors.midblue.cgColor
        self.removeAlarmButton.layer.shadowColor = Colors.midblue.cgColor
        self.removeAlarmButton.layer.shadowOpacity = 0.9
        self.removeAlarmButton.layer.shadowRadius = 2.0
        self.removeAlarmButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setLabels()
    }
    
    fileprivate func setLabels() {
        var alarmTime: String? = nil
        if let date = UserDefaults.getAlarmDate() {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            alarmTime = formatter.string(from: date as Date)
            soundNameLabel.text = UserDefaults.getDefaultSongName()
            if let message = Foundation.UserDefaults.standard.value(forKey: "User Default Message") as? String, message != "" {
                messageContentLabel.text = message
            } else {
                messageContentLabel.text = "No message set"
            }
            
            editAlarmButton.isHidden = false
            removeAlarmButton.isHidden = false
            addAlarmButton.isHidden = true
            soundLabel.isHidden = false
            soundNameLabel.isHidden = false
            messageLabel.isHidden = false
            messageContentLabel.isHidden = false
        } else {
            alarmTime = "No alarm set"
            editAlarmButton.isHidden = true
            removeAlarmButton.isHidden = true
            addAlarmButton.isHidden = false
            soundLabel.isHidden = true
            soundNameLabel.isHidden = true
            messageLabel.isHidden = true
            messageContentLabel.isHidden = true
        }
        alarmTimeLabel.text = alarmTime
    }
    
    @IBAction func removeAlarm() {
        let userId = Foundation.UserDefaults.standard.value(forKey: "PhoneNumber") as? String
        let x = userId!
        remoteDB.userNeedsAlarmToBeSet(forUser: x, toBeSet: false)
        if #available(iOS 10, *)    {
            Notifications.removeAlarmNotification()
        }
        UIApplication.shared.cancelAllLocalNotifications()
        UserDefaults.clearAlarmDate()
        UserDefaults.userAlarmBeenSet(false)
        UserDefaults.storeFriendWhoSetAlarm("")
        UserDefaults.setState(State.noAlarmSet)
        setLabels()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "createAlarm"{
                if let setvc = segue.destination as? SetPreferencesViewController {
                    if let date = UserDefaults.getAlarmDate() {
                        setvc.previousDate = date
                    }
                }
            }
        }
    }
 

}
