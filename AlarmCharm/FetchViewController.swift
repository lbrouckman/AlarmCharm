//
//  FetchViewController.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 6/5/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//
// Laura Brouckman

import UIKit

/* This class holds the functionality for fetching alarms from the remote database in the background. It's fetch function gets called every 5-ish minutes
 if the user's alarm hasn't been set by a friend already. It also gets called everytime the app opens.  
 Fetch will check the remote database to see whether the alarm has been set, and if so it downloads the image/audio to the local file system and store the message
 and who set it in user defaults.
 It also sets the notification to have the correct sound and information.
 */
class FetchViewController: UIViewController {
    
    //Maybe add a finish fetched parameter on user defaults because it could get interrupted halfway through these fetches
    static func storeAlarmInfo(user: String,  hasBeenSet: Bool, wakeUpMessage: String, friendWhoSetAlarm: String){
        if hasBeenSet{ //By a friend
            let db = Database()
            db.downloadFileToLocal(forUser: user, fileType: "audio_file") { wasDownloadedToLocal in
                if wasDownloadedToLocal{
                    Notifications.setNotificationFromFileSystem()
                    UserDefaults.addWakeUpMessage(wakeUpMessage)
                    UserDefaults.storeFriendWhoSetAlarm(friendWhoSetAlarm)
                    Notifications.addFriendSetAlarmNotification(friendWhoSetAlarm)
                    db.downloadFileToLocal(forUser: user, fileType: "image_file") { wasSuccessful in
                        UserDefaults.userAlarmBeenSet(true)
                        if wasSuccessful {
                            UserDefaults.hasImage(true)
                        } else {
                            UserDefaults.hasImage(false)
                        }
                    }
                }
            }
            
        }
    }
    
    static func fetch(completion: () -> Void) {
        if let user = NSUserDefaults.standardUserDefaults().valueForKey("PhoneNumber") as? String {
            let db = Database()
            if UserDefaults.getAlarmDate() != nil{
                if !UserDefaults.hasAlarmBeenSet(){ //If the user alarm hasn't been set by a friend we want to check for it
                    db.hasUserAlarmBeenSet(forUser: user, completionHandler: FetchViewController.storeAlarmInfo)
                }
            }
        }
    }

}
