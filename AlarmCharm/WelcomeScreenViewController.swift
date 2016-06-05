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
        } else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedBefore")
        }
    }
    
    static func storeAlarmInfo(user: String,  hasBeenSet: Bool, wakeUpMessage: String, friendWhoSetAlarm: String){
        if hasBeenSet{ //By a friend
            UserDefaults.userAlarmBeenSet(true)
            let db = Database()
            db.downloadFileToLocal(forUser: user) { wasDownloadedToLocal in
                if wasDownloadedToLocal{
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
            let db = Database()
            print(UserDefaults.hasAlarmBeenSet())
            if UserDefaults.getAlarmDate() != nil{
                if !UserDefaults.hasAlarmBeenSet(){ //If the user alarm hasn't been set by a friend we want to check for it
                    db.hasUserAlarmBeenSet(forUser: user, completionHandler: WelcomeScreenViewController.storeAlarmInfo)
                }
            }
        }
    }
    
    @IBOutlet weak var usernameTextBox: UITextField!
    @IBOutlet weak var textBox: UITextField!
    private var ref = FIRDatabaseReference.init()
    @IBOutlet weak var errorLabel: UILabel!
    
    
    @IBAction func enterButtonPressed() {
        if let username = usernameTextBox.text {
            if username.characters.count < 5 {
                errorLabel.text = "Error: Usernames must be at least 5 characters"
                return
            }
        }
        if let phonenumber = textBox.text {
            if phonenumber.characters.count != 10 {
                errorLabel.text = "Error: Please enter a valid phone number"
                return
            }
            remoteDB.userInDatabase(phonenumber) { alreadyInDB in
                if alreadyInDB {
                    self.errorLabel.text = "Error: Phone number has already been used"
                } else {
                    self.performSegueWithIdentifier("StorePhoneNumber", sender: nil)
                }
            }
        }
    }
    
    //If the user doesn't enter a phone number this will crash LOL
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StorePhoneNumber" {
            print("SEGUE!!!!")
            let phoneNumber = textBox.text!
            let username = usernameTextBox.text!
            
            NSUserDefaults.standardUserDefaults().setValue(phoneNumber, forKey: "PhoneNumber")
            NSUserDefaults.standardUserDefaults().setValue(username, forKey: "Username")
            remoteDB.addNewUserToDB(phoneNumber)
            
        }
    }
}
