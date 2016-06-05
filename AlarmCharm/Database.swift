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
    
    func changeWhoSetAlarm(alarmSetBy: String, forUser userID: String) {
        let uRef = FIRDatabase.database().reference().child("users")
        let hashedID = sha256(userID)!
        let currentUserRef = uRef.child(hashedID)
        let newSetter = ["friend_who_set_alarm" : alarmSetBy]
        currentUserRef.updateChildValues(newSetter)
    }
    
    
    private func sha256(data: NSData) -> NSData? {
        guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else { return nil }
        CC_SHA256(data.bytes, CC_LONG(data.length), UnsafeMutablePointer(res.mutableBytes))
        return res
    }
    
    func sha256(string: String) -> String? {
        guard
            let data = string.dataUsingEncoding(NSUTF8StringEncoding),
            let shaData = sha256(data)
            else { return nil }
        let rc = shaData.base64EncodedStringWithOptions([])
        return rc
    }
    
    
    func uploadFileToDatabase(fileURL: NSURL, forUser userID: String, fileType: String) {
        let filename = fileURL.lastPathComponent!
        let storage = FIRStorage.storage()
        let gsReference = storage.referenceForURL("gs://project-5208532535641760898.appspot.com")
        let fileRef = gsReference.child(filename)
        
        let _ = fileRef.putFile(fileURL, metadata: nil) { metadata, error in
            if (error != nil) {
                print(error)
            } else {
                let hashedID = self.sha256(userID)!
                let currUserRef = self.usersRef.child(hashedID)
                
                if fileType == "Audio" {
                    let newSound = ["audio_file": filename]
                    currUserRef.updateChildValues(newSound)
                } else if fileType == "Image" {
                    let newImage = ["image_file": filename]
                    currUserRef.updateChildValues(newImage)
                }
                
                let userNoLongerNeedsToBeSet = ["need_friend_to_set" : false]
                let notInProcess = ["in_process_of_being_set" : false]
                currUserRef.updateChildValues(notInProcess)
                currUserRef.updateChildValues(userNoLongerNeedsToBeSet)
            }
        }
        
    }
    
    // After user sets their message, this function puts their message in the database
    func uploadUserMessageToDatabase(message: String, forUser userID: String){
        let uRef = FIRDatabase.database().reference().child("users")
        let hashedID = sha256(userID)!
        let currentUserRef = uRef.child(hashedID)
        let newMessage = ["user_message" : message]
        currentUserRef.updateChildValues(newMessage)
    }
    
    func uploadWakeUpMessageToDatabase(message: String, forUser userID: String){
        let uRef = FIRDatabase.database().reference().child("users")
        let hashedID = sha256(userID)!
        let currentUserRef = uRef.child(hashedID)
        let newMessage = ["wakeup_message" : message]
        currentUserRef.updateChildValues(newMessage)
    }
    
    func userNeedsAlarmToBeSet(forUser userID: String , toBeSet: Bool){
        let uRef = FIRDatabase.database().reference().child("users")
        let hashedID = sha256(userID)!
        let currentUserRef = uRef.child(hashedID)
        let needsSetting = ["need_friend_to_set" : toBeSet]
        currentUserRef.updateChildValues(needsSetting)
    }
    
    // then this means that we have already notified the current user.
    // Let's put message, FriendName both in NSUSER Defaults
    //
    func hasUserAlarmBeenSet(forUser userID: String, completionHandler: (user: String, hasBeenSet: Bool, wakeUpMessage: String, friendWhoSetAlarm: String) -> ()){
        let hashedID = sha256(userID)!
        usersRef.child(hashedID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let needFriendToSet = snapshot.value!["need_friend_to_set"] as? Bool where needFriendToSet == false{
                let hasBeenSet = !needFriendToSet
                print("has been set has value", hasBeenSet)
                if let wakeUpMessage = snapshot.value!["wakeup_message"] as? String{
                    print("wake up Message: ", wakeUpMessage)
                    if let friendWhoSetAlarm = snapshot.value!["friend_who_set_alarm"] as? String{
                        print("friend who set alarm was : ", friendWhoSetAlarm)
                        completionHandler(user: userID, hasBeenSet: hasBeenSet, wakeUpMessage: wakeUpMessage, friendWhoSetAlarm: friendWhoSetAlarm)
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
            let hashedID = sha256(userId)!
            let timestamp = date.timeIntervalSince1970
            let ref = FIRDatabase.database().reference()
            let usersRef = ref.child("users")
            let currUserRef = usersRef.child(hashedID)
            let newTime = ["alarm_time": timestamp]
            let needsToBeSet = ["need_friend_to_set" : true]
            
            currUserRef.updateChildValues(needsToBeSet)
            currUserRef.updateChildValues(newTime)
        }
    }
    
    func userInProcessOfBeingSet(forUser userID: String, inProcess : Bool){
        let uRef = FIRDatabase.database().reference().child("users")
        let hashedID = sha256(userID)!
        let currentUserRef = uRef.child(hashedID)
        let process = ["in_process_of_being_set" : inProcess]
        currentUserRef.updateChildValues(process)
    }
    
    
    func downloadFileToLocal(forUser userID: String, completionHandler: (Bool) -> ()) {
        let hashedID = sha256(userID)!
        usersRef.child(hashedID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
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
    
    func addNewUserToDB(phoneNumber: String) {
        let phoneNumberHash = sha256(phoneNumber)
        let newUser = ["alarm_time": 0, "image_file": "", "audio_file": "", "wakeup_message" : "", "user_message" : "", "need_friend_to_set" : false, "in_process_of_being_set" : false, "friend_who_set_alarm" : ""]
        let newUserRef = usersRef.child(phoneNumberHash!)
        newUserRef.setValue(newUser)
    }
    
    func userInDatabase(phoneNumber: String, completionHandler: (Bool) -> ()) {
        let phoneNumberHash = sha256(phoneNumber)
        
        usersRef.child(phoneNumberHash!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if snapshot.value is NSNull {
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        })
    }
}
