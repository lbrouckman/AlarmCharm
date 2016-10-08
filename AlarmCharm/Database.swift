//
//  Database.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/28/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//
// Both

import Foundation
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
    
    /* We got the 2 functions below from http://stackoverflow.com/questions/25388747/sha256-in-swift and they use the objective C code
     bridged in */
    fileprivate func sha256(_ data: Data) -> Data? {
        guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else { return nil }
//        CC_SHA256((data as NSData).bytes, CC_LONG(data.count), UnsafeMutablePointer(res.mutableBytes as? Int))
        return res as Data
    }
    
    func sha256(_ string: String) -> String? {
        guard
            let data = string.data(using: String.Encoding.utf8),
            let shaData = sha256(data)
            else { return nil }
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
            // should probably check to see if it is not null! not sure this is why it crashes but it is a possibility.
            if let snapDictionary = snapshot.value as? NSDictionary{
                if let needFriendToSet = snapDictionary["need_friend_to_set"] as? Bool , needFriendToSet == false{
                    let hasBeenSet = !needFriendToSet
                    if let wakeUpMessage = snapDictionary["wakeup_message"] as? String{
                        if let friendWhoSetAlarm = snapDictionary["friend_who_set_alarm"] as? String{
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
    
    func addAlarmTimeToDatabase(_ date: Date){
        if let userId = Foundation.UserDefaults.standard.value(forKey: "PhoneNumber") as? String {
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
    
    //Downloads an image or audio file to the local file system, completion handler since this will be handled ansynchronously
    func downloadFileToLocal(forUser userID: String, fileType: String, completionHandler: @escaping (Bool) -> ()) {
        let hashedID = sha256(userID)!
        usersRef.child(hashedID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapDictionary = snapshot.value as? NSDictionary{
                if let file = snapDictionary[fileType] as? String , file != ""{
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
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        } catch let error1 as NSError {
            print("error" + error1.description)
        }
        let pathURL = Foundation.URL(fileURLWithPath: filePath)
        try? data?.write(to: pathURL,  options: [.atomic])
    }
    
    /*
     Given the url, it turns url into NSDATA and then saves the file in the libray/sounds folder.
     */
    fileprivate func saveToFileSystem(_ URL : Foundation.URL, fileName: String){
        let songData =  try? Data(contentsOf: URL)
        let fileManager = FileManager.default
        
        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let soundsPath = libraryPath + "/Sounds"
        let filePath = soundsPath + "/" + fileName
        do {
            try fileManager.createDirectory(atPath: soundsPath, withIntermediateDirectories: false, attributes: nil)
        } catch let error1 as NSError {
            print("error" + error1.description)
        }
        let soundPathUrl = Foundation.URL(fileURLWithPath: filePath)
        try? songData?.write(to: soundPathUrl,  options: [.atomic])
    }
    
    func addNewUserToDB(_ phoneNumber: String, username: String) {
        let phoneNumberHash = sha256(phoneNumber)
        let newUser = ["alarm_time": 0, "image_file": "", "audio_file": "", "wakeup_message" : "", "user_message" : "", "need_friend_to_set" : false, "in_process_of_being_set" : false, "friend_who_set_alarm" : "", "username": username] as [String : Any]
        let newUserRef = usersRef.child(phoneNumberHash!)
        newUserRef.setValue(newUser)
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
