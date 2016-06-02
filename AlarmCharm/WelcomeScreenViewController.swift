//
//  WelcomeScreenViewController.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 5/24/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//
//HELLO CARLISELEGERGERLGMERLKVMERLM

import UIKit
import Firebase
import FirebaseDatabase
class WelcomeScreenViewController: UIViewController {
    
    private var remoteDB = Database()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let launchedBefore = NSUserDefaults.standardUserDefaults().boolForKey("launchedBefore")
        if launchedBefore  {
            self.performSegueWithIdentifier("ShowMain", sender: self)
        }
        else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedBefore")
        }
    }
    
    static func storeAlarmInfo(user: String,  hasBeenSet: Bool, wakeUpMessage: String, friendWhoSetAlarm: String){
        if hasBeenSet{ //By a friend
            UserDefaults.userAlarmBeenSet(true)
            let db = Database()
            db.downloadFileToLocal(forUser: user) { wasDownloadedToLocal in
                if wasDownloadedToLocal{
                    print("about to change sound name")
                    Notifications.setNotificationFromFileSystem()
                    UserDefaults.addWakeUpMessage(wakeUpMessage)
                    UserDefaults.storeFriendWhoSetAlarm(friendWhoSetAlarm)
                    Notifications.addFriendSetAlarmNotification(friendWhoSetAlarm)
                    //Change it to be not just set anymore
                }  //This means the file has been downloaded and we can now set the notification sound
                
            }
            
        }
    }
    
    static func fetch(completion: () -> Void) {
        if let user = NSUserDefaults.standardUserDefaults().valueForKey("PhoneNumber") as? String {
            print("about to call hasUserAlarmBeenSet")
            let db = Database()
            print("LOOK HERE")
            print(UserDefaults.hasAlarmBeenSet())
            if UserDefaults.getAlarmDate() != nil{
                if !UserDefaults.hasAlarmBeenSet(){ //If the user alarm hasn't been set by a friend we want to check for it
                    db.hasUserAlarmBeenSet(forUser: user, completionHandler: WelcomeScreenViewController.storeAlarmInfo)
                }
            }
        }
    }
    
    @IBOutlet weak var textBox: UITextField!
    private var ref = FIRDatabaseReference.init()
    
    //If the user doesn't enter a phone number this will crash LOL
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StorePhoneNumber" {
            let phoneNumber = textBox.text!
            NSUserDefaults.standardUserDefaults().setValue(phoneNumber, forKey: "PhoneNumber")
            ref = FIRDatabase.database().reference()
            let usersRef = ref.child("users");
            let newUser = ["alarm_time": 0, "image_file": "", "audio_file": "", "wakeup_message" : "", "user_message" : "", "need_friend_to_set" : false, "in_process_of_being_set" : false, "friend_who_set_alarm" : ""]
            let newUserRef = usersRef.child(phoneNumber)
            newUserRef.setValue(newUser)
        }
    }
}
