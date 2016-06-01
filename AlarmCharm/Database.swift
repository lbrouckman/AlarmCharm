//
//  Database.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 5/28/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import Foundation
import Firebase
import AVFoundation

class Database {
    
    private var usersRef = FIRDatabase.database().reference().child("users")
    
    func uploadFileToDatabase(fileURL: NSURL, forUser userID: String) {
        
        let filename = fileURL.lastPathComponent!
        let storage = FIRStorage.storage()
        let gsReference = storage.referenceForURL("gs://project-5208532535641760898.appspot.com")
        let fileRef = gsReference.child(filename)
        
        let _ = fileRef.putFile(fileURL, metadata: nil) { metadata, error in
            if (error != nil) {
                print(error)
            } else {
                let currUserRef = self.usersRef.child(userID)
                let newSound = ["audio_file": filename]
                
                let userNoLongerNeedsToBeSet = ["need_friend_to_set" : false]
                let notInProcess = ["in_process_of_being_set" : false]
                
                currUserRef.updateChildValues(notInProcess)
                currUserRef.updateChildValues(userNoLongerNeedsToBeSet)
                currUserRef.updateChildValues(newSound)
            }
        }
        
    }
    
    // After user sets their message, this function puts their message in the database
   func uploadUserMessageToDatabase(message: String, forUser userID: String){
        let uRef = FIRDatabase.database().reference().child("users")
        let currentUserRef = uRef.child(userID)
        let newMessage = ["user_message" : message]
        currentUserRef.updateChildValues(newMessage)
    }
    
    func uploadWakeUpMessageToDatabase(message: String, forUser userID: String){
        let uRef = FIRDatabase.database().reference().child("users")
        let currentUserRef = uRef.child(userID)
        let newMessage = ["wakeup_message" : message]
        currentUserRef.updateChildValues(newMessage)
    }
    
//    func getWakeUpMessageFromDatabase(forUser userID: String) -> String?{
//        
//    }
    func userNeedsAlarmToBeSet(forUser userID: String , toBeSet: Bool){
        let uRef = FIRDatabase.database().reference().child("users")
        let currentUserRef = uRef.child(userID)
        let needsSetting = ["need_friend_to_set" : toBeSet]
        currentUserRef.updateChildValues(needsSetting)
    }
    
    // then this means that we have already notified the current user.
    // Let's put message, FriendName both in NSUSER Defaults
    //
    func hasUserAlarmBeenSet(forUser userID: String, completionHandler: (user: String, hasBeenSet: Bool, userBeenNotified: Bool, wakeUpMessage: String, friendWhoSetAlarm: String) -> ()){
        usersRef.child(userID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let needFriendToSet = snapshot.value!["need_friend_to_set"] as? Bool where needFriendToSet == false{
                let hasBeenSet = !needFriendToSet
                print("has been set has value", hasBeenSet)
                
                if let justSet = snapshot.value!["just_set"] as? Bool where justSet == true{
                    print("just set has value", justSet)
                    if let wakeUpMessage = snapshot.value!["wakeup_message"] as? String{
                        print("wake up Message: ", wakeUpMessage)
                        if let friendWhoSetAlarm = snapshot.value!["friend_who_set_alarm"] as? String{
                            print("friend who set alarm was : ", friendWhoSetAlarm)
                            completionHandler(user: userID, hasBeenSet: hasBeenSet, userBeenNotified: justSet, wakeUpMessage: wakeUpMessage, friendWhoSetAlarm: friendWhoSetAlarm)
                        }
                    }
                }
            }
            })
        { (error) in
            print(error)
        }
    }

   func addAlarmTimeToDatabase(date: NSDate){
        print("a")
        if let userId = NSUserDefaults.standardUserDefaults().valueForKey("PhoneNumber") as? String {
            print("Here")
            let timestamp = date.timeIntervalSince1970
            let ref = FIRDatabase.database().reference()
            let usersRef = ref.child("users")
            let currUserRef = usersRef.child(userId)
            let newTime = ["alarm_time": timestamp]
            let needsToBeSet = ["need_friend_to_set" : true]
            
            currUserRef.updateChildValues(needsToBeSet)
            currUserRef.updateChildValues(newTime)
        }
    }
     func userInProcessOfBeingSet(forUser userID: String, inProcess : Bool){
        let uRef = FIRDatabase.database().reference().child("users")
        let currentUserRef = uRef.child(userID)
        let process = ["in_process_of_being_set" : inProcess]
        currentUserRef.updateChildValues(process)
    }
    

    func downloadFileToLocal(forUser userID: String, completionHandler: (Bool) -> ()) {
        usersRef.child(userID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let audioFile = snapshot.value!["audio_file"] as? String where audioFile != ""{
                let storage = FIRStorage.storage()
                let gsReference = storage.referenceForURL("gs://project-5208532535641760898.appspot.com")
                let soundRef = gsReference.child(audioFile)
                soundRef.downloadURLWithCompletion { (URL, error) -> Void in
                    if (error != nil) {
                        print(error)
                        completionHandler(false)
                    } else {
                        self.saveToFileSystem(URL!, fileName: Constants.ALARM_SOUND_STORED_FILENAME)
                        print("audio saved to file system")
                        completionHandler(true)
                    }
                }
            }
            })
        { (error) in
            print(error)
        }
    }
    
    /*
     Given the url, it turns url into NSDATA and then saves the file in the libray/sounds folder.
     */
    private func saveToFileSystem(URL : NSURL, fileName: String){
        let songData =  NSData(contentsOfURL: URL)
        let fileManager = NSFileManager.defaultManager()
        
        let libraryPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0]
        let soundsPath = libraryPath + "/Sounds"
        let filePath = soundsPath + "/" + fileName
        do {
            try fileManager.createDirectoryAtPath(soundsPath, withIntermediateDirectories: false, attributes: nil)
        } catch let error1 as NSError {
            print("error" + error1.description)
        }
        let soundPathUrl = NSURL(fileURLWithPath: filePath)
        print(soundPathUrl)
        songData?.writeToURL(soundPathUrl,  atomically: true)
    }
    
  
    
    
}
