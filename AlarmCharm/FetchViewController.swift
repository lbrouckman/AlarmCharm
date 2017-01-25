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
    static func storeAlarmInfo(_ user: String,  hasBeenSet: Bool, wakeUpMessage: String, friendWhoSetAlarm: String){
        if hasBeenSet{ //By a friend
            let db = Database()
            UserDefaults.addWakeUpMessage(wakeUpMessage)
            UserDefaults.storeFriendWhoSetAlarm(friendWhoSetAlarm)
            // Notifications.addFriendSetAlarmNotification(friendWhoSetAlarm)
            UserDefaults.userAlarmBeenSet(true)
            db.downloadFileToLocal(forUser: user, fileType: "audio_file") { wasDownloadedToLocal in
                if wasDownloadedToLocal{
                    print("was downloaded to local")
                    Notifications.setNotificationFromFileSystem()
                    db.downloadFileToLocal(forUser: user, fileType: "image_file") { wasSuccessful in
                        print("image downloaded as well")
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
    //Go to the database and get all the alarm info left by a friend.
    static func fetch(_ completion: () -> Void) {
        if let user = Foundation.UserDefaults.standard.value(forKey: "PhoneNumber") as? String {
            let db = Database()
            if UserDefaults.getAlarmDate() != nil{
                if UserDefaults.getState() == State.userHasSetAlarm || UserDefaults.getState() == State.friendHasSetAlarm{
                    db.hasUserAlarmBeenSet(forUser: user, completionHandler: FetchViewController.storeAlarmInfo)
                    completion()
                }
//                if !UserDefaults.hasAlarmBeenSet(){ //If the user alarm hasn't been set by a friend we want to check for it
//                    db.hasUserAlarmBeenSet(forUser: user, completionHandler: FetchViewController.storeAlarmInfo)
//                }
            }
        }
    }

}
