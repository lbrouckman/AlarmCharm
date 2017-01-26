//
//  Database.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/28/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//
// Both

import Foundation
import FirebaseDatabase
import Firebase

import AVFoundation

/* Databse class has all the remote database functionality needed. We used Firebase and got help from the following sources:
 https://www.firebase.com/docs/ios/quickstart.html
 https://www.raywenderlich.com/109706/firebase-tutorial-getting-started
 */

class Database {
    
    fileprivate var usersRef = FIRDatabase.database().reference().child("users")
    
    func changeWhoSetAlarm(_ alarmSetBy: String, forUser userID: String) {
        let uRef = FIRDatabase.database().reference().child("users")
        let hashedID = sha256(userID)!
        let currentUserRef = uRef.child(hashedID)
        let newSetter = ["friend_who_set_alarm" : alarmSetBy]
        currentUserRef.updateChildValues(newSetter)
    }
    
    func sha257(data: String) -> Data {
        var hash = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        if let newData: Data = data.data(using: .utf8) {
            _ = hash.withUnsafeMutableBytes {mutableBytes in
                newData.withUnsafeBytes {bytes in
                    CC_SHA256(bytes, CC_LONG(newData.count), mutableBytes)
                }
            }
        }
        return hash
    }
    
    func sha256(_ string: String) -> String? {
        var shaData = sha257(data: string)
        let rc = shaData.base64EncodedString(options: [])
        return rc
    }

    func uploadFileToDatabase(_ fileURL: URL, forUser userID: String, fileType: String) {
        let filename = fileURL.lastPathComponent
        let storage = FIRStorage.storage()
        let gsReference = storage.reference(forURL: "gs://project-5208532535641760898.appspot.com")
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
    func uploadUserMessageToDatabase(_ message: String, forUser userID: String){
        let uRef = FIRDatabase.database().reference().child("users")
        let hashedID = sha256(userID)!
        let currentUserRef = uRef.child(hashedID)
        let newMessage = ["user_message" : message]
        currentUserRef.updateChildValues(newMessage)
    }
    
    func uploadWakeUpMessageToDatabase(_ message: String, forUser userID: String){
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
    
    //Checks to see if a friend has set the alarm and if so, it gets the alarm and calls the completion handler that is in charge of storing it
    func hasUserAlarmBeenSet(forUser userID: String, completionHandler: @escaping (_ user: String, _ hasBeenSet: Bool, _ wakeUpMessage: String, _ friendWhoSetAlarm: String) -> ()){
        let hashedID = sha256(userID)!
        usersRef.child(hashedID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshotDictionary = snapshot.value as? NSDictionary{
                if let needFriendToSet = snapshotDictionary["need_friend_to_set"] as? Bool , needFriendToSet == false{
                    UserDefaults.setState(State.friendHasSetAlarm)
                    let hasBeenSet = !needFriendToSet
                    if let wakeUpMessage = snapshotDictionary["wakeup_message"] as? String{
                        if let friendWhoSetAlarm = snapshotDictionary["friend_who_set_alarm"] as? String{
                            completionHandler(userID, hasBeenSet, wakeUpMessage, friendWhoSetAlarm)
                        }
                    }
                    
                }
            }
            })
        { (error) in
            print(error)
        }
    }
    
    func updateTokenForUser(forUser userID: String, forToken tokenName: String){
        let uRef = FIRDatabase.database().reference().child("users")
        let hashedID = sha256(userID)!
        let currentUserRef = uRef.child(hashedID)
        let process = ["notification_token" : tokenName]
        currentUserRef.updateChildValues(process)
    }
    func addAlarmTimeToDatabase(_ date: Date){
        if let userId = Foundation.UserDefaults.standard.value(forKey: "PhoneNumber") as? String {
            let hashedID = sha256(userId)!
            let timestamp = date.timeIntervalSince1970
            let ref = FIRDatabase.database().reference()
            let usersRef = ref.child("users")
            let currUserRef = usersRef.child(hashedID)
            let newTime = ["alarm_time": timestamp]
            let needsToBeSet = ["need_friend_to_set" : true]
            let myState = ["state" : UserDefaults.getState().rawValue]
            currUserRef.updateChildValues(needsToBeSet)
            currUserRef.updateChildValues(newTime)
            currUserRef.updateChildValues(myState)
        }
    }
    
    
    //Downloads an image or audio file to the local file system, completion handler since this will be handled ansynchronously
    func downloadFileToLocal(forUser userID: String, fileType: String, completionHandler: @escaping (Bool) -> ()) {
        let hashedID = sha256(userID)!
        usersRef.child(hashedID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshotDictionary = snapshot.value as? NSDictionary {
                if let file = snapshotDictionary[fileType] as? String , file != ""{
                    let storage = FIRStorage.storage()
                    let gsReference = storage.reference(forURL: "gs://project-5208532535641760898.appspot.com")
                    let mediaRef = gsReference.child(file)
                    mediaRef.downloadURL { (URL, error) -> Void in
                        if (error != nil) {
                            print(error)
                            completionHandler(false)
                        } else {
                            if fileType == "image_file" {
                                self.saveToFileSystem(URL!, filetype: "/Images", fileName: "alarmImage.png")
                            } else if fileType == "audio_file" {
                                print(URL!, "Trying to be saved with file name", "alarmSound.caf")
                                self.saveToFileSystem(URL!, filetype: "/Sounds", fileName: "alarmSound.caf")
                            }
                            completionHandler(true)
                        }
                    }
                }
            }
            })
        { (error) in
            print(error)
        }
    }
    
    //Saves an NSURL to the file system (under a predictable name) so that the alarm image/audio can easily be retrieved from the local files
    fileprivate func saveToFileSystem(_ URL: Foundation.URL, filetype: String, fileName: String) {
        let data =  try? Data(contentsOf: URL)
        let fileManager = FileManager.default
        
        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let path = libraryPath + filetype
        let filePath = path + "/" + fileName
        do {
            //Try to remove old file if it was there
            do {
                try fileManager.removeItem(atPath: filePath)
            } catch let error as NSError {
                print(error.debugDescription, "trying to remove at alarm sounds")
            }
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        } catch let error1 as NSError {
            print("trying to overwrite sounnds" + error1.description)
        }
        let pathURL = Foundation.URL(fileURLWithPath: filePath)
        try? data?.write(to: pathURL,  options: [.atomic])
        print("hopefully wrote it out")
    }
    
    func addNewUserToDB(_ phoneNumber: String, username: String, token: String) {
        let phoneNumberHash = sha256(phoneNumber)
        let newUser = ["alarm_time": 0, "image_file": "", "audio_file": "", "wakeup_message" : "", "user_message" : "", "need_friend_to_set" : false, "in_process_of_being_set" : false, "friend_who_set_alarm" : "", "username": username, "notification_token" : token, "state" : 0] as [String : Any]
        let newUserRef = usersRef.child(phoneNumberHash!)
        newUserRef.setValue(newUser)
    }
    
    func addNotification(forUser phoneNumber : String, setBy charmerName : String){
        let phoneNumberHash = sha256(phoneNumber)
        // get token of user whose alarm is getting set, and add them to notifications queue.
        FIRDatabase.database().reference().child("users").child(phoneNumberHash!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshotDictionary = snapshot.value as? NSDictionary{
                if let userToken = snapshotDictionary["notification_token"] as? String{
                    let newNotification = [ "notificationId" : userToken,"setBy" : charmerName ]
                    let timeStamp = NSDate().timeIntervalSince1970.description
                    let notificationKey = timeStamp + charmerName
                    var newChildRef = FIRDatabase.database().reference().child("notificationQueue").childByAutoId()
                    newChildRef.setValue(newNotification)
                }
            }
            
        })
    }
    
    func userInDatabase(_ phoneNumber: String, completionHandler: @escaping (Bool) -> ()) {
        let phoneNumberHash = sha256(phoneNumber)
        usersRef.child(phoneNumberHash!).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        })
    }
}
