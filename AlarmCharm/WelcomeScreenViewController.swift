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
    
    static func storeAlarmInfo(user: String,  hasBeenSet: Bool, justSet: Bool, wakeUpMessage: String, friendWhoSetAlarm: String){
        print("call back called")
        if hasBeenSet{
            if justSet{
                let db = Database()

                db.downloadFileToLocal(forUser: user) { wasDownloadedToLocal in
                    if wasDownloadedToLocal{ Notifications.setNotificationFromFileSystem()}  //This means the file has been downloaded and we can now set the notification sound
                    UserDefaults.addWakeUpMessage(wakeUpMessage)
                    UserDefaults.storeFriendWhoSetAlarm(friendWhoSetAlarm)
                    print("about to set Notification")
                    Notifications.addFriendSetAlarmNotification(friendWhoSetAlarm)
                }
            }

            }
        }
    
    static func fetch(completion: () -> Void) {
        if let user = NSUserDefaults.standardUserDefaults().valueForKey("PhoneNumber") as? String {
            print("about to call hasUserAlarmBeenSet")
            let db = Database()
            db.hasUserAlarmBeenSet(forUser: user, completionHandler: WelcomeScreenViewController.storeAlarmInfo)

//            remoteDB.hasUserAlarmBeenSet(forUser: user, completionHandler: self.storeAlarmInfo)
            }
            //if it has been set, then we want to download the file to local, and set the notification to have that sound
            //Need to set notification sound to be local as well
            //Set the wake up message in user defaults
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
            let newUser = ["alarm_time": 0, "image_file": "", "audio_file": "", "wakeup_message" : "", "user_message" : "", "need_friend_to_set" : false, "just_set" : false, "in_process_of_being_set" : false, "friend_who_set_alarm" : ""]
            let newUserRef = usersRef.child(phoneNumber)
            newUserRef.setValue(newUser)
        }
    }
}
